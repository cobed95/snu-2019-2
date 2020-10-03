//------------------------------------------------------------------------------
/// @brief SnuPL backend
/// @author Bernhard Egger <bernhard@csap.snu.ac.kr>
/// @section changelog Change Log
/// 2012/11/28 Bernhard Egger created
/// 2013/06/09 Bernhard Egger adapted to SnuPL/0
/// 2016/04/04 Bernhard Egger adapted to SnuPL/1
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
/// ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER  OR CONTRIBUTORS BE
/// LIABLE FOR ANY DIRECT,  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSE-
/// QUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF  SUBSTITUTE
/// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
/// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT
/// LIABILITY, OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE)  ARISING IN ANY WAY
/// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
/// DAMAGE.
//------------------------------------------------------------------------------

#include <fstream>
#include <sstream>
#include <iomanip>
#include <cassert>

#include "backend.h"
using namespace std;


//------------------------------------------------------------------------------
// CBackend
//
CBackend::CBackend(ostream &out)
  : _out(out)
{
}

CBackend::~CBackend(void)
{
}

bool CBackend::Emit(CModule *m)
{
  assert(m != NULL);
  _m = m;

  if (!_out.good()) return false;

  bool res = true;

  try {
    EmitHeader();
    EmitCode();
    EmitData();
    EmitFooter();

    res = _out.good();
  } catch (...) {
    res = false;
  }

  return res;
}

void CBackend::EmitHeader(void)
{
}

void CBackend::EmitCode(void)
{
}

void CBackend::EmitData(void)
{
}

void CBackend::EmitFooter(void)
{
}


//------------------------------------------------------------------------------
// CBackendx86
//
CBackendx86::CBackendx86(ostream &out)
  : CBackend(out), _curr_scope(NULL)
{
  _ind = string(4, ' ');
}

CBackendx86::~CBackendx86(void)
{
}

void CBackendx86::EmitHeader(void)
{
  _out << "##################################################" << endl
       << "# " << _m->GetName() << endl
       << "#" << endl
       << endl;
}

void CBackendx86::EmitCode(void)
{
  _out << _ind << "#-----------------------------------------" << endl
       << _ind << "# text section" << endl
       << _ind << "#" << endl
       << _ind << ".text" << endl
       << _ind << ".align 4" << endl
       << endl
       << _ind << "# entry point and pre-defined functions" << endl
       << _ind << ".global main" << endl
       << _ind << ".extern DIM" << endl
       << _ind << ".extern DOFS" << endl
       << _ind << ".extern ReadInt" << endl
       << _ind << ".extern WriteInt" << endl
       << _ind << ".extern WriteStr" << endl
       << _ind << ".extern WriteChar" << endl
       << _ind << ".extern WriteLn" << endl
       << endl;

  // TODO
  // forall s in subscopes do
  //   EmitScope(s)
  // EmitScope(program)
  assert(_m != NULL);
  SetScope(_m);
  CScope* scope = GetScope();
  const vector<CScope*> subscopes = scope->GetSubscopes();
  vector<CScope*>::const_iterator it = subscopes.begin();
  while (it != subscopes.end()) 
    EmitScope(*it++);
  EmitScope(scope);

  _out << _ind << "# end of text section" << endl
       << _ind << "#-----------------------------------------" << endl
       << endl;
}

void CBackendx86::EmitData(void)
{
  _out << _ind << "#-----------------------------------------" << endl
       << _ind << "# global data section" << endl
       << _ind << "#" << endl
       << _ind << ".data" << endl
       << _ind << ".align 4" << endl
       << endl;

  EmitGlobalData(_m);

  _out << _ind << "# end of global data section" << endl
       << _ind << "#-----------------------------------------" << endl
       << endl;
}

void CBackendx86::EmitFooter(void)
{
  _out << _ind << ".end" << endl
       << "##################################################" << endl;
}

void CBackendx86::SetScope(CScope *scope)
{
  _curr_scope = scope;
}

