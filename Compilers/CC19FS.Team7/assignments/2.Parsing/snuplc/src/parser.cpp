//------------------------------------------------------------------------------
/// @brief SnuPL/1 parser
/// @author Bernhard Egger <bernhard@csap.snu.ac.kr>
/// @section changelog Change Log
/// 2012/09/14 Bernhard Egger created
/// 2013/03/07 Bernhard Egger adapted to SnuPL/0
/// 2014/11/04 Bernhard Egger maintain unary '+' signs in the AST
/// 2016/04/01 Bernhard Egger adapted to SnuPL/1 (this is not a joke)
/// 2019/09/15 Bernhard Egger added support for constant expressions
/// 2019/09/20 Bernhard Egger assignment 2: parser for SnuPL/-1
///
/// @section license_section License
/// Copyright (c) 2012-2019, Computer Systems and Platforms Laboratory, SNU
/// All rights reserved.
///
/// Redistribution and use in source and binary forms,  with or without modifi-
/// cation, are permitted provided that the following conditions are met:
///
/// - Redistributions of source code must retain the above copyright notice,
///   this list of conditions and the following disclaimer.
/// - Redistributions in binary form must reproduce the above copyright notice,
///   this list of conditions and the following disclaimer in the documentation
///   and/or other materials provided with the distribution.
///
/// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
/// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO,  THE
/// IMPLIED WARRANTIES OF MERCHANTABILITY  AND FITNESS FOR A PARTICULAR PURPOSE
/// ARE DISCLAIMED. IN NO  EVENT SHALL THE COPYRIGHT HOLDER  OR CONTRIBUTORS BE
/// LIABLE FOR ANY DIRECT,  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSE-
/// QUENTIAL DAMAGES (INCLUDING,  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
/// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
/// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT
/// LIABILITY,  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY  WAY
/// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
/// DAMAGE.
//------------------------------------------------------------------------------

#include <limits.h>
#include <cassert>
#include <errno.h>
#include <cstdlib>
#include <vector>
#include <iostream>
#include <exception>

#include "parser.h"
using namespace std;

//------------------------------------------------------------------------------
// EBNF of SnuPL/-1
//   module        =  statSequence "."
//   digit         =  "0".."9".
//   letter        =  "a".."z".
//   factOp        =  "*" | "/".
//   termOp        =  "+" | "-".
//   relOp         =  "=" | "#".
//   factor        =  digit | "(" expression ")".
//   term          =  factor { factOp factor }.
//   simpleexpr    =  term { termOp term }.
//   expression    =  simpleexpr [ relOp simpleexpr ].
//   assignment    =  letter ":=" expression.
//   statement     =  assignment.
//   statSequence  =  [ statement { ";" statement } ].
//   whitespace    =  { " " | \n }+.


//------------------------------------------------------------------------------
// CParser
//
CParser::CParser(CScanner *scanner)
{
  _scanner = scanner;
  _module = NULL;
}

CAstNode* CParser::Parse(void)
{
  _abort = false;

  if (_module != NULL) { delete _module; _module = NULL; }

  try {
    if (_scanner != NULL) _module = module();

    if (_module != NULL) {
      CToken t;
      string msg;
      // TODO (phase 3)
      // if (!_module->TypeCheck(&t, &msg)) SetError(t, msg);
    }
  } catch (...) {
    _module = NULL;
  }

  return _module;
}

const CToken* CParser::GetErrorToken(void) const
{
  if (_abort) return &_error_token;
  else return NULL;
}

string CParser::GetErrorMessage(void) const
{
  if (_abort) return _message;
  else return "";
}

void CParser::SetError(CToken t, const string message)
{
  _error_token = t;
  _message = message;
  _abort = true;
  throw message;
}

bool CParser::Consume(EToken type, CToken *token)
{
  if (_abort) return false;

  CToken t = _scanner->Get();

  if (t.GetType() != type) {
    SetError(t, "expected '" + CToken::Name(type) + "', got '" +
             t.GetName() + "'");
  }

  if (token != NULL) *token = t;

  return t.GetType() == type;
}

pair<CToken*, const CSymbol*> CParser::GetIdentTokenAndSym(CAstScope *s) {
  CToken t;
  CSymtab *st = s->GetSymbolTable();

  Consume(tIdent, &t);

  const CSymbol *sym = st->FindSymbol(t.GetValue(), sLocal);

  if (sym == NULL)
    SetError(t, "undefined identifier");
  
  return make_pair(&t, sym);
}

