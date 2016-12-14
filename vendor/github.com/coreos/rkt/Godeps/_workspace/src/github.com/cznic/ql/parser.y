%{
// Copyright (c) 2014 The ql Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
		
// Inital yacc source generated by ebnf2y[1]
// at 2013-10-04 23:10:47.861401015 +0200 CEST
//
//  $ ebnf2y -o ql.y -oe ql.ebnf -start StatementList -pkg ql -p _
// 
//   [1]: http://github.com/cznic/ebnf2y

package ql

import (
	"fmt"

	"github.com/cznic/mathutil"
)

%}

%union {
	line int
	col  int
	item interface{}
	list []interface{}
}

%token	<item>

	/*yy:token "1.%d"   */	floatLit	"floating-point literal"
	/*yy:token "%c"     */	identifier	"identifier"
	/*yy:token "%di"    */	imaginaryLit	"imaginary literal"
	/*yy:token "%d"     */	intLit		"integer literal"
	/*yy:token "$%d"    */	qlParam		"QL parameter"
	/*yy:token "\"%c\"" */	stringLit	"string literal"

	add		"ADD"
	alter		"ALTER"
	and 		"AND"
	andand 		"&&"
	andnot		"&^"
	as		"AS"
	asc		"ASC"
	begin		"BEGIN"
	between		"BETWEEN"
	bigIntType	"bigint"
	bigRatType	"bigrat"
	blobType	"blob"
	boolType	"bool"
	by		"BY"
	byteType	"byte"
	column		"COLUMN"
	commit		"COMMIT"
	complex128Type	"complex128"
	complex64Type	"complex64"
	create		"CREATE"
	defaultKwd	"DEFAULT"
	deleteKwd	"DELETE"
	desc		"DESC"
	distinct	"DISTINCT"
	drop		"DROP"
	durationType	"duration"
	eq		"=="
	exists		"EXISTS"
	explain		"EXPLAIN"
	falseKwd	"false"
	floatType	"float"
	float32Type	"float32"
	float64Type	"float64"
	from		"FROM"
	full		"FULL"
	ge		">="
	group		"GROUP"
	ifKwd		"IF"
	in		"IN"
	index		"INDEX"
	insert		"INSERT"
	intType		"int"
	int16Type	"int16"
	int32Type	"int32"
	int64Type	"int64"
	int8Type	"int8"
	into		"INTO"
	is		"IS"
	join		"JOIN"
	le		"<="
	left		"LEFT"
	like		"LIKE"
	limit		"LIMIT"
	lsh 		"<<"
	neq		"!="
	not		"NOT"
	null		"NULL"
	offset		"OFFSET"
	on		"ON"
	or		"OR"
	order		"ORDER"
	oror		"||"
	outer		"OUTER"
	right		"RIGHT"
	rollback	"ROLLBACK"
	rsh		">>"
	runeType	"rune"
	selectKwd	"SELECT"
	set		"SET"
	stringType	"string"
	tableKwd	"TABLE"
	timeType	"time"
	transaction	"TRANSACTION"
	trueKwd		"true"
	truncate	"TRUNCATE"
	uintType	"uint"
	uint16Type	"uint16"
	uint32Type	"uint32"
	uint64Type	"uint64"
	uint8Type	"uint8",
	unique		"UNIQUE"
	update		"UPDATE"
	values		"VALUES"
	where		"WHERE"

	parseExpression	"parse expression prefix"

