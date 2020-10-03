//------------------------------------------------------------------------------
/// @brief SnuPL abstract syntax tree
/// @author Bernhard Egger <bernhard@csap.snu.ac.kr>
/// @section changelog Change Log
/// 2012/09/14 Bernhard Egger created
/// 2013/05/22 Bernhard Egger reimplemented TAC generation
/// 2013/11/04 Bernhard Egger added typechecks for unary '+' operators
/// 2016/03/12 Bernhard Egger adapted to SnuPL/1
/// 2019/09/15 Bernhard Egger added support for constant expressions
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

#include <iostream>
#include <cassert>
#include <cstring>

#include <typeinfo>

#include "ast.h"
using namespace std;


//------------------------------------------------------------------------------
// CAstNode
//
int CAstNode::_global_id = 0;

CAstNode::CAstNode(CToken token)
  : _token(token), _addr(NULL)
{
  _id = _global_id++;
}

CAstNode::~CAstNode(void)
{
  if (_addr != NULL) delete _addr;
}

int CAstNode::GetID(void) const
{
  return _id;
}

CToken CAstNode::GetToken(void) const
{
  return _token;
}

const CType* CAstNode::GetType(void) const
{
  return CTypeManager::Get()->GetNull();
}

string CAstNode::dotID(void) const
{
  ostringstream out;
  out << "node" << dec << _id;
  return out.str();
}

string CAstNode::dotAttr(void) const
{
  return " [label=\"" + dotID() + "\"]";
}

void CAstNode::toDot(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << dotID() << dotAttr() << ";" << endl;
}

CTacAddr* CAstNode::GetTacAddr(void) const
{
  return _addr;
}

ostream& operator<<(ostream &out, const CAstNode &t)
{
  return t.print(out);
}

ostream& operator<<(ostream &out, const CAstNode *t)
{
  return t->print(out);
}

//------------------------------------------------------------------------------
// CAstScope
//
CAstScope::CAstScope(CToken t, const string name, CAstScope *parent)
  : CAstNode(t), _name(name), _symtab(NULL), _parent(parent), _statseq(NULL),
    _cb(NULL)
{
  if (_parent != NULL) _parent->AddChild(this);
}

CAstScope::~CAstScope(void)
{
  delete _symtab;
  delete _statseq;
  delete _cb;
}

const string CAstScope::GetName(void) const
{
  return _name;
}

CAstScope* CAstScope::GetParent(void) const
{
  return _parent;
}

size_t CAstScope::GetNumChildren(void) const
{
  return _children.size();
}

CAstScope* CAstScope::GetChild(size_t i) const
{
  assert(i < _children.size());
  return _children[i];
}

CSymtab* CAstScope::GetSymbolTable(void) const
{
  assert(_symtab != NULL);
  return _symtab;
}

CSymbol* CAstScope::CreateConst(const string ident, const CType *type,
                                const CDataInitializer *data)
{
  return new CSymConstant(ident, type, data);
}

void CAstScope::SetStatementSequence(CAstStatement *statseq)
{
  _statseq = statseq;
}

CAstStatement* CAstScope::GetStatementSequence(void) const
{
  return _statseq;
}

bool CAstScope::TypeCheck(CToken *t, string *msg) const
{
  bool result = true;

  // TODO (phase 3)
  //
  try {
    CAstStatement *s = _statseq;
    while (result && s != NULL) {
      result = s->TypeCheck(t, msg);
      s = s->GetNext();
    }

    vector<CAstScope*>::const_iterator it = _children.begin();
    while (result && it != _children.end()) {
      result = (*it)->TypeCheck(t, msg);
      it++;
    }
  } catch(...) {
    result = false;
  }

  return result;
}

ostream& CAstScope::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << "CAstScope: '" << _name << "'" << endl;
  out << ind << "  symbol table:" << endl;
  _symtab->print(out, indent+4);
  out << ind << "  statement list:" << endl;
  CAstStatement *s = GetStatementSequence();
  if (s != NULL) {
    do {
      s->print(out, indent+4);
      s = s->GetNext();
    } while (s != NULL);
  } else {
    out << ind << "    empty." << endl;
  }

  out << ind << "  nested scopes:" << endl;
  if (_children.size() > 0) {
    for (size_t i=0; i<_children.size(); i++) {
      _children[i]->print(out, indent+4);
    }
  } else {
    out << ind << "    empty." << endl;
  }
  out << ind << endl;

  return out;
}

void CAstScope::toDot(ostream &out, int indent) const
{
  string ind(indent, ' ');

  CAstNode::toDot(out, indent);

  CAstStatement *s = GetStatementSequence();
  if (s != NULL) {
    string prev = dotID();
    do {
      s->toDot(out, indent);
      out << ind << prev << " -> " << s->dotID() << " [style=dotted];" << endl;
      prev = s->dotID();
      s = s->GetNext();
    } while (s != NULL);
  }

  vector<CAstScope*>::const_iterator it = _children.begin();
  while (it != _children.end()) {
    CAstScope *s = *it++;
    s->toDot(out, indent);
    out << ind << dotID() << " -> " << s->dotID() << ";" << endl;
  }

}

CTacAddr* CAstScope::ToTac(CCodeBlock *cb)
{
  // TODO (phase 4)
  assert(cb != NULL);

  CAstStatement *s = GetStatementSequence();
  while (s != NULL) {
    CTacLabel *next = cb->CreateLabel();
    s->ToTac(cb, next);
    cb->AddInstr(next);
    s = s->GetNext();
  }

  cb->CleanupControlFlow();

  return NULL;
}

CCodeBlock* CAstScope::GetCodeBlock(void) const
{
  return _cb;
}

void CAstScope::SetSymbolTable(CSymtab *st)
{
  if (_symtab != NULL) delete _symtab;
  _symtab = st;
}

void CAstScope::AddChild(CAstScope *child)
{
  _children.push_back(child);
}


//------------------------------------------------------------------------------
// CAstModule
//
CAstModule::CAstModule(CToken t, const string name)
  : CAstScope(t, name, NULL)
{
  SetSymbolTable(new CSymtab());
}

CSymbol* CAstModule::CreateVar(const string ident, const CType *type)
{
  return new CSymGlobal(ident, type);
}

string CAstModule::dotAttr(void) const
{
  return " [label=\"m " + GetName() + "\",shape=box]";
}



//------------------------------------------------------------------------------
// CAstProcedure
//
CAstProcedure::CAstProcedure(CToken t, const string name,
                             CAstScope *parent, CSymProc *symbol)
  : CAstScope(t, name, parent), _symbol(symbol)
{
  assert(GetParent() != NULL);
  SetSymbolTable(new CSymtab(GetParent()->GetSymbolTable()));
  assert(_symbol != NULL);
}

CSymProc* CAstProcedure::GetSymbol(void) const
{
  return _symbol;
}

CSymbol* CAstProcedure::CreateVar(const string ident, const CType *type)
{
  return new CSymLocal(ident, type);
}

const CType* CAstProcedure::GetType(void) const
{
  return GetSymbol()->GetDataType();
}

string CAstProcedure::dotAttr(void) const
{
  return " [label=\"p/f " + GetName() + "\",shape=box]";
}


//------------------------------------------------------------------------------
// CAstType
//
CAstType::CAstType(CToken t, const CType *type)
  : CAstNode(t), _type(type)
{
  assert(type != NULL);
}

const CType* CAstType::GetType(void) const
{
  return _type;
}

ostream& CAstType::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << "CAstType (" << _type << ")" << endl;
  return out;
}


//------------------------------------------------------------------------------
// CAstStatement
//
CAstStatement::CAstStatement(CToken token)
  : CAstNode(token), _next(NULL)
{
}

CAstStatement::~CAstStatement(void)
{
  delete _next;
}

void CAstStatement::SetNext(CAstStatement *next)
{
  _next = next;
}

CAstStatement* CAstStatement::GetNext(void) const
{
  return _next;
}

CTacAddr* CAstStatement::ToTac(CCodeBlock *cb, CTacLabel *next)
{
  // generate code for statement (assignment, if-else, etc.)

  // jump to next
  // TODO: find out if this is necessary.
  // cb->AddInstr(new CTacInstr(opGoto, next));

  return NULL;
}


//------------------------------------------------------------------------------
// CAstStatAssign
//
CAstStatAssign::CAstStatAssign(CToken t,
                               CAstDesignator *lhs, CAstExpression *rhs)
  : CAstStatement(t), _lhs(lhs), _rhs(rhs)
{
  assert(lhs != NULL);
  assert(rhs != NULL);
}

CAstDesignator * CAstStatAssign::GetLHS(void) const
{
  return _lhs;
}

CAstExpression* CAstStatAssign::GetRHS(void) const
{
  return _rhs;
}