void CParser::InitSymbolTable(CSymtab *st)
{
  CTypeManager *tm = CTypeManager::Get();

  // TODO (phase 2)
  // add predefined functions here
  CSymbol *s;
  CSymProc *f;

  s = new CSymbol("main", stReserved, tm->GetNull());
  st->AddSymbol(s);

  f = new CSymProc("WriteInt", tm->GetNull());
  f->AddParam(new CSymParam(0/* 0-th param */, "i", tm->GetInt()));
  st->AddSymbol(f);

  f = new CSymProc("WriteChar", tm->GetNull());
  f->AddParam(new CSymParam(0, "c", tm->GetChar()));
  st->AddSymbol(f);

  f = new CSymProc("WriteStr", tm->GetNull());
  // First arg of GetArray is the number of elements in 
  // the array. CArrayType::OPEN signifies the open array.
  // The return type is Pointer because we're going to implement
  // call by reference for arrays.
  f->AddParam(new CSymParam(0, "string", tm->GetPointer(tm->GetArray(CArrayType::OPEN, tm->GetChar()))));
  st->AddSymbol(f);

  f = new CSymProc("WriteLn", tm->GetNull());
  st->AddSymbol(f);

  f = new CSymProc("DIM", tm->GetInt());
  // The void pointer!
  f->AddParam(new CSymParam(0, "array", tm->GetVoidPtr()));
  f->AddParam(new CSymParam(1, "dim", tm->GetInt()));
  st->AddSymbol(f);

  f = new CSymProc("DOFS", tm->GetInt());
  f->AddParam(new CSymParam(0, "array", tm->GetVoidPtr()));
  st->AddSymbol(f);
}

CAstModule* CParser::module(void)
{
  //
  // module ::= statSequence  ".".
  //
  CToken mt, t;
  string id;
  CAstModule *m;
  CAstStatement *statseq = NULL;

  Consume(tModule, &mt);
  Consume(tIdent, &t);
  id = t.GetValue();
  Consume(tSemicolon);

  m = new CAstModule(mt, id);

  InitSymbolTable(m->GetSymbolTable());

  constDeclaration(m);
  varDeclaration(m);
  subroutineDecl(m);
  statseq = statSequence(m);

  Consume(tEnd);
  Consume(tIdent, &t);
  Consume(tDot);

  m->SetStatementSequence(statseq);

  if (t.GetValue() != id)
    throw new string("module identifier mismatch");

  return m;
}

void CParser::constDeclaration(CAstScope *s)
{
  if (!_scanner->Peek().GetType() != tConstDecl)  
    return;

  Consume(tConstDecl);
  constDeclSequence(s);
  // if (not const) do nothing;
  // else do things;
}

void CParser::constDeclSequence(CAstScope *s)
{
  do {
    constDecl(s);
    Consume(tSemicolon);
  } while (_scanner->Peek().GetType() != tVarDecl &&
           _scanner->Peek().GetType() != tProcedure &&
           _scanner->Peek().GetType() != tFunction &&
           _scanner->Peek().GetType() != tBegin);
  // do {
  //   do {
      
  //   } while (true);
 
  // ...

  // } while (true);
}

void CParser::constDecl(CAstScope *s)
{
  // varDecl()
}

void CParser::varDecl(CAstScope *s)
{
  // vector<string>* identifiers = new vector<string>();
  // CToken t;
  // Consume(tIdent, &t);
  // identifiers.push_back(t.GetValue());
  // do {

  // } while (_scanner->Peek().GetType() != tColon)
}

CAstStatement* CParser::statSequence(CAstScope *s)
{
  //
  // statSequence ::= [ statement { ";" statement } ].
  // statement ::= assignment.
  //
  // FIRST(statSequence) = { tLetter }
  // FOLLOW(statSequence) = { tDot }
  //
  // FIRST(statement) = { tLetter }
  // FOLLOW(statement) = { tSemicolon, tDot }
  //

  // The linking of statement sequences is a bit akward here because
  // we implement statSequence as a loop and not recursively.
  // We keep a 'head' that points to the first statement and is finally
  // returned at the end of the function. Head can be NULL if no statement
  // is present. 
  // In the loop, we track the end of the linked list using 'tail' and
  // attach new statements to that tail.
  CAstStatement *head = NULL;

  if (_scanner->Peek().GetType() != tDot) {
    CAstStatement *tail = NULL;

    do {
      CAstStatement *st = NULL;

      st = statement(s);

      assert(st != NULL);
      if (head == NULL) head = st;
      else tail->SetNext(st);
      tail = st;

      if (_scanner->Peek().GetType() == tDot) break;

      Consume(tSemicolon);
    } while (!_abort);
  }

  return head;
}