%type	<item>
	AlterTableStmt		"ALTER TABLE statement"
	Assignment		"assignment"
	AssignmentList		"assignment list"
	AssignmentList1		"assignment list optional trailing comma"
	BeginTransactionStmt	"BEGIN TRANSACTION statement"
	Call			"function call"
	Call1			"function call optional argument list"
	ColumnDef		"table column definition"
	ColumnName		"column name"
	ColumnNameList		"column name list"
	ColumnNameList1		"column name list with optional trailing comma"
	CommaOpt		"optional comma"
	CommitStmt		"COMMIT statement"
	Constraint		"column value constraint"
	ConstraintOpt		"optional column value constraint"
	Conversion		"conversion"
	CreateIndexStmt		"CREATE INDEX statement"
	CreateIndexIfNotExists	"CREATE INDEX statement optional IF NOT EXISTS cluse"
	CreateIndexStmtUnique	"CREATE INDEX optional UNIQUE clause"
	CreateTableStmt		"CREATE TABLE statement"
	CreateTableStmt1	"CREATE TABLE statement colum definition list"
	Default			"DEFAULT clause"
	DefaultOpt		"optional DEFAULT clause"
	DeleteFromStmt		"DELETE FROM statement"
	DropIndexStmt		"DROP INDEX statement"
	DropIndexIfExists	"DROP INDEX statement optional IF EXISTS clause"
	DropTableStmt		"DROP TABLE statement"
	EmptyStmt		"empty statement"
	ExplainStmt		"EXPLAIN statement"
	Expression		"expression"
	ExpressionList		"expression list"
	ExpressionList1		"expression list expression"
	Factor			"expression factor"
	Factor1			"binary expression factor"
	Field			"field expression"
	Field1			"field expression optional AS clause"
	FieldList		"field expression list"
	GroupByClause		"GROUP BY clause"
	Index			"string index"
	InsertIntoStmt		"INSERT INTO statement"
	InsertIntoStmt1		"INSERT INTO statement optional column list clause"
	InsertIntoStmt2		"INSERT INTO statement optional values list"
	JoinClause		"SELECT statement JOIN clause"
	JoinClauseOpt		"SELECT statement optional JOIN clause"
	JoinType		"join type"
	Literal			"literal value"
	logAnd			"logical and operator"
	logOr			"logical or operator"
	Operand			"operand"
	OrderBy			"ORDER BY clause"
	OrderBy1		"ORDER BY clause optional collation specification"
	OuterOpt		"optional OUTER clause"
	QualifiedIdent		"qualified identifier"
	PrimaryExpression	"primary expression"
	PrimaryFactor		"primary expression factor"
	PrimaryTerm		"primary expression term"
	RecordSet		"record set"
	RecordSet1		"record set name or parenthesized SELECTECT statement"
	RecordSet2		"record set optional AS clause"
	RollbackStmt		"ROLLBACK statement"
	SelectStmt		"SELECT statement"
	SelectStmtDistinct	"SELECT statement optional DISTINCT clause"
	SelectStmtFieldList	"SELECT statement field list"
	SelectStmtLimit		"SELECT statement optional LIMIT clause"
	SelectStmtWhere		"SELECT statement optional WHERE clause"
	SelectStmtGroup		"SELECT statement optional GROUP BY clause"
	SelectStmtOffset	"SELECT statement optional OFFSET clause"
	SelectStmtOrder		"SELECT statement optional ORDER BY clause"
	Slice			"string slice"
	Statement		"statement"
	StatementList		"statement list"
	TableName		"table name"
	Term			"expression term"
	TruncateTableStmt	"TRANSACTION TABLE statement"
	Type			"type"
	UnaryExpr		"unary expression"
	UpdateStmt		"UPDATE statement"
	UpdateStmt1		"UPDATE statement optional WHERE clause"
	WhereClause		"WHERE clause"

%type	<list>	RecordSetList

%start	Start

%%

Start:
	StatementList
|	parseExpression Expression
	{
		yylex.(*lexer).expr = expr($2)
	}

AlterTableStmt:
	"ALTER" "TABLE" TableName "ADD" ColumnDef
	{
		$$ = &alterTableAddStmt{tableName: $3.(string), c: $5.(*col)}
	}
|	"ALTER" "TABLE" TableName "DROP" "COLUMN" ColumnName
	{
		$$ = &alterTableDropColumnStmt{tableName: $3.(string), colName: $6.(string)}
	}

Assignment:
	ColumnName '=' Expression
	{
		$$ = assignment{colName: $1.(string), expr: expr($3)}
	}

AssignmentList:
	Assignment AssignmentList1 CommaOpt
	{
		$$ = append([]assignment{$1.(assignment)}, $2.([]assignment)...)
	}

AssignmentList1:
	/* EMPTY */
	{
		$$ = []assignment{}
	}
|	AssignmentList1 ',' Assignment
	{
		$$ = append($1.([]assignment), $3.(assignment))
	}

BeginTransactionStmt:
	"BEGIN" "TRANSACTION"
	{
		$$ = beginTransactionStmt{}
	}

Call:
	'(' Call1 ')'
	{
		$$ = $2
	}
|	'(' '*' ')'
	{
		$<item>$ = '*'
	}