bool CAstStatAssign::TypeCheck(CToken *t, string *msg) const
{
  // TODO (phase 3)
  bool result = _lhs->TypeCheck(t, msg) &&
                _rhs->TypeCheck(t, msg);

  if (result) {
    assert(_lhs->GetType() != NULL);

    bool isCompoundType = !_lhs->GetType()->IsScalar();
    bool typeMismatch = !_lhs->GetType()->Match(_rhs->GetType());

    if (isCompoundType || typeMismatch) {
      if (t != NULL) *t = GetToken();

      ostringstream o;
      if (isCompoundType) 
        o << "assignments to ct are not supported." << endl;
      if (typeMismatch) 
        o << "incompatible types in asssignment" << endl;
      if (msg != NULL)
        *msg = o.str();

      return false;
    }
  }

  return result;
}

const CType* CAstStatAssign::GetType(void) const
{
  return GetLHS()->GetType();
}

ostream& CAstStatAssign::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << ":=" << " ";

  const CType *t = GetType();
  if (t != NULL) out << t; else out << "<INVALID>";

  out << endl;

  _lhs->print(out, indent+2);
  _rhs->print(out, indent+2);

  return out;
}

string CAstStatAssign::dotAttr(void) const
{
  return " [label=\":=\",shape=box]";
}

void CAstStatAssign::toDot(ostream &out, int indent) const
{
  string ind(indent, ' ');

  CAstNode::toDot(out, indent);

  _lhs->toDot(out, indent);
  out << ind << dotID() << "->" << _lhs->dotID() << ";" << endl;
  _rhs->toDot(out, indent);
  out << ind << dotID() << "->" << _rhs->dotID() << ";" << endl;
}

CTacAddr* CAstStatAssign::ToTac(CCodeBlock *cb, CTacLabel *next)
{
  // TODO (phase 4)
  // generate code for assignment.
  CTacAddr* expr = GetRHS()->ToTac(cb);
  CTacAddr* addr = GetLHS()->ToTac(cb);
  assert(addr != NULL && expr != NULL);
  
  cb->AddInstr(new CTacInstr(opAssign, addr, expr));

  // jump to next.
  cb->AddInstr(new CTacInstr(opGoto, next));

  return NULL;
}


//------------------------------------------------------------------------------
// CAstStatCall
//
CAstStatCall::CAstStatCall(CToken t, CAstFunctionCall *call)
  : CAstStatement(t), _call(call)
{
  assert(call != NULL);
}

CAstFunctionCall* CAstStatCall::GetCall(void) const
{
  return _call;
}

bool CAstStatCall::TypeCheck(CToken *t, string *msg) const
{
  return GetCall()->TypeCheck(t, msg);
}

ostream& CAstStatCall::print(ostream &out, int indent) const
{
  _call->print(out, indent);

  return out;
}

string CAstStatCall::dotID(void) const
{
  return _call->dotID();
}

string CAstStatCall::dotAttr(void) const
{
  return _call->dotAttr();
}

void CAstStatCall::toDot(ostream &out, int indent) const
{
  _call->toDot(out, indent);
}

CTacAddr* CAstStatCall::ToTac(CCodeBlock *cb, CTacLabel *next)
{
  // TODO (phase 4)
  GetCall()->ToTac(cb);

  cb->AddInstr(new CTacInstr(opGoto, next));

  return NULL;
}


//------------------------------------------------------------------------------
// CAstStatReturn
//
CAstStatReturn::CAstStatReturn(CToken t, CAstScope *scope, CAstExpression *expr)
  : CAstStatement(t), _scope(scope), _expr(expr)
{
  assert(scope != NULL);
}

CAstScope* CAstStatReturn::GetScope(void) const
{
  return _scope;
}

CAstExpression* CAstStatReturn::GetExpression(void) const
{
  return _expr;
}

bool CAstStatReturn::TypeCheck(CToken *t, string *msg) const
{
  // TODO (phase 3)
  // we're in a func/procedure
  const CType *st = GetScope()->GetType();
  CAstExpression *e = GetExpression();

  if (st->Match(CTypeManager::Get()->GetNull())) {
    if (e != NULL) {
      if (t != NULL) *t = e->GetToken();
      if (msg != NULL) *msg = "superfluous expression after return.";
      return false;
    }
  } else {
    if (e == NULL) {
      if (t != NULL) *t = GetToken();
      if (msg != NULL) *msg = "expression expected after return.";
      return false;
    }

    if (!e->TypeCheck(t, msg)) return false;

    if (!st->Match(e->GetType())) {
      if (t != NULL) *t = e->GetToken();
      if (msg != NULL) *msg = "return type mismatch.";
      return false;
    }
  }

  return true;
}

const CType* CAstStatReturn::GetType(void) const
{
  const CType *t = NULL;

  if (GetExpression() != NULL) {
    t = GetExpression()->GetType();
  } else {
    t = CTypeManager::Get()->GetNull();
  }

  return t;
}

ostream& CAstStatReturn::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << "return" << " ";

  const CType *t = GetType();
  if (t != NULL) out << t; else out << "<INVALID>";

  out << endl;

  if (_expr != NULL) _expr->print(out, indent+2);

  return out;
}

string CAstStatReturn::dotAttr(void) const
{
  return " [label=\"return\",shape=box]";
}

void CAstStatReturn::toDot(ostream &out, int indent) const
{
  string ind(indent, ' ');

  CAstNode::toDot(out, indent);

  if (_expr != NULL) {
    _expr->toDot(out, indent);
    out << ind << dotID() << "->" << _expr->dotID() << ";" << endl;
  }
}

CTacAddr* CAstStatReturn::ToTac(CCodeBlock *cb, CTacLabel *next)
{
  // generate code for return statement.
  CTacAddr* expr = NULL;
  if (GetExpression() != NULL) 
    expr = GetExpression()->ToTac(cb);
  
  cb->AddInstr(new CTacInstr(opReturn, NULL, expr));

  // jump to next.
  cb->AddInstr(new CTacInstr(opGoto, next));

  return NULL;
}


//------------------------------------------------------------------------------
// CAstStatIf
//
CAstStatIf::CAstStatIf(CToken t, CAstExpression *cond,
                       CAstStatement *ifBody, CAstStatement *elseBody)
  : CAstStatement(t), _cond(cond), _ifBody(ifBody), _elseBody(elseBody)
{
  assert(cond != NULL);
}

CAstExpression* CAstStatIf::GetCondition(void) const
{
  return _cond;
}

CAstStatement* CAstStatIf::GetIfBody(void) const
{
  return _ifBody;
}

CAstStatement* CAstStatIf::GetElseBody(void) const
{
  return _elseBody;
}

bool CAstStatIf::TypeCheck(CToken *t, string *msg) const
{
  // TODO (phase 3)
  bool result = _cond->TypeCheck(t, msg);
  if (!result) return false;

  result = _cond->GetType()->Match(CTypeManager::Get()->GetBool());
  if (!result) {
    if (t != NULL)
      *t = GetToken();
    if (msg != NULL)
      *msg = "if condition must be of boolean type.";
    return false;
  }

  // const CType *typeOfCondition = _cond->GetType();
  // result = typeOfCondition->Match(CTypeManager::Get()->GetBool());

  CAstStatement *s = _ifBody;
  while (result && s != NULL) {
    result = s->TypeCheck(t, msg);
    s = s->GetNext();
  }

  s = _elseBody;
  while (result && s != NULL) {
    result = s->TypeCheck(t, msg);
    s = s->GetNext();
  }

  return result;
}

ostream& CAstStatIf::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << "if cond" << endl;
  _cond->print(out, indent+2);
  out << ind << "if-body" << endl;
  if (_ifBody != NULL) {
    CAstStatement *s = _ifBody;
    do {
      s->print(out, indent+2);
      s = s->GetNext();
    } while (s != NULL);
  } else out << ind << "  empty." << endl;
  out << ind << "else-body" << endl;
  if (_elseBody != NULL) {
    CAstStatement *s = _elseBody;
    do {
      s->print(out, indent+2);
      s = s->GetNext();
    } while (s != NULL);
  } else out << ind << "  empty." << endl;

  return out;
}

string CAstStatIf::dotAttr(void) const
{
  return " [label=\"if\",shape=box]";
}

void CAstStatIf::toDot(ostream &out, int indent) const
{
  string ind(indent, ' ');

  CAstNode::toDot(out, indent);

  _cond->toDot(out, indent);
  out << ind << dotID() << "->" << _cond->dotID() << ";" << endl;

  if (_ifBody != NULL) {
    CAstStatement *s = _ifBody;
    if (s != NULL) {
      string prev = dotID();
      do {
        s->toDot(out, indent);
        out << ind << prev << " -> " << s->dotID() << " [style=dotted];"
            << endl;
        prev = s->dotID();
        s = s->GetNext();
      } while (s != NULL);
    }
  }

  if (_elseBody != NULL) {
    CAstStatement *s = _elseBody;
    if (s != NULL) {
      string prev = dotID();
      do {
        s->toDot(out, indent);
        out << ind << prev << " -> " << s->dotID() << " [style=dotted];" 
            << endl;
        prev = s->dotID();
        s = s->GetNext();
      } while (s != NULL);
    }
  }
}