CScope* CBackendx86::GetScope(void) const
{
  return _curr_scope;
}

void CBackendx86::EmitScope(CScope *scope)
{
  assert(scope != NULL);
  SetScope(scope);

  string label;

  if (scope->GetParent() == NULL) label = "main";
  else label = scope->GetName();
  SetScope(scope);

  // label
  _out << _ind << "# scope " << scope->GetName() << endl
       << label << ":" << endl;

  // TODO
  // ComputeStackOffsets(scope)
  //
  // emit function prologue
  //
  // forall i in instructions do
  //   EmitInstruction(i)
  //
  // emit function epilogue

  // TODO: 0's are arbitrary integers. They need change.
  size_t stackSize = ComputeStackOffsets(scope->GetSymbolTable(), 8, -12);
  
  CSymtab *st = scope->GetSymbolTable();
  vector<CSymbol*> symbols = st->GetSymbols();
  vector<CSymbol*>::const_iterator it = symbols.begin();
  const CSymConstant *symConst = NULL;
  _out << _ind << "# stack offsets:" << endl;
  while (it != symbols.end()) {
    if ((*it)->GetSymbolType() == stGlobal ||
        (*it)->GetSymbolType() == stReserved ||
        (*it)->GetSymbolType() == stProcedure ||
        (symConst = dynamic_cast<const CSymConstant*>(*it)) != NULL) {
      it++;
      continue;
    }
    _out << _ind << "# " 
         << right << setw(6) 
         << (*it)->GetOffset() << "(" << (*it)->GetBaseRegister() << ")"
         << setw(4)
         << (*it)->GetDataType()->GetSize() <<  "  " << (*it)
         << endl;
    it++;
  }

  // Function prologue emission.
  _out << endl;
  _out << _ind << "# prologue" << endl;
  EmitInstruction("pushl", "%ebp");
  EmitInstruction("movl", "%esp, %ebp");

  string cmt = "save callee saved registers";
  EmitInstruction("pushl", "%ebx", cmt);
  EmitInstruction("pushl", "%esi");
  EmitInstruction("pushl", "%edi");
  cmt = "make room for locals";
  EmitInstruction("subl", Imm(stackSize) + ", %esp", cmt);


  int n = stackSize / 4;
  if (n > 0) {
    _out << endl;
    cmt = "memset local stack area to 0";
    if (n <= 4) {
      EmitInstruction("xorl", "%eax, %eax", cmt);
      int offset = stackSize - 4;
      ostringstream stream;
      string args;
      while (offset >= 0) {
        stream << "%eax, " << offset << "(%esp)";
        args = stream.str();
        EmitInstruction("movl", args);
        stream.str("");
        stream.clear();
        offset -= 4;
      }
    } else {
      EmitInstruction("cld", "", cmt);
      EmitInstruction("xorl", "%eax, %eax");
      EmitInstruction("movl", Imm(n) + ", %ecx");
      EmitInstruction("mov", "%esp, %edi");
      EmitInstruction("rep", "stosl");
    }
  }
  
  // Local data emission.
  EmitLocalData(scope);

  // Function body emission.
  _out << endl;
  _out << _ind << "# function body" << endl;
  EmitCodeBlock(scope->GetCodeBlock());

  // Function epilogue emission.
  _out << endl;
  _out << Label("exit") << ":" << endl;
  _out << _ind << "# epilogue" << endl;
  EmitInstruction("addl", Imm(stackSize) + ", %esp", "remove locals");
  EmitInstruction("popl", "%edi");
  EmitInstruction("popl", "%esi");
  EmitInstruction("popl", "%ebx");
  EmitInstruction("popl", "%ebp");
  EmitInstruction("ret");

  _out << endl;
}