Call1:
	/* EMPTY */
	{
		$$ = []expression{}
	}
|	ExpressionList

ColumnDef:
	ColumnName Type ConstraintOpt DefaultOpt
	{
		x := &col{name: $1.(string), typ: $2.(int), constraint: $3.(*constraint)}
		if $4 != nil {
			x.dflt = expr($4)
		}
		$$ = x
	}

ColumnName:
	identifier

ColumnNameList:
	ColumnName ColumnNameList1 CommaOpt
	{
		$$ = append([]string{$1.(string)}, $2.([]string)...)
	}

ColumnNameList1:
	/* EMPTY */
	{
		$$ = []string{}
	}
|	ColumnNameList1 ',' ColumnName
	{
		$$ = append($1.([]string), $3.(string))
	}

CommitStmt:
	"COMMIT"
	{
		$$ = commitStmt{}
	}

Constraint:
	"NOT" "NULL"
	{
		$$ = &constraint{}
	}
|	Expression
	{
		$$ = &constraint{expr($1)}
	}

ConstraintOpt:
	{
		$$ = (*constraint)(nil)
	}
|	Constraint

Conversion:
	Type '(' Expression ')'
	{
		$$ = &conversion{typ: $1.(int), val: expr($3)}
	}

CreateIndexStmt:
	"CREATE" CreateIndexStmtUnique "INDEX" CreateIndexIfNotExists identifier "ON" identifier '(' ExpressionList ')'
	{
		indexName, tableName, exprList := $5.(string), $7.(string), $9.([]expression)
		simpleIndex := len(exprList) == 1
		var columnName string
		if simpleIndex {
			expr := exprList[0]
			switch x := expr.(type) {
			case *ident:
				columnName = x.s
			case *call:
				if x.f == "id" && len(x.arg) == 0 {
					columnName = "id()"
					break
				}

				simpleIndex = false
			default:
				simpleIndex = false
			}
		}
		
		if !simpleIndex {
			columnName = ""
		}
		$$ = &createIndexStmt{unique: $2.(bool), ifNotExists: $4.(bool), indexName: indexName, tableName: tableName, colName: columnName, exprList: exprList}

		if indexName == tableName || indexName == columnName {
			yylex.(*lexer).err("index name collision: %s", indexName)
			return 1
		}

		if yylex.(*lexer).root {
			break
		}

		if isSystemName[indexName] || isSystemName[tableName] {
			yylex.(*lexer).err("name is used for system tables: %s", indexName)
			return 1
		}
	}

CreateIndexIfNotExists:
	{
		$$ = false
	}
|	"IF" "NOT" "EXISTS"
	{
		$$ = true
	}

CreateIndexStmtUnique:
	{
		$$ = false
	}
|	"UNIQUE"
	{
		$$ = true
	}

CreateTableStmt:
	"CREATE" "TABLE" TableName '(' ColumnDef CreateTableStmt1 CommaOpt ')'
	{
		nm := $3.(string)
		$$ = &createTableStmt{tableName: nm, cols: append([]*col{$5.(*col)}, $6.([]*col)...)}

		if yylex.(*lexer).root {
			break
		}

		if isSystemName[nm] {
			yylex.(*lexer).err("name is used for system tables: %s", nm)
			return 1
		}
	}
|	"CREATE" "TABLE" "IF" "NOT" "EXISTS" TableName '(' ColumnDef CreateTableStmt1 CommaOpt ')'
	{
		nm := $6.(string)
		$$ = &createTableStmt{ifNotExists: true, tableName: nm, cols: append([]*col{$8.(*col)}, $9.([]*col)...)}

		if yylex.(*lexer).root {
			break
		}

		if isSystemName[nm] {
			yylex.(*lexer).err("name is used for system tables: %s", nm)
			return 1
		}
	}

CreateTableStmt1:
	/* EMPTY */
	{
		$$ = []*col{}
	}
|	CreateTableStmt1 ',' ColumnDef
	{
		$$ = append($1.([]*col), $3.(*col))
	}

Default:
	"DEFAULT" Expression
	{
		$$ = $2
	}

DefaultOpt:
	{
		$$ = nil
	}
|	Default