CTacAddr* CAstStatIf::ToTac(CCodeBlock *cb, CTacLabel *next)
{
  // TODO (phase 4)
  assert(cb != NULL);

  // CTacLabel *ifLabel = NULL;
  // CTacLabel *elseLabel = NULL;
  // if (GetIfBody() == NULL && GetElseBody() == NULL) {
  //   GetCondition()->ToTac(cb, next, next);
  // } else if (GetIfBody() != NULL && GetElseBody() == NULL) {
  //   ifLabel = cb->CreateLabel("if_true");
  //   GetCondition()->ToTac(cb, ifLabel, next);
  // } else if (GetIfBody() == NULL && GetElseBody() != NULL) {
  //   elseLabel = cb->CreateLabel("if_false");
  //   GetCondition()->ToTac(cb, next, elseLabel);
  // } else {
  //   ifLabel = cb->CreateLabel("if_true");
  //   elseLabel = cb->CreateLabel("if_false");
  //   GetCondition()->ToTac(cb, ifLabel, elseLabel);
  // }

  CTacLabel *ifTrue = cb->CreateLabel("if_true");
  CTacLabel *ifFalse = cb->CreateLabel("if_false");
  GetCondition()->ToTac(cb, ifTrue, ifFalse);

  cb->AddInstr(ifTrue);
  CAstStatement *s = GetIfBody();
  while (s != NULL) {
    CTacLabel *ifNext = cb->CreateLabel();
    s->ToTac(cb, ifNext);
    cb->AddInstr(ifNext);
    s = s->GetNext();
  }
  cb->AddInstr(new CTacInstr(opGoto, next));
  
  cb->AddInstr(ifFalse);
  s = GetElseBody();
  while (s != NULL) {
    CTacLabel *elseNext = cb->CreateLabel();
    s->ToTac(cb, elseNext);
    cb->AddInstr(elseNext);
    s = s->GetNext();
  }
  cb->AddInstr(new CTacInstr(opGoto, next));

  return NULL;
}


//------------------------------------------------------------------------------
// CAstStatWhile
//
CAstStatWhile::CAstStatWhile(CToken t,
                             CAstExpression *cond, CAstStatement *body)
  : CAstStatement(t), _cond(cond), _body(body)
{
  assert(cond != NULL);
}

CAstExpression* CAstStatWhile::GetCondition(void) const
{
  return _cond;
}

CAstStatement* CAstStatWhile::GetBody(void) const
{
  return _body;
}

bool CAstStatWhile::TypeCheck(CToken *t, string *msg) const
{
  // TODO (phase 3)
  bool result = _cond->TypeCheck(t, msg);
  if (!result) return false;

  const CType *typeOfCondition = _cond->GetType();
  result = typeOfCondition->Match(CTypeManager::Get()->GetBool());
  if (!result) {
    if (t != NULL) 
      *t = GetToken();
    if (msg != NULL)
      *msg = "while condition must be of boolean type.";
    return false;
  }

  CAstStatement *s = _body;
  while (result && s != NULL) {
    result = s->TypeCheck(t, msg);
    s = s->GetNext();
  }

  return true;
}

ostream& CAstStatWhile::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << "while cond" << endl;
  _cond->print(out, indent+2);
  out << ind << "while-body" << endl;
  if (_body != NULL) {
    CAstStatement *s = _body;
    do {
      s->print(out, indent+2);
      s = s->GetNext();
    } while (s != NULL);
  }
  else out << ind << "  empty." << endl;

  return out;
}

string CAstStatWhile::dotAttr(void) const
{
  return " [label=\"while\",shape=box]";
}

void CAstStatWhile::toDot(ostream &out, int indent) const
{
  string ind(indent, ' ');

  CAstNode::toDot(out, indent);

  _cond->toDot(out, indent);
  out << ind << dotID() << "->" << _cond->dotID() << ";" << endl;

  if (_body != NULL) {
    CAstStatement *s = _body;
    if (s != NULL) {
      string prev = dotID();
      do {
        s->toDot(out, indent);
        out << ind << prev << " -> " << s->dotID() << " [style=dotted];"
            << endl;
        prev = s->dotID();
        s = s->GetNext();
      } while (s != NULL);
    }
  }
}

CTacAddr* CAstStatWhile::ToTac(CCodeBlock *cb, CTacLabel *next)
{
  // TODO (phase 4)
  assert(cb != NULL);

  CTacLabel *conditionLabel = cb->CreateLabel("while_cond");
  CTacLabel *bodyLabel = cb->CreateLabel("while_body");

  cb->AddInstr(conditionLabel);
  GetCondition()->ToTac(cb, bodyLabel, next);

  cb->AddInstr(bodyLabel);
  CAstStatement *s = GetBody();
  while (s != NULL) {
    CTacLabel *bodyNext = cb->CreateLabel();
    s->ToTac(cb, bodyNext);
    cb->AddInstr(bodyNext);
    s = s->GetNext();
  }
  cb->AddInstr(new CTacInstr(opGoto, conditionLabel));

  cb->AddInstr(new CTacInstr(opGoto, next));

  return NULL;
}


//------------------------------------------------------------------------------
// CAstExpression
//
CAstExpression::CAstExpression(CToken t)
  : CAstNode(t)
{
}

void CAstExpression::SetParenthesized(bool parenthesized)
{
  _parenthesized = parenthesized;
}

bool CAstExpression::GetParenthesized(void) const
{
  return _parenthesized;
}

const CDataInitializer* CAstExpression::Evaluate(void) const
{
  return NULL;
}

CTacAddr* CAstExpression::ToTac(CCodeBlock *cb)
{
  return NULL;
}

CTacAddr* CAstExpression::ToTac(CCodeBlock *cb,
                                CTacLabel *ltrue, CTacLabel *lfalse)
{
  return NULL;
}


//------------------------------------------------------------------------------
// CAstOperation
//
CAstOperation::CAstOperation(CToken t, EOperation oper)
  : CAstExpression(t), _oper(oper)
{
}

EOperation CAstOperation::GetOperation(void) const
{
  return _oper;
}


//------------------------------------------------------------------------------
// CAstBinaryOp
//
CAstBinaryOp::CAstBinaryOp(CToken t, EOperation oper,
                           CAstExpression *l,CAstExpression *r)
  : CAstOperation(t, oper), _left(l), _right(r)
{
  // these are the only binary operation we support for now
  assert((oper == opAdd)        || (oper == opSub)         ||
         (oper == opMul)        || (oper == opDiv)         ||
         (oper == opAnd)        || (oper == opOr)          ||
         (oper == opEqual)      || (oper == opNotEqual)    ||
         (oper == opLessThan)   || (oper == opLessEqual)   ||
         (oper == opBiggerThan) || (oper == opBiggerEqual)
        );
  assert(l != NULL);
  assert(r != NULL);
}

CAstExpression* CAstBinaryOp::GetLeft(void) const
{
  return _left;
}

CAstExpression* CAstBinaryOp::GetRight(void) const
{
  return _right;
}

bool CAstBinaryOp::TypeCheck(CToken *t, string *msg) const
{
  // TODO (phase 3)
  CTypeManager *CTM = CTypeManager::Get();
  const CType *lt, *rt;

  lt = _left -> GetType();
  rt = _right -> GetType();

  assert (lt!=NULL && rt!=NULL);

  if (! _left -> TypeCheck(t, msg) || ! _right -> TypeCheck(t, msg)) return false;

  if (lt==CTM->GetNull()) {
    if (t != NULL) *t = _left -> GetToken();
    if (msg != NULL) *msg = "Operand type is null";
    return false;
  }

  if (rt==CTM->GetNull()) {
    if (t != NULL) *t = _right -> GetToken();
    if (msg != NULL) *msg = "Operand type is null";
    return false;
  }
   
  if (!lt->Match(rt)) {
    if (t != NULL) *t = GetToken();
    if (msg != NULL) *msg = "Operands type mismatch";
    return false;  
  }

  if (IsRelOp(GetOperation())) {
    if (GetOperation()==opEqual || GetOperation()==opNotEqual) {
      if (lt->IsInt() || lt->IsBoolean() || lt->IsChar()) return true;
      if (t != NULL) *t = GetToken();
      if (msg != NULL) *msg = "Invalid type of operand";
      return false;
    }
    if (lt->IsInt() || lt->IsChar()) return true;
    if (t != NULL) *t = GetToken();
    if (msg != NULL) *msg = "Invalid type of operand";
    return false;
  }

  if (GetOperation()==opAdd || GetOperation()==opSub || GetOperation()==opMul || GetOperation()==opDiv) {
    if (lt->IsInt()) return true;
    if (t != NULL) *t = GetToken();
    if (msg != NULL) *msg = "Invalid type of operand";
    return false;    
  }

  if (GetOperation()==opAnd || GetOperation()==opOr) {
    if (lt->IsBoolean()) return true;
    if (t != NULL) *t = GetToken();
    if (msg != NULL) *msg = "Invalid type of operand";
    return false;
  }

  if (t != NULL) *t = GetToken();
  if (msg != NULL) *msg = "Invalid operation";
  return false;
}