void CBackendx86::EmitGlobalData(CScope *scope)
{
  assert(scope != NULL);

  // emit the globals for the current scope
  CSymtab *st = scope->GetSymbolTable();
  assert(st != NULL);

  bool header = false;

  vector<CSymbol*> slist = st->GetSymbols();

  _out << dec;

  size_t size = 0;

  for (size_t i=0; i<slist.size(); i++) {
    CSymbol *s = slist[i];

    // filter out constant symbols
    if (dynamic_cast<CSymConstant*>(s) != NULL) continue;

    const CType *t = s->GetDataType();

    if (s->GetSymbolType() == stGlobal) {
      if (!header) {
        _out << _ind << "# scope: " << scope->GetName() << endl;
        header = true;
      }

      // insert alignment only when necessary
      if ((t->GetAlign() > 1) && (size % t->GetAlign() != 0)) {
        size += t->GetAlign() - size % t->GetAlign();
        _out << setw(4) << " " << ".align "
             << right << setw(3) << t->GetAlign() << endl;
      }

      _out << left << setw(36) << s->GetName() + ":" << "# " << t << endl;

      if (t->IsArray()) {
        const CArrayType *a = dynamic_cast<const CArrayType*>(t);
        assert(a != NULL);
        int dim = a->GetNDim();

        _out << setw(4) << " "
          << ".long " << right << setw(4) << dim << endl;

        for (int d=0; d<dim; d++) {
          assert(a != NULL);

          _out << setw(4) << " "
            << ".long " << right << setw(4) << a->GetNElem() << endl;

          a = dynamic_cast<const CArrayType*>(a->GetInnerType());
        }
      }

      const CDataInitializer *di = s->GetData();
      if (di != NULL) {
        const CDataInitString *sdi = dynamic_cast<const CDataInitString*>(di);
        assert(sdi != NULL);  // only support string data initializers for now

        _out << left << setw(4) << " "
          << ".asciz " << '"' << sdi->GetData() << '"' << endl;
      } else {
        _out  << left << setw(4) << " "
          << ".skip " << dec << right << setw(4) << t->GetDataSize()
          << endl;
      }

      size += t->GetSize();
    }
  }

  _out << endl;

  // emit globals in subscopes (necessary if we support static local variables)
  vector<CScope*>::const_iterator sit = scope->GetSubscopes().begin();
  while (sit != scope->GetSubscopes().end()) EmitGlobalData(*sit++);
}

void CBackendx86::EmitLocalData(CScope *scope)
{
  assert(scope != NULL);

  // TODO
  // emit the variables for the current scope

  if (scope->GetParent() == NULL)
    return;

  CSymtab *st = scope->GetSymbolTable();
  vector<CSymbol*> symbols = st->GetSymbols();

  vector<CSymbol*>::const_iterator it = symbols.begin();
  while (it != symbols.end()) {
    const CSymConstant *symConst = dynamic_cast<const CSymConstant*>(*it);
    if (symConst != NULL) {
      it++;
      continue;
    }

    const CType* type = (*it)->GetDataType();
    if (type->IsArray()) {
      const CArrayType* arrayType = dynamic_cast<const CArrayType*>(type);

      string mnm = "movl";
      int value = arrayType->GetNDim();
      int offset = (*it)->GetOffset();
      ostringstream stream;
      stream << offset << "(" << (*it)->GetBaseRegister() << ")";
      string dst = stream.str();
      stream.str("");
      stream.clear();
      stream << "local array \'" << (*it)->GetName() << "\': "
             << value << " dimensions";
      string cmt = stream.str();
      EmitInstruction(mnm, Imm(value) + "," + dst, cmt);

      int ndim = value;
      for (int i = 0; i < ndim; i++) {
        value = arrayType->GetNElem();
        offset += 4;

        stream.str("");
        stream.clear();
        stream << offset << "(" << (*it)->GetBaseRegister() << ")";
        dst = stream.str();

        stream.str("");
        stream.clear();
        stream << "  dimension " << i + 1 << ": " << value << " elements";
        cmt = stream.str();
        EmitInstruction(mnm, Imm(value) + "," + dst, cmt);
      }
    }
    it++;
  }
}

