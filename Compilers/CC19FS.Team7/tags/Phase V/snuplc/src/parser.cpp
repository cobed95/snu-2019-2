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
      if (!_module->TypeCheck(&t, &msg)) {
        SetError(t, msg);
      }
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

void CParser::InitSymbolTable(CSymtab *st)
{
  CTypeManager *tm = CTypeManager::Get();

  // TODO (phase 2)
  // add predefined functions here
  CSymbol *s;
  CSymProc *f;

  s = new CSymbol("main", stReserved, tm->GetNull());
  st->AddSymbol(s);

  f = new CSymProc("ReadInt", tm->GetInt());
  st->AddSymbol(f);

  f = new CSymProc("WriteInt", tm->GetNull());
  f->AddParam(new CSymParam(0/* 0-th param */, "i", tm->GetInt()));
  st->AddSymbol(f);

  f = new CSymProc("WriteChar", tm->GetNull());
  f->AddParam(new CSymParam(0, "c", tm->GetChar()));
  st->AddSymbol(f);

  f = new CSymProc("WriteStr", tm->GetNull());
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
  // module ::= "module" ident ";"
  //            constDeclaration varDeclaration { subroutineDecl }
  //            "begin" statSequence  "end" ident ".".
  //

  CToken mt, t;
  string id;
  CAstModule *m = NULL;
  CAstStatement *statseq = NULL;

  Consume(tModule, &mt);
  Consume(tIdent, &t);
  id = t.GetValue();
  Consume(tSemicolon);

  m = new CAstModule(mt, id);

  InitSymbolTable(m->GetSymbolTable());

  constDeclaration(m);
  varDeclaration(m);
  EToken tt = _scanner->Peek().GetType();
  while (tt == tProcedure || tt == tFunction) {
    subroutineDecl(m);
    tt = _scanner->Peek().GetType();
  }
  
  if (_scanner->Peek().GetType() != tBegin) {
    SetError(_scanner->Peek(), "no statement");
    return m;
  }
  Consume(tBegin);
  statseq = statSequence(m);

  Consume(tEnd);
  Consume(tIdent, &t);
  Consume(tDot);

  m->SetStatementSequence(statseq);

  if (t.GetValue() != id)
    SetError(t, "module identifier mismatch");

  return m;
}

//
// FIRST(constDeclaration) = {tConst, eps}
// FIRST(constDeclSequence) = {tIdent}
// FIRST(constDecl) = {tIdent}
// FOLLOW(constDeclaration) = {tVarDecl, tBegin, tProcedure, tFunction}
// FOLLOW(constDeclSequence) = {tVarDecl, tBegin, tProcedure, tFunction}
// FOLLOW(constDecl) = {tSemicolon}
//
void CParser::constDeclaration(CAstScope *s) {
  // 
  // constDeclaration -> [tConstDecl constDeclSequence]
  // 

  if (_scanner->Peek().GetType() != tConstDecl) return;
  Consume(tConstDecl);
  constDeclSequence(s);
  return;
}

void CParser::constDeclSequence(CAstScope *s) {
  // 
  // constDeclSequence -> constDecl tSemicolon {constDecl tSemicolon}  
  // 

  CToken t;
  t = _scanner->Peek();
  do {
    constDecl(s);
    Consume(tSemicolon);
    t = _scanner->Peek();
  } while (t.GetType() != tVarDecl && t.GetType() != tBegin && t.GetType() != tProcedure && t.GetType() != tFunction);

  return;
}