const CType* CAstBinaryOp::GetType(void) const
{
  // TODO (phase 3)
  CTypeManager *CTM = CTypeManager::Get();

  if (IsRelOp(GetOperation())) return CTM -> GetBool();

  if (GetOperation()==opAdd || GetOperation()==opSub || GetOperation()==opMul || GetOperation()==opDiv) 
	  return CTM -> GetInt();

  if (GetOperation()==opAnd || GetOperation()==opOr) return CTM -> GetBool();

  return CTM -> GetNull();
}

const CDataInitializer* CAstBinaryOp::Evaluate(void) const
{
  // TODO (phase 3)
  // numerical evaluation frees the datainitializers
  // return new instances
  //
  // if (_left -> GetParenthesized)
  // if (_right -> GetParenthesized)
  
  const CDataInitializer *di[2];
  const CDataInitializer *rdi = NULL;
  
  // make pointers for each type

  di[0] = _left->Evaluate();
  di[1] = _right->Evaluate();
  if (di[0] == NULL || di[1] == NULL) {
    delete di[0]; delete di[1];
    return NULL;
  }


  // At this point we have typechecked already.
  // So assume that binaryOp is valid.
  const CDataInitInteger *intOfLeft = dynamic_cast<const CDataInitInteger*>(di[0]);
  const CDataInitInteger *intOfRight = dynamic_cast<const CDataInitInteger*>(di[1]);
  
  const CDataInitBoolean *boolOfLeft = dynamic_cast<const CDataInitBoolean*>(di[0]);
  const CDataInitBoolean *boolOfRight = dynamic_cast<const CDataInitBoolean*>(di[1]);

  const CDataInitChar *charOfLeft = dynamic_cast<const CDataInitChar*>(di[0]);
  const CDataInitChar *charOfRight = dynamic_cast<const CDataInitChar*>(di[1]);

  const CDataInitInteger *evaluatedInt = NULL;
  const CDataInitBoolean *evaluatedBool = NULL;
  
  int evaluatedRawInt;
  bool evaluatedRawBool;
  switch (GetOperation()) {
    case opAdd :
      evaluatedRawInt = intOfLeft->GetData() + intOfRight->GetData();
      evaluatedInt = new const CDataInitInteger(evaluatedRawInt);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedInt);
	    break;
    case opSub :
      evaluatedRawInt = intOfLeft->GetData() - intOfRight->GetData();
      evaluatedInt = new const CDataInitInteger(evaluatedRawInt);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedInt);
	    break;
    case opMul :
      evaluatedRawInt = intOfLeft->GetData() * intOfRight->GetData();
      evaluatedInt = new const CDataInitInteger(evaluatedRawInt);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedInt);
	    break;
    case opDiv :
      evaluatedRawInt = intOfLeft->GetData() / intOfRight->GetData();
      evaluatedInt = new const CDataInitInteger(evaluatedRawInt);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedInt);
	    break;
    case opAnd :
      evaluatedRawBool = boolOfLeft->GetData() && boolOfRight->GetData();
      evaluatedBool = new const CDataInitBoolean(evaluatedRawBool);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedBool);
	    break;
    case opOr :
      evaluatedRawBool = boolOfLeft->GetData() || boolOfRight->GetData();
      evaluatedBool = new const CDataInitBoolean(evaluatedRawBool);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedBool);
    	break;
    case opEqual :
      if (intOfLeft != NULL && intOfRight != NULL) {
        evaluatedRawBool = intOfLeft->GetData() == intOfRight->GetData();
      } else if (boolOfLeft != NULL && boolOfRight != NULL) {
        evaluatedRawBool = boolOfLeft->GetData() == boolOfRight->GetData();
      } else {
        evaluatedRawBool = charOfLeft->GetData() == charOfRight->GetData();
      }
      evaluatedBool = new const CDataInitBoolean(evaluatedRawBool);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedBool);
	    break;
    case opNotEqual :
      if (intOfLeft != NULL && intOfRight != NULL) {
        evaluatedRawBool = intOfLeft->GetData() != intOfRight->GetData();
      } else if (boolOfLeft != NULL && boolOfRight != NULL) {
        evaluatedRawBool = boolOfLeft->GetData() != boolOfRight->GetData();
      } else {
        evaluatedRawBool = charOfLeft->GetData() != charOfRight->GetData();
      }
      evaluatedBool = new const CDataInitBoolean(evaluatedRawBool);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedBool);
	    break;
    case opLessThan :
      if (intOfLeft != NULL && intOfRight != NULL) {
        evaluatedRawBool = intOfLeft->GetData() < intOfRight->GetData();
      } else {
        evaluatedRawBool = charOfLeft->GetData() < charOfRight->GetData();
      }
      evaluatedBool = new const CDataInitBoolean(evaluatedRawBool);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedBool);
	    break;
    case opLessEqual :
      if (intOfLeft != NULL && intOfRight != NULL) {
        evaluatedRawBool = intOfLeft->GetData() <= intOfRight->GetData();
      } else {
        evaluatedRawBool = charOfLeft->GetData() <= charOfRight->GetData();
      }
      evaluatedBool = new const CDataInitBoolean(evaluatedRawBool);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedBool);
	    break;
    case opBiggerThan :
      if (intOfLeft != NULL && intOfRight != NULL) {
        evaluatedRawBool = intOfLeft->GetData() > intOfRight->GetData();
      } else {
        evaluatedRawBool = charOfLeft->GetData() > charOfRight->GetData();
      }
      evaluatedBool = new const CDataInitBoolean(evaluatedRawBool);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedBool);
	    break;
    case opBiggerEqual :
      if (intOfLeft != NULL && intOfRight != NULL) {
        evaluatedRawBool = intOfLeft->GetData() >= intOfRight->GetData();
      } else {
        evaluatedRawBool = charOfLeft->GetData() >= charOfRight->GetData();
      }
      evaluatedBool = new const CDataInitBoolean(evaluatedRawBool);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedBool);
	    break;
    default :
      // won't happen
	    break;
  }
  
  delete di[0];
  delete di[1];

  return rdi;
}

ostream& CAstBinaryOp::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << GetOperation() << " ";

  const CType *t = GetType();
  if (t != NULL) out << t; else out << "<INVALID>";

  out << endl;

  _left->print(out, indent+2);
  _right->print(out, indent+2);

  return out;
}

string CAstBinaryOp::dotAttr(void) const
{
  ostringstream out;
  out << " [label=\"" << GetOperation() << "\",shape=box]";
  return out.str();
}

void CAstBinaryOp::toDot(ostream &out, int indent) const
{
  string ind(indent, ' ');

  CAstNode::toDot(out, indent);

  _left->toDot(out, indent);
  out << ind << dotID() << "->" << _left->dotID() << ";" << endl;
  _right->toDot(out, indent);
  out << ind << dotID() << "->" << _right->dotID() << ";" << endl;
}

CTacAddr* CAstBinaryOp::ToTac(CCodeBlock *cb)
{
  // TODO (phase 4)
  const CTypeManager *tm = CTypeManager::Get();
  CTacLabel *ltrue  = NULL;
  CTacLabel *lfalse = NULL;
  CTacLabel *lnext  = NULL;
  CTacAddr  *src1   = NULL;
  CTacAddr  *src2   = NULL;
  CTacTemp  *dst    = NULL;

  CAstDesignator *astDesignator = NULL;
  CAstConstant   *astConstant   = NULL;
  CAstStatAssign *astStatAssign = NULL;
  CToken t;

  switch (GetOperation()) {
    case opAdd:
    case opSub:
    case opMul:
    case opDiv:
      src1 = GetLeft()->ToTac(cb);
      src2 = GetRight()->ToTac(cb);
      assert(src1 != NULL && src2 != NULL);
      dst = cb->CreateTemp(tm->GetInt());
      cb->AddInstr(new CTacInstr(GetOperation(), dst, src1, src2));
      return dst;
    case opAnd:
    case opOr:
    case opEqual:
    case opNotEqual:
    case opLessThan:
    case opLessEqual:
    case opBiggerThan:
    case opBiggerEqual:
      ltrue = cb->CreateLabel();
      lfalse = cb->CreateLabel();
      lnext = cb->CreateLabel();

      ToTac(cb, ltrue, lfalse);

      dst = cb->CreateTemp(tm->GetBool());
      astDesignator = new CAstDesignator(t, dst->GetSymbol());

      cb->AddInstr(ltrue);
      astConstant = new CAstConstant(t, tm->GetBool(), true);
      astStatAssign = new CAstStatAssign(t, astDesignator, astConstant);
      astStatAssign->ToTac(cb, lnext);

      cb->AddInstr(lfalse);
      astConstant = new CAstConstant(t, tm->GetBool(), false);
      astStatAssign = new CAstStatAssign(t, astDesignator, astConstant);
      astStatAssign->ToTac(cb, lnext);

      cb->AddInstr(lnext);
      return dst;
    default:
      assert(false);
  }
}