CAstStatement* CParser::statement(CAstScope *s)
{
  //
  // statement ::= assignment 
  //             | subroutineCall 
  //             | ifStatement 
  //             | whileStatement
  //             | returnStatement.
  //
  CToken t;
  pair<CToken*, const CSymbol*> toksym;
  switch (_scanner->Peek().GetType()) {
    case tIdent:
      toksym = GetIdentTokenAndSym(s);
      if (_scanner->Peek().GetType() == tLParens)
        return new CAstStatCall(t, subroutineCall(s, toksym.first, toksym.second));
      else 
        return assignment(s, toksym.first, toksym.second);
    case tIf:
      return ifStatement(s);
    case tWhile:
      return whileStatement(s);
    case tReturn:
      return returnStatement(s);
    default:
      SetError(_scanner->Peek(), "tIdent | tIf | tWhile | tReturn expected");
      break;
  }
}

CAstStatReturn* CParser::returnStatement(CAstScope *s)
{
  //
  // returnStatement ::= "return" [ expression ].
  //
  CToken t;
  Consume(tReturn, &t);
  return new CAstStatReturn(t, s, expression(s));
}

CAstStatWhile* CParser::whileStatement(CAstScope *s)
{
  //
  // whileStatement ::= "while" "(" expression ")" "do" statSequence "end".
  //
  CToken t;
  Consume(tWhile, &t);

  Consume(tLParens);
  CAstExpression *condition = expression(s);
  Consume(tRParens);

  Consume(tDo);
  CAstStatement *body = statSequence(s);
  Consume(tEnd);
  
  return new CAstStatWhile(t, condition, body);
}

CAstStatIf* CParser::ifStatement(CAstScope *s) 
{
  //
  // ifStatement ::= "if" "(" expression ")" "then" statSequence
  //                [ "else" statSequence ] "end".

  CToken t;
  Consume(tIf, &t);
  Consume(tLParens);
  CAstExpression *cond = expression(s);
  Consume(tRParens);
  Consume(tThen);
  CAstStatement *ifBody = statSequence(s);

  CAstStatement *elseBody = NULL;
  if (_scanner->Peek().GetType() == tElse) {
    Consume(tElse);
    elseBody = statSequence(s);
  }

  Consume(tEnd);
  return new CAstStatIf(t, cond, ifBody, elseBody);
}

CAstFunctionCall* CParser::subroutineCall(CAstScope *s, CToken *t, const CSymbol* sym)
{
  //
  // subroutineCall ::= ident "(" [ expression { "," expression } ] ")".
  //

  Consume(tLParens);

  if (sym->GetSymbolType() != stProcedure)
    SetError(t, "invalid procedure/function identifier");

  const CSymProc *symProc = dynamic_cast<const CSymProc*>(sym);
  CAstFunctionCall *fc = new CAstFunctionCall(t, symProc);
  
  return NULL;
}

CAstStatAssign* CParser::assignment(CAstScope *s, CToken *t, const CSymbol *sym)
{
  //
  // assignment ::= qualident ":=" expression.
  //

  CAstDesignator *lhs = qualident(s, t, sym);
  Consume(tAssign, t);

  CAstExpression *rhs = expression(s);

  return new CAstStatAssign(t, lhs, rhs);
}

CAstExpression* CParser::expression(CAstScope* s)
{
  //
  // expression ::= simpleexpr [ relOp simpleexpr ].
  //

  CToken t;
  EOperation relop;
  CAstExpression *left = NULL, *right = NULL;

  left = simpleexpr(s);

  if (_scanner->Peek().GetType() == tRelOp) {
    Consume(tRelOp, &t);
    right = simpleexpr(s);

    if (t.GetValue() == "=")       relop = opEqual;
    else if (t.GetValue() == "#")  relop = opNotEqual;
    else if (t.GetValue() == "<")  relop = opLessThan;
    else if (t.GetValue() == "<=") relop = opLessEqual;
    else if (t.GetValue() == ">")  relop = opBiggerThan;
    else if (t.GetValue() == ">=") relop = opBiggerEqual;
    else SetError(t, "invalid relation.");

    return new CAstBinaryOp(t, relop, left, right);
  } else {
    return left;
  }
}