void CParser::constDecl(CAstScope *s) {
  // 
  // constDecl -> varDecl tRelOp(=) expression
  // varDecl -> tIdent {tComma tIdent} tColon type
  // CTypeManager *CTM = CTypeManager::Get();
  // 
  vector<CToken> v;                           //start varDecl
  CToken iD;
  Consume(tIdent, &iD);
  v.push_back(iD);
  while (!_abort && _scanner->Peek().GetType() != tColon) {
    Consume(tComma);
    Consume(tIdent, &iD);
    v.push_back(iD);
  }

  Consume(tColon);

  CAstType *tp;
  tp = type(s, false, true);                        //end varDecl

  CToken t;
  Consume(tRelOp, &t);
  
  if (t.GetValue() != "=") {
    SetError(t, "Expected constDecl");
  }
  
  CAstExpression *es = expression(s);
  const CType *etype = es -> GetType();

  CSymtab *sTab = s->GetSymbolTable();
  CSymbol *sym = NULL;
  string name;
  CToken temp;
  const CType *typeOfConst = tp -> GetType();

  if (!typeOfConst -> Match(etype)) {
    SetError(t, "Type mismatch in constant expression");
  }

  CToken errToken;
  string msg;
  if (!es->TypeCheck(&errToken, &msg)) {
    SetError(t, "TypeCheck for constant expression failed");
  }
  const CDataInitializer *di = es -> Evaluate();
  if (di == NULL) SetError(t, "Cannot evaluate constant expression");

  if (typeOfConst->IsArray()) {
  	const CArrayType *constToArray = dynamic_cast<const CArrayType*>(typeOfConst);
    if (!constToArray->GetInnerType()->IsChar()) {
		  SetError(tp->GetToken(), "Array constants are not supported with the exception of constant character arrays (i.e., strings)");
	  }	
  }

  if (etype->IsArray()) {
  	const CArrayType *etypeToArray = dynamic_cast<const CArrayType*>(etype);
    if (!etypeToArray->GetInnerType()->IsChar()) {
      SetError(es->GetToken(), "Array constants are not supported with the exception of constant character arrays (i.e., strings)");
    }
  }
 
  while (!_abort && !v.empty()) {
    temp = v[v.size() - 1];
    v.pop_back();
    name = temp.GetValue(); 
    //sym = s->CreateConst(name, typeOfConst, di);    //might raise error
    //const CDataInitializer *dataInit = dynamic_cast<const CDataInitializer*>(new const CDataInitInteger(1));
    sym = s->CreateConst(name, typeOfConst, di);      //might raise error
    //sym->SetDataType(typeOfConst);
    const CDataInitInteger *test1 = static_cast<const CDataInitInteger*>(sym->GetData());
    if (!sTab->AddSymbol(sym)) SetError(temp, "Re-defined variable");
  }

  return;
}

//
// FIRST(varDeclaration) = {tVarDecl, eps}
// FIRST(varDeclSequence) = {tIdent}
// FIRST(varDecl) = {tIdent}
// FOLLOW(varDeclaration) = {tBegin, tProcedure, tFunction}
// FOLLOW(varDeclSequence) = {tSemicolon, tRParens}
//
void CParser::varDeclaration(CAstScope *s) {
  //varDeclaration -> tVarDecl varDeclSequence tSemicolon
  if (_scanner->Peek().GetType() != tVarDecl) return;
  Consume(tVarDecl);
  varDeclSequence(s, false);
  return;
}

void CParser::varDeclSequence(CAstScope *s, bool formalParam)
{
  varDecl(s, formalParam);
  while (_scanner->Peek().GetType() == tSemicolon) {
    Consume(tSemicolon);
    if (!formalParam && _scanner->Peek().GetType() != tIdent)
      break;
    varDecl(s, formalParam);
  } 
}