CTacAddr* CAstBinaryOp::ToTac(CCodeBlock *cb,
                              CTacLabel *ltrue, CTacLabel *lfalse)
{
  // TODO (phase 4)
  const CTypeManager *tm = CTypeManager::Get();
  assert(GetType()->Match(tm->GetBool()));

  CTacLabel *localLabel = NULL;
  CTacAddr *src1 = NULL;
  CTacAddr *src2 = NULL;

  switch (GetOperation()) {
    case opAnd:
      localLabel = cb->CreateLabel();
      GetLeft()->ToTac(cb, localLabel, lfalse);
      cb->AddInstr(localLabel);
      GetRight()->ToTac(cb, ltrue, lfalse);
      return NULL;
    case opOr:
      localLabel = cb->CreateLabel();
      GetLeft()->ToTac(cb, ltrue, localLabel);
      cb->AddInstr(localLabel);
      GetRight()->ToTac(cb, ltrue, lfalse);
      return NULL;
    case opEqual:
    case opNotEqual:
    case opLessThan:
    case opLessEqual:
    case opBiggerThan:
    case opBiggerEqual:
      src1 = GetLeft()->ToTac(cb);
      src2 = GetRight()->ToTac(cb);
      assert(src1 != NULL && src2 != NULL);
      cb->AddInstr(new CTacInstr(GetOperation(), ltrue, src1, src2));
      cb->AddInstr(new CTacInstr(opGoto, lfalse));
      return NULL;
    default:
      assert(false);
  }
}


//------------------------------------------------------------------------------
// CAstUnaryOp
//
CAstUnaryOp::CAstUnaryOp(CToken t, EOperation oper, CAstExpression *e)
  : CAstOperation(t, oper), _operand(e)
{
  assert((oper == opNeg) || (oper == opPos) || (oper == opNot));
  assert(e != NULL);
}

CAstExpression* CAstUnaryOp::GetOperand(void) const
{
  return _operand;
}

bool CAstUnaryOp::TypeCheck(CToken *t, string *msg) const
{
  // TODO (phase 3)
  if (! _operand -> TypeCheck(t,msg)) return false;

  const CType *tp = _operand->GetType();
  CTypeManager *CTM = CTypeManager::Get();

  assert (tp != NULL);

  switch (GetOperation()) {
    case opNeg:
    case opPos:
      if (tp->Match(CTM->GetInt())) return true;
      else {
        if (t != NULL) *t = GetToken();
        if (msg != NULL) *msg = "Invalid operand type";
        return false;
      }
    case opNot:
      if (tp->Match(CTM->GetBool())) return true;
      else {
        if (t != NULL) *t = GetToken();
        if (msg != NULL) *msg = "Invalid operand type";
        return false;
      }
    default:
      if (t != NULL) *t = GetToken();
      if (msg != NULL) *msg = "Invalid operation";
      return false;
  }
}

const CType* CAstUnaryOp::GetType(void) const
{
  // TODO (phase 3)
  CTypeManager *CTM = CTypeManager::Get();

  if (GetOperation()==opNeg || GetOperation()==opPos) return CTM -> GetInt();
  
  if (GetOperation()==opNot) return CTM -> GetBool();

  // TODO change to assert(false)?
  return CTM -> GetNull();
}

const CDataInitializer* CAstUnaryOp::Evaluate(void) const
{
  // TODO (phase 3)
  // if (_operand -> GetParenthesized)
  const CDataInitializer *di;
  const CDataInitializer *rdi = NULL;
  
  di = _operand -> Evaluate();
  if (di == NULL) {
    delete di;
    return NULL;
  }

  const CDataInitInteger *intOfOrand = dynamic_cast<const CDataInitInteger*>(di);
  const CDataInitBoolean *boolOfOrand = dynamic_cast<const CDataInitBoolean*>(di);

  const CDataInitInteger *evaluatedInt = NULL;
  const CDataInitBoolean *evaluatedBool = NULL;

  int evaluatedRawInt;
  bool evaluatedRawBool;
  
  switch (GetOperation()) {
    case opNeg :
      evaluatedRawInt = -(intOfOrand->GetData());
      evaluatedInt = new const CDataInitInteger(evaluatedRawInt);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedInt);
      break;
    case opPos :
      evaluatedRawInt = intOfOrand->GetData();
      evaluatedInt = new const CDataInitInteger(evaluatedRawInt);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedInt);
      break;
    case opNot :
      evaluatedRawBool = !(boolOfOrand->GetData());
      evaluatedBool = new const CDataInitBoolean(evaluatedRawBool);
      rdi = dynamic_cast<const CDataInitializer*>(evaluatedBool);
      break;
    default:
          
	  break;
  }

  delete di;

  return rdi;
}

ostream& CAstUnaryOp::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << GetOperation() << " ";

  const CType *t = GetType();
  if (t != NULL) out << t; else out << "<INVALID>";
  out << endl;

  _operand->print(out, indent+2);

  return out;
}

string CAstUnaryOp::dotAttr(void) const
{
  ostringstream out;
  out << " [label=\"" << GetOperation() << "\",shape=box]";
  return out.str();
}

void CAstUnaryOp::toDot(ostream &out, int indent) const
{
  string ind(indent, ' ');

  CAstNode::toDot(out, indent);

  _operand->toDot(out, indent);
  out << ind << dotID() << "->" << _operand->dotID() << ";" << endl;
}

CTacAddr* CAstUnaryOp::ToTac(CCodeBlock *cb)
{
  // TODO (phase 4)
  const CTypeManager *tm = CTypeManager::Get();

  CTacLabel *ltrue  = NULL;
  CTacLabel *lfalse = NULL;
  CTacLabel *lnext  = NULL;
  CTacAddr  *src    = NULL;
  CTacTemp  *dst    = NULL;

  CAstDesignator *astDesignator = NULL;
  CAstConstant   *astConstant   = NULL;
  CAstStatAssign *astStatAssign = NULL;
  CToken t;
  
  switch (GetOperation()) {
    case opNeg:
    case opPos:
      src = GetOperand()->ToTac(cb);
      dst = cb->CreateTemp(tm->GetInt());
      cb->AddInstr(new CTacInstr(GetOperation(), dst, src));
      return dst;
    case opNot:
      ltrue = cb->CreateLabel();
      lfalse = cb->CreateLabel();
      lnext = cb->CreateLabel();
      dst = cb->CreateTemp(tm->GetBool());
      astDesignator = new CAstDesignator(t, dst->GetSymbol());

      ToTac(cb, ltrue, lfalse);
      cb->AddInstr(ltrue);
      astConstant = new CAstConstant(t, tm->GetBool(), true);
      astStatAssign = new CAstStatAssign(t, astDesignator, astConstant);
      astStatAssign->ToTac(cb, lnext);

      cb->AddInstr(lfalse);
      astConstant = new CAstConstant(t, tm->GetBool(), false);
      astStatAssign = new CAstStatAssign(t, astDesignator, astConstant);
      astStatAssign->ToTac(cb, lnext);

      cb->AddInstr(lnext);
      return dst;
    default:
      assert(false);
  }
}

CTacAddr* CAstUnaryOp::ToTac(CCodeBlock *cb,
                             CTacLabel *ltrue, CTacLabel *lfalse)
{
  // TODO (phase 4)
  const CTypeManager *tm = CTypeManager::Get(); 
  assert(GetType()->Match(tm->GetBool()));

  switch (GetOperation()) {
    case opNot:
      GetOperand()->ToTac(cb, lfalse, ltrue);
      return NULL;
    default:
      assert(false);
  }
}


//------------------------------------------------------------------------------
// CAstSpecialOp
//
CAstSpecialOp::CAstSpecialOp(CToken t, EOperation oper, CAstExpression *e,
                             const CType *type)
  : CAstOperation(t, oper), _operand(e), _type(type)
{
  assert((oper == opAddress) || (oper == opDeref) || (oper = opCast));
  assert(e != NULL);
  assert(((oper != opCast) && (type == NULL)) ||
         ((oper == opCast) && (type != NULL)));
}

CAstExpression* CAstSpecialOp::GetOperand(void) const
{
  return _operand;
}

bool CAstSpecialOp::TypeCheck(CToken *t, string *msg) const
{
  if (!GetOperand()->TypeCheck(t, msg))
    return false;

  // TODO (phase 3)
  
  if (GetOperation() == opAddress) {
  	if (!_operand->GetType()->IsArray()){
      if (t != NULL) *t = GetToken();
      if (msg != NULL) *msg = "Type conversion is not supported unless array arguments or formal array parameters of type array have to be converted to pointer to array";
      return false;
    }
  }
  
  if (GetOperation() == opDeref) {
  	if (!_operand->GetType()->IsPointer()) {
      if (t != NULL) *t = GetToken();
      if (msg != NULL) *msg = "Only pointers can be dereferenced";
      return false;
    }
  }

  return true;
}

const CType* CAstSpecialOp::GetType(void) const
{
  // TODO (phase 3)
  CTypeManager *CTM = CTypeManager::Get();
  if (GetOperation() == opAddress) {
    return CTM -> GetPointer(_operand->GetType());
  }
  if (GetOperation() == opDeref) {
    const CPointerType *cPtr = dynamic_cast<const CPointerType*>(_operand->GetType());
    return cPtr->GetBaseType();
  }
  if (GetOperation() == opCast) return _type;
  return CTM->GetNull();
}