void CBackendx86::EmitCodeBlock(CCodeBlock *cb)
{
  assert(cb != NULL);

  const list<CTacInstr*> &instr = cb->GetInstr();
  list<CTacInstr*>::const_iterator it = instr.begin();

  while (it != instr.end()) EmitInstruction(*it++);
}

void CBackendx86::EmitInstruction(CTacInstr *i)
{
  assert(i != NULL);

  ostringstream cmt;
  string mnm;
  cmt << i;

  EOperation op = i->GetOperation();

  CTacAddr *src1 = NULL;
  CTacAddr *src2 = NULL;
  CTac *dst = NULL;

  CTacReference *tacRef = NULL;
  ostringstream refStream;

  CTacName *funcName = NULL;
  unsigned int nparams;
  int stackSize;
  const CSymProc *symProc = NULL;

  switch (op) {
    // binary operators
    // dst = src1 op src2
    // TODO
    case opAdd:
      src1 = i->GetSrc(1);
      src2 = i->GetSrc(2);
      dst = i->GetDest();
      mnm = "addl";

      Load(src1, "%eax", cmt.str());
      Load(src2, "%ebx");
      EmitInstruction(mnm, "%ebx, %eax");
      Store(dst, 'a');
      break;
    case opSub:
      src1 = i->GetSrc(1);
      src2 = i->GetSrc(2);
      dst = i->GetDest();
      mnm = "subl";

      Load(src1, "%eax", cmt.str());
      Load(src2, "%ebx");
      EmitInstruction(mnm, "%ebx, %eax");
      Store(dst, 'a');
      break;
    case opMul:
      src1 = i->GetSrc(1);
      src2 = i->GetSrc(2);
      dst = i->GetDest();
      mnm = "imull";

      Load(src1, "%eax", cmt.str());
      Load(src2, "%ebx");
      EmitInstruction(mnm, "%ebx");
      Store(dst, 'a');
      break;
    case opDiv:
      src1 = i->GetSrc(1);
      src2 = i->GetSrc(2);
      dst = i->GetDest();
      mnm = "cdq";

      Load(src1, "%eax", cmt.str());
      Load(src2, "%ebx");
      EmitInstruction(mnm);

      mnm = "idivl";
      EmitInstruction(mnm, "%ebx");
      Store(dst, 'a');
      break;
    case opAnd:
      src1 = i->GetSrc(1);
      src2 = i->GetSrc(2);
      dst = i->GetDest();
      mnm = "andl";

      Load(src1, "%eax", cmt.str());
      Load(src2, "%ebx");
      EmitInstruction(mnm, "%ebx, %eax");
      Store(dst, 'a');
      break;
    case opOr:
      src1 = i->GetSrc(1);
      src2 = i->GetSrc(2);
      dst = i->GetDest();
      mnm = "orl";

      Load(src1, "%eax", cmt.str());
      Load(src2, "%ebx");
      EmitInstruction(mnm, "%ebx, %eax");
      Store(dst, 'a');
      break;

    // unary operators
    // dst = op src1
    // TODO
    case opNeg:
      src1 = i->GetSrc(1);
      dst = i->GetDest();
      mnm = "negl";

      Load(src1, "%eax", cmt.str());
      EmitInstruction(mnm, "%eax");
      Store(dst, 'a');
      break;
    case opPos:
      src1 = i->GetSrc(1);
      dst = i->GetDest();
      
      Load(src1, "%eax", cmt.str());
      Store(dst, 'a');
      break;
    case opNot:
      src1 = i->GetSrc(1);
      dst = i->GetDest();
      mnm = "notl";

      Load(src1, "%eax", cmt.str());
      EmitInstruction(mnm, "%eax");
      Store(dst, 'a');
      break;

    // memory operations
    // dst = src1
    // TODO
    case opAssign:
      src1 = i->GetSrc(1);
      dst = i->GetDest();
      
      Load(src1, "%eax", cmt.str());

      // tacRef = dynamic_cast<CTacReference*>(dst);
      // if (tacRef != NULL) {
      //   mnm = "movl";
        
      //   tacRef->GetSymbol()->GetBaseRegister();
      //   refStream.str("");
      //   refStream.clear();
      //   refStream << tacRef->GetSymbol()->GetOffset() 
      //             << "(" << tacRef->GetSymbol()->GetBaseRegister() << ")";
      //   EmitInstruction(mnm, refStream.str() + ", %edi");
      //   // Load(tacRef, "%edi");
      //   // EmitInstruction(mnm, "%eax, (%edi)");
      // } 
      
      Store(dst, 'a');

      break;

    // pointer operations
    // dst = &src1
    case opAddress:
      src1 = i->GetSrc(1);
      dst = i->GetDest();
      mnm = "leal";

      EmitInstruction(mnm, Operand(src1) + ", %eax", cmt.str());

      // Load(src1, "%ebx", cmt.str());
      // EmitInstruction(mnm, "(%ebx), %eax");
      Store(dst, 'a');
      break;
    // TODO
    // dst = *src1
    case opDeref:
      // opDeref not generated for now
      EmitInstruction("# opDeref", "not implemented", cmt.str());
      break;
    case opCast:
      EmitInstruction("# opCast", "not implemented", cmt.str());
      break;

    // unconditional branching
    // goto dst
    // TODO
    case opGoto:
      dst = i->GetDest();
      mnm = "jmp";

      EmitInstruction(mnm, Operand(dst), cmt.str());
      break;

    // conditional branching
    // if src1 relOp src2 then goto dst
    // TODO
    case opEqual:
    case opNotEqual:
    case opLessThan:
    case opLessEqual:
    case opBiggerThan:
    case opBiggerEqual:
      src1 = i->GetSrc(1);
      src2 = i->GetSrc(2);
      dst = i->GetDest();
      mnm = "cmpl";

      Load(src1, "%eax", cmt.str());
      Load(src2, "%ebx");
      EmitInstruction(mnm, "%ebx, %eax");

      mnm = "j" + Condition(op);
      EmitInstruction(mnm, Operand(dst));
      break;

    // function call-related operations
    // TODO
    case opCall:
      src1 = i->GetSrc(1);
      dst = i->GetDest();
      mnm = "call";
      funcName = dynamic_cast<CTacName*>(src1);

      EmitInstruction(mnm, funcName->GetSymbol()->GetName(), cmt.str());

      symProc = dynamic_cast<const CSymProc*>(funcName->GetSymbol());
      nparams = symProc->GetNParams();
      mnm = "addl";
      stackSize = nparams * 4;
      // for (unsigned int i = 0; i < nparams; i++)
        // stackSize += 4;
        // stackSize += symProc->GetParam(i)->GetDataType()->GetAlign();
      if (stackSize!=0) EmitInstruction(mnm, Imm(stackSize) + ", %esp");

      if (!funcName->GetSymbol()->GetDataType()->Match(CTypeManager::Get()->GetNull()))
        Store(dst, 'a');
      break;
    case opReturn:
      src1 = i->GetSrc(1);
      mnm = "jmp";

      if (src1 != NULL) {
        Load(src1, "%eax", cmt.str());
        EmitInstruction(mnm, Label("exit"));
      } else {
        EmitInstruction(mnm, Label("exit"), cmt.str());
      }
      break;
    case opParam:
      src1 = i->GetSrc(1);

      // tacRef = dynamic_cast<CTacReference*>(src1);
      // if (tacRef != NULL) {
      //   mnm = "movl";
      //   refStream.str("");
      //   refStream.clear();
      //   refStream << tacRef->GetSymbol()->GetOffset()
      //             << "(" << tacRef->GetSymbol()->GetBaseRegister() << ")";
      //   EmitInstruction(mnm, refStream.str() + ", %edi");
      //   // EmitInstruction(mnm, "(%edi), %eax", cmt.str());
      // } 
      
      Load(src1, "%eax", cmt.str());
      mnm = "pushl";
      EmitInstruction(mnm, "%eax");
      break;

    // special
    case opLabel:
      _out << Label(dynamic_cast<CTacLabel*>(i)) << ":" << endl;
      break;

    case opNop:
      EmitInstruction("nop", "", cmt.str());
      break;


    default:
      EmitInstruction("# ???", "not implemented", cmt.str());
  }
}