void CParser::varDecl(CAstScope *s, bool formalParam)
{
  vector<CToken> v;
  CToken t;
  Consume(tIdent, &t);
  v.push_back(t);
  while (_scanner->Peek().GetType() == tComma) {
    Consume(tComma);
    Consume(tIdent, &t);
    v.push_back(t);
  }

  Consume(tColon);
  CAstType * tp = type(s, formalParam);

  CSymbol *sym = NULL;
  CSymParam *paramsym = NULL;
  CSymProc *par = NULL;
  CSymtab *sTab = s->GetSymbolTable();
  CAstProcedure *cap = NULL;

  string name;
  CToken temp;
  const CType *typeOfVar = tp -> GetType();
  if (formalParam) {
    cap = dynamic_cast<CAstProcedure*>(s);
    par = cap->GetSymbol();
    for (int i = 0; i < v.size(); i++) {
      if (_abort) break;  

      temp = v[i];
      name = temp.GetValue();

      paramsym = new CSymParam(par->GetNParams(), name, typeOfVar);
      paramsym->SetDataType(typeOfVar);
      par->AddParam(paramsym);
      if (!sTab->AddSymbol(paramsym))
        SetError(temp, "Re-defined parameter");
    }
  } else {
    for (int i = 0; i < v.size(); i++) {
      if (_abort) break;

      temp = v[i];
      name = temp.GetValue();
      sym = s->CreateVar(name, typeOfVar);
      sym->SetDataType(typeOfVar);
      if (!sTab->AddSymbol(sym))
        SetError(temp, "Re-defined parameter");
    }
  }

  // while (!_abort && !v.empty()) {
  //   cout << "v.size: " << v.size() << endl;
  //   temp = v[v.size() - 1];
  //   v.pop_back();
  //   name = temp.GetValue();
  //   if (formalParam) {
  //     cap = dynamic_cast<CAstProcedure*>(s);
  //     par = cap->GetSymbol();
  //     paramsym = new CSymParam(v.size()+1, name, typeOfVar);
  //     paramsym->SetDataType(typeOfVar);
  //     par->AddParam(paramsym);
  //     if (!sTab->AddSymbol(paramsym)) SetError(temp, "Re-defined parameter");
  //   } else {
  //     sym = s->CreateVar(name, typeOfVar);
  //     sym->SetDataType(typeOfVar);
  //     if (!sTab->AddSymbol(sym)) SetError(temp, "Re-defined variable");
  //   }
  // }
}

CAstProcedure* CParser::subroutineDecl(CAstScope *s) {
  // 
  // subroutineDecl -> (procedureDecl | functionDecl) subroutineBody tIdent tSemicolon
  // 

  CTypeManager *CTM = CTypeManager::Get();
  CAstProcedure *subr = NULL;
  CSymProc *sym = NULL;
  CToken stID, funcOrProc;
  string id;
  funcOrProc = _scanner->Peek();
  switch(funcOrProc.GetType()) {
    case tProcedure:
      Consume(tProcedure);
      break;
    case tFunction:
      Consume(tFunction);
      break;
    default:
      SetError(funcOrProc, "Expected subroutineDecl");
      break;
  }

  Consume(tIdent, &stID);
  id = stID.GetValue();

  sym = new CSymProc(id, CTM->GetNull());
  subr = new CAstProcedure(funcOrProc, id, s, sym);
  
  if (_scanner->Peek().GetType() == tLParens) {                            //formalParam
    Consume(tLParens);
    if (_scanner->Peek().GetType() != tRParens) varDeclSequence(subr, true);  
    Consume(tRParens);
  }

  if (funcOrProc.GetType() == tFunction) {
    Consume(tColon);
    sym->SetDataType(type(subr, true)->GetType());
  } else {
    sym->SetDataType(CTM->GetNull());
  }

  Consume(tSemicolon);                                                   //end of (procedureDecl | functionDecl)
  CSymtab *par_st = s->GetSymbolTable();
  par_st->AddSymbol(sym);

  constDeclaration(subr);                                                //start subroutineBody
  varDeclaration(subr);

  Consume(tBegin);
  CAstStatement *statseq = statSequence(subr);
  subr->SetStatementSequence(statseq);
  
  Consume(tEnd);

  CToken eID;
  Consume(tIdent, &eID);
  if (id != eID.GetValue()) SetError(eID, "Subroutine name mismatch");
  Consume(tSemicolon);

  return subr;
}