ostream& CAstSpecialOp::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << GetOperation() << " ";

  const CType *t = GetType();
  if (t != NULL) out << t; else out << "<INVALID>";
  out << endl;

  _operand->print(out, indent+2);

  return out;
}

string CAstSpecialOp::dotAttr(void) const
{
  ostringstream out;
  out << " [label=\"" << GetOperation() << "\",shape=box]";
  return out.str();
}

void CAstSpecialOp::toDot(ostream &out, int indent) const
{
  string ind(indent, ' ');

  CAstNode::toDot(out, indent);

  _operand->toDot(out, indent);
  out << ind << dotID() << "->" << _operand->dotID() << ";" << endl;
}

CTacAddr* CAstSpecialOp::ToTac(CCodeBlock *cb)
{
  // TODO (phase 4)
  CTypeManager *tm = CTypeManager::Get();

  CTacAddr  *src    = NULL;
  CTacTemp  *dst    = NULL;

  const CPointerType *cPtr = NULL;

  switch(GetOperation()) {
    case opAddress :
      src = _operand -> ToTac(cb);
      dst = cb -> CreateTemp(tm -> GetPointer(_operand -> GetType()));
      cb -> AddInstr(new CTacInstr(opAddress, dst, src));
      break;
    case opDeref :
      src = _operand -> ToTac(cb);
      cPtr = dynamic_cast<const CPointerType*>(_operand -> GetType());
      dst = cb -> CreateTemp(cPtr -> GetBaseType());
      cb -> AddInstr(new CTacInstr(opDeref, dst, src));
      break;
    case opCast :
      src = _operand -> ToTac(cb);
      dst = cb -> CreateTemp(_type);
      cb -> AddInstr(new CTacInstr(opCast, dst, src));
      break;
    default :
      assert(false);
      break;
  }
  return dst;
}


//------------------------------------------------------------------------------
// CAstFunctionCall
//
CAstFunctionCall::CAstFunctionCall(CToken t, const CSymProc *symbol)
  : CAstExpression(t), _symbol(symbol)
{
  assert(symbol != NULL);
}

const CSymProc* CAstFunctionCall::GetSymbol(void) const
{
  return _symbol;
}

void CAstFunctionCall::AddArg(CAstExpression *arg)
{
  // TODO (phase 3)
  // check param number.
  // make special op if param symbol type is pointer and arg type is array OR null.

  if (arg->GetType()->IsArray()) {
  	CAstSpecialOp *argToPtr = new CAstSpecialOp(arg->GetToken(), opAddress, arg, NULL);
	_arg.push_back(argToPtr);	
  }
  else _arg.push_back(arg);
}

unsigned int CAstFunctionCall::GetNArgs(void) const
{
  return _arg.size();
}

CAstExpression* CAstFunctionCall::GetArg(unsigned int index) const
{
  assert((index >= 0) && (index < _arg.size()));
  return _arg[index];
}

bool CAstFunctionCall::TypeCheck(CToken *t, string *msg) const
{
  // TODO (phase 3)
  // get nparam
  // get narg
  // match them
  // walk through params and args and match all types

  unsigned int nparams = GetSymbol()->GetNParams();
  unsigned int nargs = GetNArgs();
  
  if (nparams != nargs) {
    if (t != NULL) 
      *t = GetToken();
    if (msg != NULL) 
      *msg = "the number of arguments do not match the number of params";
    return false;
  }

  for (unsigned int i = 0; i < nparams; i++) {
    if (!GetArg(i)->TypeCheck(t, msg))
      return false;

    const CType *typeOfParam = GetSymbol()->GetParam(i)->GetDataType();
    const CType *typeOfArg = GetArg(i)->GetType();
    //const CPointerType *pPtr = dynamic_cast<const CPointerType*>(typeOfParam);
    //const CPointerType *aPtr = dynamic_cast<const CPointerType*>(typeOfArg);
    if (typeOfParam->Match(CTypeManager::Get()->GetVoidPtr())) {
      if (!typeOfArg->IsPointer()) {
        if (t != NULL)
          *t = GetToken();
        if (msg != NULL)
          *msg = "an argument to a parameter of pointer to void type should be of a pointer type.";
        return false;
      }
    } else if (!typeOfParam->Match(typeOfArg)) {
      if (t != NULL)
        *t = GetToken();
      if (msg != NULL)
        *msg = "argument type and parameter type does not match";
      return false;
    }
  }

  return true;
}

const CType* CAstFunctionCall::GetType(void) const
{
  return GetSymbol()->GetDataType();
}

ostream& CAstFunctionCall::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << "call " << _symbol << " ";
  const CType *t = GetType();
  if (t != NULL) out << t; else out << "<INVALID>";
  out << endl;

  for (size_t i=0; i<_arg.size(); i++) {
    _arg[i]->print(out, indent+2);
  }

  return out;
}

string CAstFunctionCall::dotAttr(void) const
{
  ostringstream out;
  out << " [label=\"call " << _symbol->GetName() << "\",shape=box]";
  return out.str();
}

void CAstFunctionCall::toDot(ostream &out, int indent) const
{
  string ind(indent, ' ');

  CAstNode::toDot(out, indent);

  for (size_t i=0; i<_arg.size(); i++) {
    _arg[i]->toDot(out, indent);
    out << ind << dotID() << "->" << _arg[i]->dotID() << ";" << endl;
  }
}

CTacAddr* CAstFunctionCall::ToTac(CCodeBlock *cb)
{
  // TODO (phase 4)
  CTacAddr *param;
  CTacConst *index;
  for (int i = GetNArgs() - 1; i >= 0; i--) {
    param = GetArg(i)->ToTac(cb);
    index = new CTacConst(i);
    cb->AddInstr(new CTacInstr(opParam, index, param));
  }

  CTacTemp *ret = NULL;
  if (!GetType()->Match(CTypeManager::Get()->GetNull()))
    ret = cb->CreateTemp(GetType());

  CTacName *funcTac = new CTacName(GetSymbol());
  cb->AddInstr(new CTacInstr(opCall, ret, funcTac));

  return ret;
}

CTacAddr* CAstFunctionCall::ToTac(CCodeBlock *cb,
                                  CTacLabel *ltrue, CTacLabel *lfalse)
{
  // TODO (phase 4)
  const CTypeManager *tm = CTypeManager::Get();
  assert(GetType()->Match(tm->GetBool()));

  CTacAddr *ret = ToTac(cb);
  cb->AddInstr(new CTacInstr(opEqual, ltrue, ret, new CTacConst(1)));
  cb->AddInstr(new CTacInstr(opGoto, lfalse));

  return NULL;
}



//------------------------------------------------------------------------------
// CAstOperand
//
CAstOperand::CAstOperand(CToken t)
  : CAstExpression(t)
{
}


//------------------------------------------------------------------------------
// CAstDesignator
//
CAstDesignator::CAstDesignator(CToken t, const CSymbol *symbol)
  : CAstOperand(t), _symbol(symbol)
{
  assert(symbol != NULL);
}

const CSymbol* CAstDesignator::GetSymbol(void) const
{
  return _symbol;
}

bool CAstDesignator::TypeCheck(CToken *t, string *msg) const
{
  // TODO (phase 3)

  return true;
}

const CType* CAstDesignator::GetType(void) const
{
  return GetSymbol()->GetDataType();
}

const CDataInitializer* CAstDesignator::Evaluate(void) const
{
  // TODO (phase 3)
  // const CDataInitInteger *test = static_cast<const CDataInitInteger*>(_symbol->GetData());
  // cout << test->GetData() << endl;

  // Do we need to fix this? What if data is not initialized?
  const CDataInitializer *symData = _symbol->GetData();
  const CType *symDataType = _symbol->GetDataType();
  if (symDataType->Match(CTypeManager::Get()->GetInt())) {
    const CDataInitInteger *intData = static_cast<const CDataInitInteger*>(symData);
    return new CDataInitInteger(intData->GetData());
  } else if (symDataType->Match(CTypeManager::Get()->GetBool())) {
    const CDataInitBoolean *boolData = static_cast<const CDataInitBoolean*>(symData);
    return new CDataInitBoolean(boolData->GetData());
  } else if (symDataType->Match(CTypeManager::Get()->GetBool())) {
    const CDataInitChar *charData = static_cast<const CDataInitChar*>(symData);
    return new CDataInitChar(charData->GetData());
  } else {
    throw string("CAstDesignator contains non-scalar or compound type.");
  }
}

ostream& CAstDesignator::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << _symbol << " ";

  const CType *t = GetType();
  if (t != NULL) out << t; else out << "<INVALID>";

  out << endl;

  return out;
}

string CAstDesignator::dotAttr(void) const
{
  ostringstream out;
  out << " [label=\"" << _symbol->GetName();
  out << "\",shape=ellipse]";
  return out.str();
}