DeleteFromStmt:
	"DELETE" "FROM" TableName
	{
		$$ = &truncateTableStmt{$3.(string)}

		if yylex.(*lexer).root {
			break
		}

		if isSystemName[$3.(string)] {
			yylex.(*lexer).err("name is used for system tables: %s", $3.(string))
			return 1
		}
	}
|	"DELETE" "FROM" TableName WhereClause
	{
		$$ = &deleteStmt{tableName: $3.(string), where: $4.(*whereRset).expr}

		if yylex.(*lexer).root {
			break
		}

		if isSystemName[$3.(string)] {
			yylex.(*lexer).err("name is used for system tables: %s", $3.(string))
			return 1
		}
	}

DropIndexStmt:
	"DROP" "INDEX" DropIndexIfExists identifier
	{
		$$ = &dropIndexStmt{ifExists: $3.(bool), indexName: $4.(string)}
	}

DropIndexIfExists:
	{
		$$ = false
	}
|	"IF" "EXISTS"
	{
		$$ = true
	}

DropTableStmt:
	"DROP" "TABLE" TableName
	{
		nm := $3.(string)
		$$ = &dropTableStmt{tableName: nm}

		if yylex.(*lexer).root {
			break
		}

		if isSystemName[nm] {
			yylex.(*lexer).err("name is used for system tables: %s", nm)
			return 1
		}
	}
|	"DROP" "TABLE" "IF" "EXISTS" TableName
	{
		nm := $5.(string)
		$$ = &dropTableStmt{ifExists: true, tableName: nm}

		if yylex.(*lexer).root {
			break
		}

		if isSystemName[nm] {
			yylex.(*lexer).err("name is used for system tables: %s", nm)
			return 1
		}
	}

EmptyStmt:
	/* EMPTY */
	{
		$$ = nil
	}

ExplainStmt:
	"EXPLAIN" Statement
	{
		$$ = &explainStmt{$2.(stmt)}
	}

Expression:
	Term