CAstStatement* CParser::statSequence(CAstScope *s)
{
  //
  // statSequence ::= [ statement { ";" statement } ].
  // statement ::= assignment.
  //
  // FIRST(statSequence) = { tLetter }
  // FOLLOW(statSequence) = { tElse, tEnd }
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

  if (_scanner->Peek().GetType() != tElse && _scanner->Peek().GetType() != tEnd) {
    CAstStatement *tail = NULL;

    do {
      CAstStatement *st = NULL;

      st = statement(s);

      assert(st != NULL);
      if (head == NULL) head = st;
      else tail->SetNext(st);
      tail = st;

      EToken tt = _scanner->Peek().GetType();
      if (tt == tEnd || tt == tElse) break;

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
  const CSymbol *sym;
  switch (_scanner->Peek().GetType()) {
    case tIdent:
      Consume(tIdent, &t);
      sym = s->GetSymbolTable()->FindSymbol(t.GetValue());
      if (sym == NULL) {
        SetError(t, "undefined identifier");
        return NULL;  
      }
      
      if (_scanner->Peek().GetType() == tLParens)
        return new CAstStatCall(t, subroutineCall(s, &t, sym));
      else
        return assignment(s, &t, sym);
    case tIf:
      sym = NULL;
      return ifStatement(s);
    case tWhile:
      sym = NULL;
      return whileStatement(s);
    case tReturn:
      sym = NULL;
      return returnStatement(s);
    default:
      sym = NULL;
      SetError(_scanner->Peek(), "tIdent | tIf | tWhile | tReturn expected");
      return NULL;
  }
}

CAstStatReturn* CParser::returnStatement(CAstScope *s)
{
  //
  // returnStatement ::= "return" [ expression ].
  //
  CToken t;
  Consume(tReturn, &t);
  switch (_scanner->Peek().GetType()) {
    case tPlusMinus:
    case tIdent:
    case tNumber:
    case tBoolConst:
    case tCharConst:
    case tStringConst:
    case tLParens:
    case tNot:
      return new CAstStatReturn(t, s, expression(s));
    default:
      return new CAstStatReturn(t, s, NULL);
  }
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
  CTypeManager *CTM = CTypeManager::Get();

  if (_scanner->Peek().GetType() != tRParens) {
    CAstExpression *exp = expression(s);    
    fc->AddArg(exp);

    while (_scanner->Peek().GetType() == tComma) {
      Consume(tComma);
      exp  = expression(s);
      fc->AddArg(exp);
    }
  }

  Consume(tRParens);
  
  return fc;
}

CAstStatAssign* CParser::assignment(CAstScope *s, CToken *t, const CSymbol *sym)
{
  //
  // assignment ::= qualident ":=" expression.
  //

  CAstDesignator *lhs = dynamic_cast<CAstDesignator*>(qualident(s, t, sym));
  if (lhs == NULL)
    SetError(t, "assignment to a symbolic constant.");

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
    else {
      SetError(t, "invalid relation.");
      return NULL;
    }

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

  CToken unary;
  if (_scanner->Peek().GetType() == tPlusMinus) {
    Consume(tPlusMinus, &unary);
    if (unary.GetValue()=="+") {
      n = new CAstUnaryOp(unary, opPos, term(s,false));
    }
    else if (_scanner->Peek().GetType()==tNumber) {
      n = term(s,true);
    }
    else if (_scanner->Peek().GetType()==tLParens) {
      n = term(s,true);
    } 
    else n = new CAstUnaryOp(unary, opNeg, term(s,false));
  }else {
    n = term(s, false);
  }

  EToken tt = _scanner->Peek().GetType();
  while (!_abort && (tt == tPlusMinus || tt == tOr))  {
    CToken t;
    CAstExpression *l = n, *r;

    Consume(tt, &t);

    r = term(s,false);

    EOperation opT;
    string v = t.GetValue();
    if (v == "+") opT = opAdd;
    else if (v == "-") opT = opSub;
    else if (v == "||") opT = opOr;
    else {
      SetError(t, "termOp expected");
      break;
    }

    n = new CAstBinaryOp(t, opT, l, r);

    tt = _scanner->Peek().GetType();
  }

  return n;
}

CAstExpression* CParser::term(CAstScope *s, bool fold)
{
  //
  // term ::= factor { ("*"|"/") factor }.
  //
  CAstExpression *n = NULL;

  n = factor(s, fold);

  EToken tt = _scanner->Peek().GetType();

  while (!_abort && (tt == tMulDiv || tt == tAnd)) {
    CToken t;
    CAstExpression *l = n, *r;

    Consume(tt, &t);

    r = factor(s,false);

    EOperation opT;
    string v = t.GetValue();
    if (v == "*") opT = opMul;
    else if (v == "/") opT = opDiv;
    else if (v == "&&") opT = opAnd;
    else {
      SetError(t, "factOp expected");
      break;
    }

    n = new CAstBinaryOp(t, opT, l, r);

    tt = _scanner->Peek().GetType();
  }

  return n;
}

CAstExpression* CParser::factor(CAstScope *s, bool fold)
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
  CAstExpression *exp = NULL;
  const CSymbol *sym;

  if (_abort) return NULL;

  switch (_scanner->Peek().GetType()) {
    case tIdent:
      Consume(tIdent, &t);
      sym = s->GetSymbolTable()->FindSymbol(t.GetValue());
      if (sym == NULL) {
          SetError(t, "undefined identifier");
          return NULL;
      }
      switch (_scanner->Peek().GetType()) {
        case tLParens:
          return subroutineCall(s, &t, sym);
        default:
          return qualident(s, &t, sym);
      }
    case tNumber: {
      sym = NULL;
      CAstConstant *intNum = number();
      if (fold) intNum->SetValue(-intNum->GetValue());
      return intNum;
    }
    case tBoolConst: {
      sym = NULL;
      return boolean();
    }
    case tCharConst:
      sym = NULL;
      return characterConst();  
    case tStringConst:
      sym = NULL;
      return stringConst(s);
    case tLParens: {
      sym = NULL;
      Consume(tLParens);
      exp = expression(s);
      Consume(tRParens);
      // This is for the relaxed parsing.
      exp->SetParenthesized(true);
      if (fold) {
        CAstUnaryOp *minusExp = new CAstUnaryOp(exp->GetToken(), opNeg, exp);
        return minusExp;
      }
      return exp;
    }
    case tNot:
      sym = NULL;
      Consume(tNot, &t);
      exp = factor(s, false);
      return new CAstUnaryOp(t, opNot, exp);
    default:
      sym = NULL;
      SetError(_scanner->Peek(), "factor expected");
      return NULL;
  }
}

CAstOperand* CParser::qualident(CAstScope *s, CToken *t, const CSymbol *sym)
{
  //
  // qualident ::= ident { "[" simpleexpr "]" }.
  //

  const CSymConstant *symConst = NULL;
  CAstArrayDesignator *arrDesig = NULL;
  if (_scanner->Peek().GetType() == tLBrak) {
    arrDesig = new CAstArrayDesignator(t, sym);

    while (!_abort && _scanner->Peek().GetType() == tLBrak) {
      Consume(tLBrak);
      CAstExpression *idx = simpleexpr(s);
      Consume(tRBrak);
      arrDesig->AddIndex(idx);
    }

    arrDesig->IndicesComplete();
    return arrDesig;
  } else if ((symConst = dynamic_cast<const CSymConstant*>(sym)) != NULL) {
    const CType *constType = sym->GetDataType();
    if (constType->IsArray()) {
      CSymtab *symtab = s->GetSymbolTable();
      if (symtab->GetParent() != NULL)
        symtab = symtab->GetParent();
      
      vector<CSymbol*> symbols = symtab->GetSymbols();
      vector<CSymbol*>::const_iterator it = symbols.begin();
      CSymbol *globalSym = NULL;

      while (it != symbols.end()) {
        if (
          (*it)->GetSymbolType() == stGlobal &&
          (*it)->GetData() == sym->GetData()
        ) {
          globalSym = (*it);
          break;
        }
        it++;
      }

      assert(it != symbols.end());

      return new CAstDesignator(t, globalSym);
    } else if (constType->IsInt()) {
      const CDataInitInteger *dataInitInteger = dynamic_cast<const CDataInitInteger*>(sym->GetData());
      return new CAstConstant(t, constType, dataInitInteger->GetData());
    } else if (constType->IsBoolean()) {
      const CDataInitBoolean *dataInitBoolean = dynamic_cast<const CDataInitBoolean*>(sym->GetData());
      return new CAstConstant(t, constType, dataInitBoolean->GetData());
    } else if (constType->IsChar()) {
      const CDataInitChar *dataInitChar = dynamic_cast<const CDataInitChar*>(sym->GetData());
      return new CAstConstant(t, constType, dataInitChar->GetData());
    } else {
      assert(false);
    } 
  } else {
    return new CAstDesignator(t, sym);
  }

}

CAstType* CParser::type(CAstScope *s, const bool formalParam, const bool constDecl)
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

  const CType* type = arraytype(s, basetype, formalParam, constDecl);

  // arrays that are too big return NULL.
  // We need to deal with this and check if type points to NULL
  
  if (formalParam && type->IsArray())
    return new CAstType(t, tm->GetPointer(type));
  return new CAstType(t, type);
}