void CAstDesignator::toDot(ostream &out, int indent) const
{
  string ind(indent, ' ');

  CAstNode::toDot(out, indent);
}

CTacAddr* CAstDesignator::ToTac(CCodeBlock *cb)
{
  // TODO (phase 4)

  return new CTacName(GetSymbol());
}

CTacAddr* CAstDesignator::ToTac(CCodeBlock *cb,
                                CTacLabel *ltrue, CTacLabel *lfalse)
{
  // TODO (phase 4)
  const CTypeManager *tm = CTypeManager::Get();
  assert(GetType()->Match(tm->GetBool()));

  //
  // Below code optimizes IR by evaluating this designator's boolean value
  // and removing unnecessary branches.
  // Maybe use for final presentation?
  // 
  // bool value;
  // const CDataInitializer *dataInit = GetSymbol()->GetData();
  // // Followed g++ behaviour of setting uninitialized booleans to false.
  // if (dataInit == NULL) 
  //   value = false;
  // else 
  //   value = static_cast<const CDataInitBoolean*>(dataInit)->GetData();

  // if (value)
  //   cb->AddInstr(new CTacInstr(opGoto, ltrue));
  // else 
  //   cb->AddInstr(new CTacInstr(opGoto, lfalse));

  //  
  // Below code follows the reference implementation.
  //
  CToken dummy;
  CAstConstant *astConstant = new CAstConstant(dummy, tm->GetBool(), 1);
  CAstBinaryOp *astBinaryOp = new CAstBinaryOp(dummy, opEqual, this, astConstant);
  astBinaryOp->ToTac(cb, ltrue, lfalse);

  return NULL;
}


//------------------------------------------------------------------------------
// CAstArrayDesignator
//
CAstArrayDesignator::CAstArrayDesignator(CToken t, const CSymbol *symbol)
  : CAstDesignator(t, symbol), _done(false), _offset(NULL)
{
}

void CAstArrayDesignator::AddIndex(CAstExpression *idx)
{
  assert(!_done);
  _idx.push_back(idx);
}

void CAstArrayDesignator::IndicesComplete(void)
{
  assert(!_done);
  _done = true;
}

unsigned CAstArrayDesignator::GetNIndices(void) const
{
  return _idx.size();
}

CAstExpression* CAstArrayDesignator::GetIndex(unsigned int index) const
{
  assert((index >= 0) && (index < _idx.size()));
  return _idx[index];
}

bool CAstArrayDesignator::TypeCheck(CToken *t, string *msg) const
{
  // bool result = true;

  assert(_done);

  // TODO (phase 3)
  const CType *typeOfDesig = _symbol->GetDataType();
  const CArrayType *typeOfArray = NULL;
  if (typeOfDesig->IsPointer()) {
    const CPointerType *pointerType = dynamic_cast<const CPointerType*>(typeOfDesig);
    const CType *baseType = pointerType->GetBaseType();
    if (!baseType->IsArray()) {
      if (t != NULL)
        *t = GetToken();
      if (msg != NULL)
        *msg = "an array designator should be of array type or pointer type to an array.";
      return false;
    } else {
      typeOfArray = dynamic_cast<const CArrayType*>(baseType);
    }
  } else if (!typeOfDesig->IsArray()) {
    if (t != NULL)
      *t = GetToken();
    if (msg != NULL)
      *msg = "an array designator should be of array type or pointer type to an array.";
    return false;
  } else {
    typeOfArray = dynamic_cast<const CArrayType*>(typeOfDesig);
  }
  
  if (GetNIndices() > typeOfArray->GetNDim()) {
    if (t != NULL)
      *t = GetToken();
    if (msg != NULL)
      *msg = "more indices specified than the array's actual dimensions.";
    return false;
  }

  for (unsigned int i = 0; i < GetNIndices(); i++) {
    if (!GetIndex(i)->TypeCheck(t, msg))
      return false;

    const CType *typeOfIndex = GetIndex(i)->GetType();
    if (!typeOfIndex->Match(CTypeManager::Get()->GetInt())) {
      if (t != NULL)
        *t = GetToken();
      if (msg != NULL)
        *msg = "index does not evaluate to int";
      return false;
    } 
  }
  
  return true;
}

const CType* CAstArrayDesignator::GetType(void) const
{
  // TODO (phase 3)
  // if t is pointer cas
  const CType *result = _symbol->GetDataType();
  const CArrayType *typeOfArray = NULL;
  for (unsigned int i = 0; i < GetNIndices(); i++) {
    const CPointerType *typeOfPtr = dynamic_cast<const CPointerType*>(result);
    if (typeOfPtr != NULL) {
      const CType *innerType = typeOfPtr->GetBaseType();
      typeOfArray = dynamic_cast<const CArrayType*>(innerType);
    } else {
      typeOfArray = dynamic_cast<const CArrayType*>(result);
    }
    
    result = typeOfArray->GetInnerType();
  }
  
  return result;
}

ostream& CAstArrayDesignator::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << _symbol << " ";

  const CType *t = GetType();
  if (t != NULL) out << t; else out << "<INVALID>";

  out << endl;

  for (size_t i=0; i<_idx.size(); i++) {
    _idx[i]->print(out, indent+2);
  }

  return out;
}

string CAstArrayDesignator::dotAttr(void) const
{
  ostringstream out;
  out << " [label=\"" << _symbol->GetName() << "[]\",shape=ellipse]";
  return out.str();
}

void CAstArrayDesignator::toDot(ostream &out, int indent) const
{
  string ind(indent, ' ');

  CAstNode::toDot(out, indent);

  for (size_t i=0; i<_idx.size(); i++) {
    _idx[i]->toDot(out, indent);
    out << ind << dotID() << "-> " << _idx[i]->dotID() << ";" << endl;
  }
}

CTacAddr* CAstArrayDesignator::ToTac(CCodeBlock *cb)
{
  // TODO (phase 4)
  // For array A[N][M][O], array access A[i][j][k] is equal to
  // A[i * M * O * sizeof(int) + j * O * sizeof(int) + k * sizeof(int)] or
  // A[sizeof(int) * (k + O * (j + M * i))]
  // Therefore we need O and M to be able to compute the memory address of data.
  // We need type information (metadata) to be able to query these at runtime.
  // So the array would look like...
  // NumOfDim + NumOf1stDim + NumOf2ndDim + ... + NumOfNthDim + data0 + data1 + ...
  // This idea is also used in cstdlib's malloc() and free().
  // DOFS(a) can be used to retrieve offset for actual data.
  // In SNUPL the actual memory address would be 
  // A[DOFS(A) + sizeof(int) * (k + O * (j + M * i))]
  // Or rather, 
  // A[DOFS(A) + sizeof(int) * (k + DIM(A, n - 1) * (j + DIM(A, n) * i))]
  //
  // var A: integer[10][12];
  // procedure foo(B:integer[5][7]);
  // var C: integer[2][7];
  // begin
  //   := A[1][1]
  //   := B[1][1]
  //   := C[1][1]
  // ...
  // 
  // B is passed as an argument.
  // By IA32 convention, arguments are passed on the stack.
  // Therefore B[1][1] should be translated to mem[offset + mem[stackpointer4]]
  // which would look something like...
  // t1 := ofs
  // t2 := &B         <-- & is loadmem
  // mem[t1 + t2]     <-- t1 = %eax, t2 = %ebx
  // or...
  // t1 := ofs
  // t2 := &B
  // t3 := t1 + t2
  // mem[t3]          <-- t3 = %eax
  // 
  // For A[1][1]...
  // t1 := ofs,
  // t2 := &A         <-- load effective address
  // t3 := t1 + t2

  // assert(_offset == NULL);
  assert(_done);

  CToken token = GetToken();
  CTypeManager *tm = CTypeManager::Get();
  assert(tm != NULL);

  const CType *t = _symbol->GetDataType();
  if (t->IsPointer()) t = dynamic_cast<const CPointerType*>(t)->GetBaseType();
  const CArrayType *a = dynamic_cast<const CArrayType*>(t);

  // Save the base address of this array.
  CTacAddr *baseAddr = NULL;
  if (_symbol->GetDataType()->IsPointer()) {
    baseAddr = new CTacName(_symbol);
  } else {
    baseAddr = cb->CreateTemp(tm->GetPointer(a));
    cb->AddInstr(new CTacInstr(opAddress, baseAddr, new CTacName(_symbol)));
  }
  
  assert(a != NULL);
  assert(_idx.size() > 0);
  
  CSymtab *st = _symbol->GetSymbolTable();
  assert(st != NULL);

  if (_offset == NULL) {
    // add 0's to the front of array <-- I don't quite understand why added this comment.

    // Get symbols for dim and dofs
    const CSymProc *dofs = dynamic_cast<const CSymProc*>(st->FindSymbol("DOFS"));
    const CSymProc *dim = dynamic_cast<const CSymProc*>(st->FindSymbol("DIM"));

    // create ast nodes
    // make the nodes convert themselves to tac.
    CToken dummy;
    // A[DOFS(A) + sizeof(int) * (k + DIM(A, n - 1) * (j + DIM(A, n) * i))]
    CAstExpression *self = new CAstDesignator(GetToken(), GetSymbol());

    if (!_symbol->GetDataType()->IsPointer())
      self = new CAstSpecialOp(dummy, opAddress, self);

    unsigned int dimension = a->GetNDim();
    CAstExpression *temp = GetIndex(0);
    for (unsigned int i = 1; i < GetNIndices(); i++) {
      CAstFunctionCall *dimCall = new CAstFunctionCall(dummy, dim);
      dimCall->AddArg(self);
      dimCall->AddArg(new CAstConstant(dummy, tm->GetInt(), dimension));
      dimension--;

      CAstBinaryOp *mult = new CAstBinaryOp(dummy, opMul, temp, dimCall);

      temp = new CAstBinaryOp(dummy, opAdd, mult, GetIndex(i));
    }
    
    CAstConstant *bytes4 = new CAstConstant(dummy, tm->GetInt(), 4);
    CAstConstant *bytes1 = new CAstConstant(dummy, tm->GetInt(), 1);
    if (a->GetBaseType()->Match(tm->GetInt()))
      temp = new CAstBinaryOp(dummy, opMul, temp, bytes4);
    else 
      temp = new CAstBinaryOp(dummy, opMul, temp, bytes1);

    CAstFunctionCall *dofsCall = new CAstFunctionCall(dummy, dofs);
    dofsCall->AddArg(self);

    // calculate _offset
    _offset = new CAstBinaryOp(dummy, opAdd, temp, dofsCall);
  }
  assert(_offset != NULL);
  
  // convert to TAC
  CTacAddr *offsetAddr = _offset->ToTac(cb);
  CTacTemp *dataAddr = cb->CreateTemp(tm->GetInt());
  cb->AddInstr(new CTacInstr(opAdd, dataAddr, baseAddr, offsetAddr));

  // if pointer make special op <-- TODO: Not sure about this.

  // return new CTacReference
  return new CTacReference(dataAddr->GetSymbol(), _symbol);
}