|	Expression logOr Term
	{
		var err error
		if $$, err = newBinaryOperation(oror, $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}

logOr:
	"||"
	{
	}
|	"OR"
	{
	}

ExpressionList:
	Expression ExpressionList1 CommaOpt
	{
		$$ = append([]expression{expr($1)}, $2.([]expression)...)
	}

ExpressionList1:
	/* EMPTY */
	{
		$$ = []expression(nil)
	}
|	ExpressionList1 ',' Expression
	{
		$$ = append($1.([]expression), expr($3))
	}

Factor:
	Factor1
|       Factor1 "IN" '(' ExpressionList ')'
        {
		$$ = &pIn{expr: $1.(expression), list: $4.([]expression)}
        }
|       Factor1 "NOT" "IN" '(' ExpressionList ')'
        {
		$$ = &pIn{expr: $1.(expression), not: true, list: $5.([]expression)}
        }
|       Factor1 "IN" '(' SelectStmt semiOpt ')'
        {
		$$ = &pIn{expr: $1.(expression), sel: $4.(*selectStmt)}
        }
|       Factor1 "NOT" "IN" '(' SelectStmt semiOpt ')'
        {
		$$ = &pIn{expr: $1.(expression), not: true, sel: $5.(*selectStmt)}
        }
|       Factor1 "BETWEEN" PrimaryFactor "AND" PrimaryFactor
        {
		var err error
		if $$, err = newBetween($1, $3, $5, false); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|       Factor1 "NOT" "BETWEEN" PrimaryFactor "AND" PrimaryFactor
        {
		var err error
		if $$, err = newBetween($1, $4, $6, true); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|       Factor1 "IS" "NULL"
        {
		$$ = &isNull{expr: $1.(expression)}
        }
|       Factor1 "IS" "NOT" "NULL"
        {
		$$ = &isNull{expr: $1.(expression), not: true}
        }

Factor1:
        PrimaryFactor
|       Factor1 ">=" PrimaryFactor
        {
		var err error
		if $$, err = newBinaryOperation(ge, $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|       Factor1 '>' PrimaryFactor
        {
		var err error
		if $$, err = newBinaryOperation('>', $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|       Factor1 "<=" PrimaryFactor
        {
		var err error
		if $$, err = newBinaryOperation(le, $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|       Factor1 '<' PrimaryFactor
        {
		var err error
		if $$, err = newBinaryOperation('<', $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|       Factor1 "!=" PrimaryFactor
        {
		var err error
		if $$, err = newBinaryOperation(neq, $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|       Factor1 "==" PrimaryFactor
        {
		var err error
		if $$, err = newBinaryOperation(eq, $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
        }
|	Factor1 "LIKE" PrimaryFactor
	{
		$$ = &pLike{expr: $1.(expression), pattern: $3.(expression)}
	}

Field:
	Expression Field1
	{
		expr, name := expr($1), $2.(string)
		if name == "" {
			s, ok := expr.(*ident)
			if ok {
				name = s.s
			}
		}
		$$ = &fld{expr: expr, name: name}
	}

Field1:
	/* EMPTY */
	{
		$$ = ""
	}
|	"AS" identifier
	{
		$$ = $2
	}

FieldList:
	Field
	{
		$$ = []*fld{$1.(*fld)}
	}
|	FieldList ',' Field
	{
		l, f := $1.([]*fld), $3.(*fld)
		if f.name != "" {
			if f := findFld(l, f.name); f != nil {
				yylex.(*lexer).err("duplicate field name %q", f.name)
				return 1
			}
		}

		$$ = append($1.([]*fld), $3.(*fld))
	}

GroupByClause:
	"GROUP" "BY" ColumnNameList
	{
		$$ = &groupByRset{colNames: $3.([]string)}
	}

Index:
	'[' Expression ']'
	{
		$$ = $2
	}

InsertIntoStmt:
	"INSERT" "INTO" TableName InsertIntoStmt1 "VALUES" '(' ExpressionList ')' InsertIntoStmt2 CommaOpt
	{
		$$ = &insertIntoStmt{tableName: $3.(string), colNames: $4.([]string), lists: append([][]expression{$7.([]expression)}, $9.([][]expression)...)}

		if yylex.(*lexer).root {
			break
		}

		if isSystemName[$3.(string)] {
			yylex.(*lexer).err("name is used for system tables: %s", $3.(string))
			return 1
		}
	}
|	"INSERT" "INTO" TableName InsertIntoStmt1 SelectStmt
	{
		$$ = &insertIntoStmt{tableName: $3.(string), colNames: $4.([]string), sel: $5.(*selectStmt)}
	}

InsertIntoStmt1:
	/* EMPTY */
	{
		$$ = []string{}
	}
|	'(' ColumnNameList ')'
	{
		$$ = $2
	}

InsertIntoStmt2:
	/* EMPTY */
	{
		$$ = [][]expression{}
	}
|	InsertIntoStmt2 ',' '(' ExpressionList ')'
	{
		$$ = append($1.([][]expression), $4.([]expression))
	}

Literal:
	"false"
|	"NULL"
|	"true"
|	floatLit
|	imaginaryLit
|	intLit
|	stringLit

Operand:
	Literal
	{
		$$ = value{$1}
	}
|	qlParam
	{
		n := $1.(int)
		$$ = parameter{n}
		l := yylex.(*lexer)
		l.params = mathutil.Max(l.params, n)
		if n == 0 {
			l.err("parameter number must be non zero")
			return 1
		}
	}
|	QualifiedIdent
	{
		$$ = &ident{$1.(string)}
	}
|	'(' Expression ')'
	{
		$$ = &pexpr{expr: expr($2)}
	}

OrderBy:
	"ORDER" "BY" ExpressionList OrderBy1
	{
		$$ = &orderByRset{by: $3.([]expression), asc: $4.(bool)}
	}

OrderBy1:
	/* EMPTY */
	{
		$$ = true // ASC by default
	}
|	"ASC"
	{
		$$ = true
	}
|	"DESC"
	{
		$$ = false
	}

PrimaryExpression:
	Operand
|	Conversion
|	PrimaryExpression Index
	{
		var err error
		if $$, err = newIndex($1.(expression), expr($2)); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryExpression Slice
	{
		var err error
		s := $2.([2]*expression)
		if $$, err = newSlice($1.(expression), s[0], s[1]); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryExpression Call
	{
		x := yylex.(*lexer)
		f, ok := $1.(*ident)
		if !ok {
			x.err("expected identifier or qualified identifier")
			return 1
		}

		if r, ok := $2.(rune); ok {
			if f.isQualified() || f.s != "count" || r != '*' {
				x.err(fmt.Sprintf("invalid expression %s(%c)", f, r))
				return 1
			}

			$2 = []expression(nil)
		}

		var err error
		var agg bool
		if $$, agg, err = newCall(f.s, $2.([]expression)); err != nil {
			x.err("%v", err)
			return 1
		}
		if n := len(x.agg); n > 0 {
			x.agg[n-1] = x.agg[n-1] || agg
		}
	}

PrimaryFactor:
	PrimaryTerm
|	PrimaryFactor '^' PrimaryTerm
	{
		var err error
		if $$, err = newBinaryOperation('^', $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryFactor '|' PrimaryTerm
	{
		var err error
		if $$, err = newBinaryOperation('|', $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryFactor '-' PrimaryTerm
	{
		var err error
		if $$, err = newBinaryOperation('-', $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryFactor '+' PrimaryTerm
	{
		var err error
		$$, err = newBinaryOperation('+', $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}

PrimaryTerm:
	UnaryExpr
|	PrimaryTerm "&^" UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation(andnot, $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryTerm '&' UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation('&', $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryTerm "<<" UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation(lsh, $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryTerm ">>" UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation(rsh, $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryTerm '%' UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation('%', $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryTerm '/' UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation('/', $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	PrimaryTerm '*' UnaryExpr
	{
		var err error
		$$, err = newBinaryOperation('*', $1, $3)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}

QualifiedIdent:
	identifier
|	identifier '.' identifier
	{
		$$ = fmt.Sprintf("%s.%s", $1.(string), $3.(string))
	}

RecordSet:
	RecordSet1 RecordSet2
	{
		$$ = []interface{}{$1, $2}
	}

RecordSet1:
	identifier
|	'(' SelectStmt semiOpt ')'
	{
		$$ = $2
	}

semiOpt:
	/* EMPTY */
|	';'

RecordSet2:
	/* EMPTY */
	{
		$$ = ""
	}
|	"AS" identifier
	{
		$$ = $2
	}

RecordSetList:
	RecordSet
	{
		$$ = []interface{}{$1}
	}
|	RecordSetList ',' RecordSet
	{
		$$ = append($1, $3)
	}

RollbackStmt:
	"ROLLBACK"
	{
		$$ = rollbackStmt{}
	}

JoinType:
	"LEFT"
	{
		$$ = leftJoin
	}
|	"RIGHT"
	{
		$$ = rightJoin
	}
|	"FULL"
	{
		$$ = fullJoin
	}

OuterOpt:
	{
		$$ = nil
	}
|	"OUTER"

JoinClause:
	JoinType OuterOpt "JOIN" RecordSet "ON" Expression
	{
		$$ = []interface{}{$1, $4, $6}
	}

JoinClauseOpt:
	{
		$$ = nil
	}
|	JoinClause

SelectStmt:
	"SELECT" SelectStmtDistinct SelectStmtFieldList "FROM" RecordSetList
	CommaOpt JoinClauseOpt SelectStmtWhere SelectStmtGroup SelectStmtOrder
	SelectStmtLimit SelectStmtOffset
	{
		x := yylex.(*lexer)
		n := len(x.agg)
		join := &joinRset{sources: $5}
		if o := $7; o != nil {
			o := o.([]interface{})
			join.typ = o[0].(int)
			join.sources = append(join.sources, o[1].([]interface{}))
			join.on = o[2].(expression)
		}
		$$ = &selectStmt{
			distinct:      $2.(bool),
			flds:          $3.([]*fld),
			from:          join,
			hasAggregates: x.agg[n-1],
			where:         $8.(*whereRset),
			group:         $9.(*groupByRset),
			order:         $10.(*orderByRset),
			limit:         $11.(*limitRset),
			offset:        $12.(*offsetRset),
		}
		x.agg = x.agg[:n-1]
	}

SelectStmtLimit:
	{
		$$ = (*limitRset)(nil)
	}
|	"LIMIT" Expression
	{
		$$ = &limitRset{expr: expr($2)}
	}

SelectStmtOffset:
	{
		$$ = (*offsetRset)(nil)
	}
|	"OFFSET" Expression
	{
		$$ = &offsetRset{expr: expr($2)}
	}

SelectStmtDistinct:
	/* EMPTY */
	{
		$$ = false
	}
|	"DISTINCT"
	{
		$$ = true
	}

SelectStmtFieldList:
	'*'
	{
		$$ = []*fld{}
	}
|	FieldList
	{
		$$ = $1
	}
|	FieldList ','
	{
		$$ = $1
	}

SelectStmtWhere:
	/* EMPTY */
	{
		$$ = (*whereRset)(nil)
	}
|	WhereClause

SelectStmtGroup:
	/* EMPTY */
	{
		$$ = (*groupByRset)(nil)
	}
|	GroupByClause

SelectStmtOrder:
	/* EMPTY */
	{
		$$ = (*orderByRset)(nil)
	}
|	OrderBy

Slice:
	'[' ':' ']'
	{
		$$ = [2]*expression{nil, nil}
	}
|	'[' ':' Expression ']'
	{
		hi := expr($3)
		$$ = [2]*expression{nil, &hi}
	}
|	'[' Expression ':' ']'
	{
		lo := expr($2)
		$$ = [2]*expression{&lo, nil}
	}
|	'[' Expression ':' Expression ']'
	{
		lo := expr($2)
		hi := expr($4)
		$$ = [2]*expression{&lo, &hi}
	}

Statement:
	EmptyStmt
|	AlterTableStmt
|	BeginTransactionStmt
|	CommitStmt
|	CreateIndexStmt
|	CreateTableStmt
|	DeleteFromStmt
|	DropIndexStmt
|	DropTableStmt
|	ExplainStmt
|	InsertIntoStmt
|	RollbackStmt
|	SelectStmt
|	TruncateTableStmt
|	UpdateStmt

StatementList:
	Statement
	{
		if $1 != nil {
			yylex.(*lexer).list = []stmt{$1.(stmt)}
		}
	}
|	StatementList ';' Statement
	{
		if $3 != nil {
			yylex.(*lexer).list = append(yylex.(*lexer).list, $3.(stmt))
		}
	}

TableName:
	identifier

Term:
	Factor
|	Term logAnd Factor
	{
		var err error
		if $$, err = newBinaryOperation(andand, $1, $3); err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}

logAnd:
	"&&"
	{
	}
|	"AND"
	{
	}

TruncateTableStmt:
	"TRUNCATE" "TABLE" TableName
	{
		$$ = &truncateTableStmt{tableName: $3.(string)}
	}

Type:
	"bigint"
|	"bigrat"
|	"blob"
|	"bool"
|	"byte"
|	"complex128"
|	"complex64"
|	"duration"
|	"float"
|	"float32"
|	"float64"
|	"int"
|	"int16"
|	"int32"
|	"int64"
|	"int8"
|	"rune"
|	"string"
|	"time"
|	"uint"
|	"uint16"
|	"uint32"
|	"uint64"
|	"uint8"

UpdateStmt:
	"UPDATE" TableName SetOpt AssignmentList UpdateStmt1
	{
		var expr expression
		if w := $5; w != nil {
			expr = w.(*whereRset).expr
		}
		$$ = &updateStmt{tableName: $2.(string), list: $4.([]assignment), where: expr}

		if yylex.(*lexer).root {
			break
		}

		if isSystemName[$2.(string)] {
			yylex.(*lexer).err("name is used for system tables: %s", $2.(string))
			return 1
		}
	}

UpdateStmt1:
	/* EMPTY */
	{
		$$ = nil
	}
|	WhereClause

UnaryExpr:
	PrimaryExpression
|	'^'  PrimaryExpression
	{
		var err error
		$$, err = newUnaryOperation('^', $2)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	'!' PrimaryExpression
	{
		var err error
		$$, err = newUnaryOperation('!', $2)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	'-' PrimaryExpression
	{
		var err error
		$$, err = newUnaryOperation('-', $2)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}
|	'+' PrimaryExpression
	{
		var err error
		$$, err = newUnaryOperation('+', $2)
		if err != nil {
			yylex.(*lexer).err("%v", err)
			return 1
		}
	}

WhereClause:
	"WHERE" Expression
	{
		$$ = &whereRset{expr: expr($2)}
	}


SetOpt:
	{
	}
|	"SET"
	{
	}

CommaOpt:
	{
	}
|	','
	{
	}

%%

func expr(v interface{}) expression {
	e := v.(expression)
	for {
		x, ok := e.(*pexpr)
		if !ok {
			return e
		}
		e = x.expr
	}
}