CAstExpression* CParser::simpleexpr(CAstScope *s)
{
  //
  // simpleexpr ::= ["+"|"-"] term { termOp term }.
  //

  CAstExpression *n = NULL;

  CToken *unary = NULL;
  if (_scanner->Peek().GetType() == tPlusMinus)
    Consume(tPlusMinus, unary);

  n = term(s);

  EToken tt = _scanner->Peek().GetType();
  while (!_abort && (tt == tPlusMinus || tt == tOr))  {
    CToken t;
    CAstExpression *l = n, *r;

    Consume(tPlusMinus, &t);

    r = term(s);

    EOperation opT;
    string v = t.GetValue();
    if (v == "+") opT = opAdd;
    else if (v == "-") opT = opSub;
    else if (v == "||") opT = opOr;
    else SetError(t, "termOp expected");

    n = new CAstBinaryOp(t, t.GetValue() == "+" ? opAdd : opSub, l, r);

    tt = _scanner->Peek().GetType();
  }

  if (unary != NULL) 
    n = new CAstUnaryOp(unary, unary->GetValue() == "+" ? opPos : opNeg, n);

  return n;
}

CAstExpression* CParser::term(CAstScope *s)
{
  //
  // term ::= factor { ("*"|"/") factor }.
  //
  CAstExpression *n = NULL;

  n = factor(s);

  EToken tt = _scanner->Peek().GetType();

  while (!_abort && (tt == tMulDiv || tt == tAnd)) {
    CToken t;
    CAstExpression *l = n, *r;

    Consume(tt, &t);

    r = factor(s);

    EOperation opT;
    string v = t.GetValue();
    if (v == "*") opT = opMul;
    else if (v == "/") opT = opDiv;
    else if (v == "&&") opT = opAnd;
    else SetError(t, "factOp expected");

    n = new CAstBinaryOp(t, opT, l, r);

    tt = _scanner->Peek().GetType();
  }

  return n;
}

CAstExpression* CParser::factor(CAstScope *s)
{
  //
  // factor ::= qualident
  //          | number
  //          | boolean
  //          | char
  //          | string
  //          | "(" expression ")"
  //          | subroutineCall
  //          | "!" factor
  //

  CToken t;
  string identifier;
  CAstExpression *exp;
  pair<CToken*, const CSymbol*> toksym;

  if (_abort) return NULL;

  switch (_scanner->Peek().GetType()) {
    case tIdent:
      toksym = GetIdentTokenAndSym(s);
      switch (_scanner->Peek().GetType()) {
        case tLParens:
          return subroutineCall(s, toksym.first, toksym.second);
        default:
          return qualident(s, toksym.first, toksym.second);
      }
    case tNumber:
      return number();
    case tBoolConst:
      return boolean();
    case tCharConst:
      return characterConst();  
    case tStringConst:
      return stringConst(s);
    case tLParens:
      Consume(tLParens);
      exp = expression(s);
      Consume(tRParens);
      exp->SetParenthesized(true);
      return exp;
    case tNot:
      Consume(tNot);
      exp = factor(s);
      return new CAstUnaryOp(t, opNot, exp);
    default:
      SetError(_scanner->Peek(), "factor expected");
      return NULL;
  }
}

CAstDesignator* CParser::qualident(CAstScope *s, CToken *t, const CSymbol *sym)
{
  //
  // qualident ::= ident { "[" simpleexpr "]" }.
  //

  if (_scanner->Peek().GetType() == tLBrak) {
    CAstArrayDesignator *arrDesig = new CAstArrayDesignator(t, sym);

    while (!_abort && _scanner->Peek().GetType() == tLBrak) {
      Consume(tLBrak);
      CAstExpression *idx = simpleexpr(s);
      Consume(tRBrak);
      arrDesig->AddIndex(idx);
    }

    arrDesig->IndicesComplete();
    return arrDesig;
  }
  
  return new CAstDesignator(t, sym);
}