void CBackendx86::EmitInstruction(string mnemonic, string args, string comment)
{
  _out << left
       << _ind
       << setw(7) << mnemonic << " "
       << setw(23) << args;
  if (comment != "") _out << " # " << comment;
  _out << endl;
}

void CBackendx86::Load(CTacAddr *src, string dst, string comment)
{
  assert(src != NULL);

  string mnm = "mov";
  string mod = "l";

  // set operator modifier based on the operand size
  switch (OperandSize(src)) {
    case 1: mod = "zbl"; break;
    case 2: mod = "zwl"; break;
    case 4: mod = "l"; break;
  }

  // emit the load instruction
  EmitInstruction(mnm + mod, Operand(src) + ", " + dst, comment);
}

void CBackendx86::Store(CTac *dst, char src_base, string comment)
{
  assert(dst != NULL);

  string mnm = "mov";
  string mod = "l";
  string src = "%";

  // compose the source register name based on the operand size
  switch (OperandSize(dst)) {
    case 1: mod = "b"; src += string(1, src_base) + "l"; break;
    case 2: mod = "w"; src += string(1, src_base) + "x"; break;
    case 4: mod = "l"; src += "e" + string(1, src_base) + "x"; break;
  }

  // emit the store instruction
  EmitInstruction(mnm + mod, src + ", " + Operand(dst), comment);
}

