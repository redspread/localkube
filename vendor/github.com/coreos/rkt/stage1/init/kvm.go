// Copyright 2014 The rkt Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//+build linux

package main

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"

	"github.com/appc/spec/schema"
	"github.com/appc/spec/schema/types"
	"github.com/coreos/rkt/common"
	"github.com/coreos/rkt/networking"
	stage1commontypes "github.com/coreos/rkt/stage1/common/types"
	stage1initcommon "github.com/coreos/rkt/stage1/init/common"
	"github.com/coreos/rkt/stage1/init/kvm"
	"github.com/hashicorp/errwrap"
)

// KvmNetworkingToSystemd generates systemd unit files for a pod according to network configuration
func KvmNetworkingToSystemd(p *stage1commontypes.Pod, n *networking.Networking) error {
	podRoot := common.Stage1RootfsPath(p.Root)

	// networking
	netDescriptions := kvm.GetNetworkDescriptions(n)
	if err := kvm.GenerateNetworkInterfaceUnits(filepath.Join(podRoot, stage1initcommon.UnitsDir), netDescriptions); err != nil {
		return errwrap.Wrap(errors.New("failed to transform networking to units"), err)
	}

	return nil
}

func mountSharedVolumes(root string, p *stage1commontypes.Pod, ra *schema.RuntimeApp) error {
	app := ra.App
	appName := ra.Name
	volumes := p.Manifest.Volumes
	vols := make(map[types.ACName]types.Volume)
	for _, v := range volumes {
		vols[v.Name] = v
	}

	sharedVolPath := common.SharedVolumesPath(root)
	if err := os.MkdirAll(sharedVolPath, stage1initcommon.SharedVolPerm); err != nil {
		return errwrap.Wrap(errors.New("could not create shared volumes directory"), err)
	}
	if err := os.Chmod(sharedVolPath, stage1initcommon.SharedVolPerm); err != nil {
		return errwrap.Wrap(fmt.Errorf("could not change permissions of %q", sharedVolPath), err)
	}

	imageManifest := p.Images[appName.String()]
	mounts := stage1initcommon.GenerateMounts(ra, vols, imageManifest)
	for _, m := range mounts {
		vol := vols[m.Volume]

		if vol.Kind == "empty" {
			p := filepath.Join(sharedVolPath, vol.Name.String())
			if err := os.MkdirAll(p, stage1initcommon.SharedVolPerm); err != nil {
				return errwrap.Wrap(fmt.Errorf("could not create shared volume %q", vol.Name), err)
			}
			if err := os.Chown(p, *vol.UID, *vol.GID); err != nil {
				return errwrap.Wrap(fmt.Errorf("could not change owner of %q", p), err)
			}
			mod, err := strconv.ParseUint(*vol.Mode, 8, 32)
			if err != nil {
				return errwrap.Wrap(fmt.Errorf("invalid mode %q for volume %q", *vol.Mode, vol.Name), err)
			}
			if err := os.Chmod(p, os.FileMode(mod)); err != nil {
				return errwrap.Wrap(fmt.Errorf("could not change permissions of %q", p), err)
			}
		}

		readOnly := stage1initcommon.IsMountReadOnly(vol, app.MountPoints)
		var source string
		switch vol.Kind {
		case "host":
			source = vol.Source
		case "empty":
			source = filepath.Join(common.SharedVolumesPath(root), vol.Name.String())
		default:
			return fmt.Errorf(`invalid volume kind %q. Must be one of "host" or "empty"`, vol.Kind)
		}
		absAppRootfs, err := filepath.Abs(common.AppRootfsPath(root, appName))
		if err != nil {
			return fmt.Errorf(`could not evaluate absolute path for application rootfs in app: %v`, appName)
		}

		absDestination, err := filepath.Abs(filepath.Join(absAppRootfs, m.Path))
		if err != nil {
			return fmt.Errorf(`could not evaluate absolute path for application volume path %q in: %v`, m.Path, appName)
		}
		if !strings.HasPrefix(absDestination, absAppRootfs) {
			return fmt.Errorf("path escapes app's root: %v", absDestination)
		}
		if cleanedSource, err := filepath.EvalSymlinks(source); err != nil {
			return errwrap.Wrap(fmt.Errorf("could not resolve symlink for source: %v", source), err)
		} else if err := ensureDestinationExists(cleanedSource, absDestination); err != nil {
			return errwrap.Wrap(fmt.Errorf("could not create destination mount point: %v", absDestination), err)
		} else if err := doBindMount(cleanedSource, absDestination, readOnly); err != nil {
			return errwrap.Wrap(fmt.Errorf("could not bind mount path %v (s: %v, d: %v)", m.Path, source, absDestination), err)
		}
	}
	return nil
}

func doBindMount(source, destination string, readOnly bool) error {
	if err := syscall.Mount(source, destination, "bind", syscall.MS_BIND, ""); err != nil {
		return err
	}
	if readOnly {
		return syscall.Mount(source, destination, "bind", syscall.MS_REMOUNT|syscall.MS_RDONLY|syscall.MS_BIND, "")
	}
	return nil
}

func ensureDestinationExists(source, destination string) error {
	fileInfo, err := os.Stat(source)
	if err != nil {
		return errwrap.Wrap(fmt.Errorf("could not stat source location: %v", source), err)
	}

	targetPathParent, _ := filepath.Split(destination)
	if err := os.MkdirAll(targetPathParent, stage1initcommon.SharedVolPerm); err != nil {
		return errwrap.Wrap(fmt.Errorf("could not create parent directory: %v", targetPathParent), err)
	}

	if fileInfo.IsDir() {
		if err := os.Mkdir(destination, stage1initcommon.SharedVolPerm); !os.IsExist(err) {
			return err
		}
	} else {
		if file, err := os.OpenFile(destination, os.O_CREATE, stage1initcommon.SharedVolPerm); err != nil {
			return err
		} else {
			file.Close()
		}
	}
	return nil
}

func prepareMountsForApp(s1Root string, p *stage1commontypes.Pod, ra *schema.RuntimeApp) error {
	// bind mount all shared volumes (we don't use mechanism for bind-mounting given by nspawn)
	if err := mountSharedVolumes(s1Root, p, ra); err != nil {
		return errwrap.Wrap(errors.New("failed to prepare mount point"), err)
	}

	return nil
}

func KvmPrepareMounts(s1Root string, p *stage1commontypes.Pod) error {
	for i := range p.Manifest.Apps {
		ra := &p.Manifest.Apps[i]
		if err := prepareMountsForApp(s1Root, p, ra); err != nil {
			return errwrap.Wrap(fmt.Errorf("failed prepare mounts for app %q", ra.Name), err)
		}
	}

	return nil
}