const CType* CParser::arraytype(CAstScope *s, const CType* t, const bool formalParam, const bool constDecl)
{
  //
  // arraytype ::= "[" expression "]" arraytype.
  //

  if (_abort || _scanner->Peek().GetType() != tLBrak)
    return t;

  CToken token;
  CTypeManager *tm = CTypeManager::Get();
  int length = 0;

  Consume(tLBrak, &token);

  EToken tt = _scanner->Peek().GetType();
  if (!formalParam && tt == tRBrak && !constDecl && !t->Match(tm->GetChar())) 
    SetError(_scanner->Peek(), "Open arrays are only allowed in formal parameters or constant char arrays");
  else if (tt == tRBrak) 
    length = CArrayType::OPEN;
  else {
    CAstExpression *exp = simpleexpr(s);

    CToken t;
    string msg;
    if (!exp->TypeCheck(&t, &msg)) {
      SetError(t, msg);
      return NULL;
    } else if (!tm->GetInt()->Match(exp->GetType())) {
      SetError(token, "array length simpleexpr must be of integer type.");
      return NULL;
    }
    
    const CDataInitInteger *dataInitInt = static_cast<const CDataInitInteger*>(exp->Evaluate());
    length = dataInitInt->GetData();
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
  string v = t.GetValue();
  if (v.size() < 2 || v.at(0) != '"' || v.at(v.size() - 1) != '"')
    SetError(t, "Invalid string constant. Not surrounded by double quotes");
  int length = v.size() - 2;
  string unquoted = v.substr(1, length);
  return new CAstStringConstant(t, unquoted, s);
}

CAstConstant* CParser::characterConst(void)
{
  //
  // char ::= "'" character "'"
  //

  CToken t;

  Consume(tCharConst, &t);

  errno = 0;
  string unescaped = CToken::unescape(t.GetValue());
  char v;
  if (unescaped.size() == 0)
    v = 0;
  else
    v = unescaped.at(0);
  if (errno != 0) SetError(t, "invalid char constant.");

  return new CAstConstant(t, CTypeManager::Get()->GetChar(), v);
}