string CBackendx86::Operand(const CTac *op)
{
  assert(op != NULL);
  string operand;

  // TODO
  // return a string representing op
  // hint: take special care of references (op of type CTacReference)

  // type CTac = CTacAddr
  //           | CTacInstr
  // and CTacAddr = CTacConst 
  //              | CTacName
  // and CTacName = CTacReference
  //              | CTacTemp
  // and CTacInstr = instr
  //               | CTacLabel
  const CTacInstr *tacInstr = dynamic_cast<const CTacInstr*>(op);
  const CTacAddr *tacAddr = dynamic_cast<const CTacAddr*>(op);

  if (tacInstr != NULL) {
    const CTacLabel *tacLabel = dynamic_cast<const CTacLabel*>(op);
    // Non-label instructions cannot be an operand.
    assert(tacLabel != NULL);
    operand = Label(tacLabel);
  } else if (tacAddr != NULL) {
    const CTacConst *tacConst = dynamic_cast<const CTacConst*>(op);
    const CTacName *tacName = dynamic_cast<const CTacName*>(op);

    if (tacConst != NULL) {
      operand = Imm(tacConst->GetValue());
    } else if (tacName != NULL) {
      const CTacReference *tacReference = dynamic_cast<const CTacReference*>(op);

      if (tacReference != NULL) {
        // TODO: take special care.
        // const CSymbol *sym = tacReference->GetDerefSymbol();
        const CSymbol *sym = tacReference->GetSymbol();
        ostringstream stream;
        stream << sym->GetOffset() << "(" << sym->GetBaseRegister() << ")";
        EmitInstruction("movl", stream.str() + ", %edi");
        operand = "(%edi)";
      } else {
        // CTacTemp behaves exactly like CTacName
        const CSymbol *sym = tacName->GetSymbol();
        ostringstream stream;
        switch (sym->GetSymbolType()) {
          case stGlobal:
            operand = sym->GetName();
            break;
          default:
            // TODO: contemplation required...
            stream << sym->GetOffset() << "(" << sym->GetBaseRegister() << ")";
            operand = stream.str();
            break;
        }
      }
    } else {
      assert(false);
    }
  } else {
    assert(false);
  }

  return operand;
}

string CBackendx86::Imm(int value) const
{
  ostringstream o;
  o << "$" << dec << value;
  return o.str();
}