CAstType* CParser::type(CAstScope *s, const bool formalParam)
{
  //
  // type ::= basetype | type "[" [ simpleexpr ] "]".
  // 
  // To remove left recursion, practical implementation was 
  // modified to:
  // type := basetype arraytype.
  //
  CToken t;
  CTypeManager *tm = CTypeManager::Get();
  const CType* basetype;

  switch (_scanner->Peek().GetType()) {
    case tBoolean:
      Consume(tBoolean, &t);
      basetype = tm->GetBool();
      break;
    case tChar:
      Consume(tChar, &t);
      basetype = tm->GetChar();
      break;
    case tInteger:
      Consume(tInteger, &t);
      basetype = tm->GetInt();
      break;
    default:
      Consume(_scanner->Peek().GetType(), &t);
      SetError(t, "expected boolean, char, or integer");
  }
  const CType* type = arraytype(s, basetype, formalParam);
  
  return new CAstType(t, type);

  // handle formalParam vs. global scope decl.
}

//
// This needs some discussion.
// CAstExpression::Evaluate is not implemented yet, and returns NULL as of now.
// 
// UPDATE: Evaluate in constant simpleexpr only accept numbers or other 
// constants and operations among them.
// Evaluate will be implemented in Phase 3.
//
const CType* CParser::arraytype(CAstScope *s, const CType* t, const bool formalParam)
{
  //
  // arraytype ::= "[" expression "]" arraytype.
  //
  if (_abort || _scanner->Peek().GetType() != tLBrak)
    return t;

  CToken token;
  CTypeManager *tm = CTypeManager::Get();
  int length;

  Consume(tLBrak, &token);

  EToken tt = _scanner->Peek().GetType();
  if (!formalParam && tt == tRBrak) 
    SetError(_scanner->Peek(), "open arrays are not allowed in const/var declaration");
  else if (tt == tRBrak) 
    length = CArrayType::OPEN;
  else {
    CAstExpression *exp = simpleexpr(s);
    if (!tm->GetInt()->Match(exp->GetType())) {
      SetError(token, "array length simpleexpr must be of integer type.");
    }
    
    const CDataInitInteger *dataInitInt = dynamic_cast<const CDataInitInteger*>(exp->Evaluate());
    // TODO: set length to dataInitInt->GetData() at Phase 3.
    // length = dataInitInt->GetData();

    // For now, we can set length to arbitrary integers
    length = 1;
  }

  Consume(tRBrak);
  return tm->GetArray(length, arraytype(s, t, formalParam));
}

CAstConstant* CParser::boolean(void)
{
  //
  // boolean ::= "true" | "false"
  //

  CToken t;

  Consume(tBoolConst, &t);
  string value = t.GetValue();
  
  if (value == "true")
    return new CAstConstant(t, CTypeManager::Get()->GetBool(), true);
  else if (value == "false")
    return new CAstConstant(t, CTypeManager::Get()->GetBool(), false);
  else {
    SetError(t, "scanner error: tBoolConst holds incorrect value");
    return NULL;
  }
}

CAstConstant* CParser::number(void)
{
  //
  // number ::= digit { digit }.
  //

  CToken t;

  Consume(tNumber, &t);

  errno = 0;
  long long v = strtoll(t.GetValue().c_str(), NULL, 10);
  if (errno != 0) SetError(t, "invalid number.");

  return new CAstConstant(t, CTypeManager::Get()->GetInt(), v);
}

CAstStringConstant* CParser::stringConst(CAstScope *s)
{
  //
  // string ::= '"' { character } '"'
  //

  CToken t;
  Consume(tStringConst, &t);
  return new CAstStringConstant(t, t.GetValue(), s);
}

CAstConstant* CParser::characterConst(void)
{
  //
  // char ::= "'" character "'"
  //

  CToken t;

  Consume(tCharConst, &t);

  errno = 0;
  char v = CToken::unescape(t.GetValue()).at(0);
  if (errno != 0) SetError(t, "invalid number.");

  return new CAstConstant(t, CTypeManager::Get()->GetChar(), v);
}



// CAstDesignator* CParser::ident(CAstScope *s)
// {
//   //
//   // ident := letter { letter | digit }.
//   //

//   CToken t;
//   CSymtab *st = s->GetSymbolTable();

//   Consume(tIdent, &t);

//   // check if symbol exists in (local) symbol table
//   const CSymbol *sym = st->FindSymbol(t.GetValue(), sLocal);

//   if (sym == NULL) {
//     // if not, create one and add it to the symbol table
//     CSymbol *nsym = s->CreateVar(t.GetValue(), CTypeManager::Get()->GetInt());
//     st->AddSymbol(nsym);

//     sym = nsym;
//   }

//   return new CAstDesignator(t, sym);
// }