CTacAddr* CAstArrayDesignator::ToTac(CCodeBlock *cb,
                                     CTacLabel *ltrue, CTacLabel *lfalse)
{
  // TODO (phase 4)
  const CTypeManager *tm = CTypeManager::Get();
  assert(GetType()->Match(tm->GetBool()));

  CTacAddr *selfAddr = ToTac(cb);
  CTacReference *selfReference = dynamic_cast<CTacReference *>(selfAddr);

  // CTacTemp *temp = cb->CreateTemp(tm->GetBool());
  // CTacName *derefName = new CTacName(selfReference->GetDerefSymbol());
  // cb->AddInstr(new CTacInstr(opDeref, temp, derefName));
  cb->AddInstr(new CTacInstr(opEqual, ltrue, selfReference, new CTacConst(1)));
  cb->AddInstr(new CTacInstr(opGoto, lfalse));

  return NULL;
}


//------------------------------------------------------------------------------
// CAstConstant
//
CAstConstant::CAstConstant(CToken t, const CType *type, long long value)
  : CAstOperand(t), _type(type), _value(value)
{
}

void CAstConstant::SetValue(long long value)
{
  _value = value;
}

long long CAstConstant::GetValue(void) const
{
  return _value;
}

string CAstConstant::GetValueStr(void) const
{
  ostringstream out;

  if (GetType() == CTypeManager::Get()->GetBool()) {
    out << (_value == 0 ? "false" : "true");
  } else {
    out << dec << _value;
  }

  return out.str();
}

bool CAstConstant::TypeCheck(CToken *t, string *msg) const
{
  // TODO (phase 3)
  if (GetType()->Match(CTypeManager::Get()->GetInt())) {
    if (GetValue() > INT_MAX || GetValue() < INT_MIN) {
      if (t != NULL)
        *t = GetToken();
      if (msg != NULL)
        *msg = "integer out of bounds.";
      return false;
    }
  } else if (GetType()->Match(CTypeManager::Get()->GetBool())) {
    if (GetValue() != 0 && GetValue() != 1) {
      if (t != NULL)
        *t = GetToken();
      if (msg != NULL)
        *msg = "snuplc internal error: boolean is not 0 or 1.";
      return false;
    }
  } else if (GetType()->Match(CTypeManager::Get()->GetChar())) {
    if (GetValue() < -128 || GetValue() >= 127) {
      if (t != NULL)
        *t = GetToken();
      if (msg != NULL)
        *msg = "snuplc internal error: char out of bounds.";
      return false;
    }
  } else {
    if (t != NULL)
      *t = GetToken();
    if (msg != NULL)
      *msg = "snuplc internal error: constant should not be of a compound type.";
    return false;
  }

  return true;
}

const CType* CAstConstant::GetType(void) const
{
  return _type;
}

const CDataInitializer* CAstConstant::Evaluate(void) const
{
  // TODO (phase 3)
  //I think we need to consider integer bound here
  // Maybe at TypeCheck?
  if (GetType()->Match(CTypeManager::Get()->GetInt())) {
    return new CDataInitInteger(GetValue());
  } else if (GetType()->Match(CTypeManager::Get()->GetBool())) {
    const bool value = GetValue() == 0 ? false : true;
    return new CDataInitBoolean(value);
  } else if (GetType()->Match(CTypeManager::Get()->GetChar())) {
    return new CDataInitChar(GetValue());
  } else {
    return NULL;
    // throw string("snuplc internal error: compound type found in constants while evaluating expressions");
  }
}

ostream& CAstConstant::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << GetValueStr() << " ";

  const CType *t = GetType();
  if (t != NULL) out << t; else out << "<INVALID>";

  out << endl;

  return out;
}

string CAstConstant::dotAttr(void) const
{
  ostringstream out;
  out << " [label=\"" << GetValueStr() << "\",shape=ellipse]";
  return out.str();
}

CTacAddr* CAstConstant::ToTac(CCodeBlock *cb)
{
  // TODO (phase 4)

  return new CTacConst(GetValue());
}

CTacAddr* CAstConstant::ToTac(CCodeBlock *cb,
                                CTacLabel *ltrue, CTacLabel *lfalse)
{
  // TODO (phase 4)
  const CTypeManager *tm = CTypeManager::Get();
  assert(GetType()->Match(tm->GetBool()));

  bool value = GetValue();

  if (value)
    cb->AddInstr(new CTacInstr(opGoto, ltrue));
  else 
    cb->AddInstr(new CTacInstr(opGoto, lfalse));

  return NULL;
}


//------------------------------------------------------------------------------
// CAstStringConstant
//
int CAstStringConstant::_idx = 0;

CAstStringConstant::CAstStringConstant(CToken t, const string value,
                                       CAstScope *s)
  : CAstOperand(t)
{
  CTypeManager *tm = CTypeManager::Get();
  CSymtab *st = s->GetSymbolTable();

  _type = tm->GetArray(strlen(CToken::unescape(value).c_str())+1,
                       tm->GetChar());
  _value = new CDataInitString(value);

  // in case of name clashes we simply iterate until we find a
  // name that has not yet been used
  _sym = NULL;
  do {
    ostringstream o;
    o << "_str_" << ++_idx;
    if (st->FindSymbol(o.str(), sGlobal) == NULL) {
      _sym = new CSymGlobal(o.str(), _type);
    }
  } while (_sym == NULL);

  _sym->SetData(_value);
  st->AddSymbol(_sym);
}

const string CAstStringConstant::GetValue(void) const
{
  return _value->GetData();
}

const string CAstStringConstant::GetValueStr(void) const
{
  return GetValue();
}

bool CAstStringConstant::TypeCheck(CToken *t, string *msg) const
{
  return true;
}

const CType* CAstStringConstant::GetType(void) const
{
  // TODO (phase 3)
  return _sym->GetDataType();
}

const CDataInitializer* CAstStringConstant::Evaluate(void) const
{
  // TODO (phase 3)
  // just return the pointer to the global variable
  // Should we return symbol's data or private member _value?

  return _sym->GetData();
  // return _value;
}

ostream& CAstStringConstant::print(ostream &out, int indent) const
{
  string ind(indent, ' ');

  out << ind << '"' << GetValueStr() << '"' << " ";

  const CType *t = GetType();
  if (t != NULL) out << t; else out << "<INVALID>";

  out << endl;

  return out;
}

string CAstStringConstant::dotAttr(void) const
{
  ostringstream out;
  // the string is already escaped, but dot requires double escaping
  out << " [label=\"\\\"" << CToken::escape(tStringConst, GetValueStr())
      << "\\\"\",shape=ellipse]";
  return out.str();
}

CTacAddr* CAstStringConstant::ToTac(CCodeBlock *cb)
{
  // TODO (phase 4)

  return new CTacName(_sym);
}

CTacAddr* CAstStringConstant::ToTac(CCodeBlock *cb,
                                CTacLabel *ltrue, CTacLabel *lfalse)
{
  // TODO (phase 4)
  // TODO: need to work on this.

  return NULL;
}