string CBackendx86::Label(const CTacLabel* label) const
{
  CScope *cs = GetScope();
  assert(cs != NULL);

  ostringstream o;
  o << "l_" << cs->GetName() << "_" << label->GetLabel();
  return o.str();
  return "l_" + cs->GetName() + "_" + label->GetLabel();
}

string CBackendx86::Label(string label) const
{
  CScope *cs = GetScope();
  assert(cs != NULL);

  return "l_" + cs->GetName() + "_" + label;
}

string CBackendx86::Condition(EOperation cond) const
{
  switch (cond) {
    case opEqual:       return "e";
    case opNotEqual:    return "ne";
    case opLessThan:    return "l";
    case opLessEqual:   return "le";
    case opBiggerThan:  return "g";
    case opBiggerEqual: return "ge";
    default:            assert(false); break;
  }
}

int CBackendx86::OperandSize(CTac *t) const
{
  int size = 4;

  // TODO
  // compute the size for operand t of type CTacName
  // Hint: you need to take special care of references (incl. references to pointers!)
  //       and arrays. Compare your output to that of the reference implementation
  //       if you are not sure.
  CTacReference *tacReference = dynamic_cast<CTacReference*>(t);
  if (tacReference != NULL) {
    const CSymbol *derefSym = tacReference->GetDerefSymbol();
    const CType *derefType = derefSym->GetDataType();

    if (derefType->IsPointer()) {
      const CPointerType *pointerType = dynamic_cast<const CPointerType*>(derefType);
      derefType = pointerType->GetBaseType();
    }

    const CArrayType *arrayType = dynamic_cast<const CArrayType*>(derefType);
    if (arrayType != NULL)
      return arrayType->GetBaseType()->GetSize();
    else
      return derefType->GetSize();
  }
  CTacName *tacName = dynamic_cast<CTacName*>(t);
  if (tacName == NULL)
    return size;

  const CSymbol *sym = tacName->GetSymbol();
  const CType *type = sym->GetDataType();

  // if (type->IsPointer()) {
    // const CPointerType *pointerType = dynamic_cast<const CPointerType*>(type);
    // size = pointerType->GetBaseType()->GetSize();
  // } else {
  size = type->GetSize();
  // }

  return size;
}

size_t CBackendx86::ComputeStackOffsets(CSymtab *symtab,
                                        int param_ofs,int local_ofs)
{
  // TODO
  // foreach local symbol l in slist do
  //   compute aligned offset on stack and store in symbol l
  //   set base register to %ebp
  //
  // foreach parameter p in slist do
  //   compute offset on stack and store in symbol p
  //   set base register to %ebp
  //
  // align size
  //
  // dump stack frame to assembly file

  assert(symtab != NULL);
  vector<CSymbol*> slist = symtab->GetSymbols();

  size_t size;
  int localOffsetCount = local_ofs;
  int dSize;

  for (size_t i=0; i<slist.size(); i++) {
    CSymbol *s = slist[i];
    
    if (s->GetSymbolType() == stParam) {
      CSymParam *p = dynamic_cast<CSymParam*>(s);
      p -> SetBaseRegister("%ebp");
      p -> SetOffset(param_ofs + (p->GetIndex())*4 );
    }
    else if (s->GetSymbolType() == stLocal) {
      CSymConstant *c = dynamic_cast<CSymConstant*>(s);
      if (c!=NULL) continue;

      dSize = s -> GetDataType() -> GetSize();
      s -> SetBaseRegister("%ebp");

      if ((dSize <= 1) || (dSize%4 == (localOffsetCount%4+4)))  localOffsetCount -= dSize;
      else if ((dSize%4==0) && (localOffsetCount%4==0)) localOffsetCount -= dSize;
      else localOffsetCount = ((localOffsetCount - dSize -4)/4)*4;
      
      s->SetOffset(localOffsetCount);

    }
  }

  if (localOffsetCount%4 == 0) {
    size = -localOffsetCount -12;
  }
  else {
    size = -((localOffsetCount-4)/4)*4 -12;
  }

  return size;
}
