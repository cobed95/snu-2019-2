//------------------------------------------------------------------------------
/// @brief SnuPL/1 scanner
/// @author Bernhard Egger <bernhard@csap.snu.ac.kr>
/// @section changelog Change Log
/// 2012/09/14 Bernhard Egger created
/// 2013/03/07 Bernhard Egger adapted to SnuPL/0
/// 2014/09/10 Bernhard Egger assignment 1: scans SnuPL/-1
/// 2016/03/11 Bernhard Egger adapted to SnuPL/1
/// 2016/03/13 Bernhard Egger assignment 1: adapted to modified SnuPL/-1 syntax
/// 2017/09/22 Bernhard Egger fixed implementation of strings and characters
/// 2019/09/13 Bernhard Egger added const token, better string/char handling
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
#include <sstream>
#include <cctype>
#include <cstdlib>
#include <cstring>
#include <cassert>
#include <cstdio>

#include "scanner.h"
using namespace std;

//------------------------------------------------------------------------------
// token names
//
#define TOKEN_STRLEN 24

char ETokenName[][TOKEN_STRLEN] = {
  "tIdent",                           ///< ident
  "tNumber",                          ///< number
  "tBoolConst",                       ///< boolean constant
  "tCharConst",                       ///< character constant
  "tStringConst",                     ///< string constant
  "tPlusMinus",                       ///< '+' or '-'
  "tMulDiv",                          ///< '*' or '/'
  "tOr",                              ///< '||'
  "tAnd",                             ///< '&&'
  "tNot",                             ///< '!'
  "tRelOp",                           ///< relational operator
  "tAssign",                          ///< assignment operator
  "tComma",                           ///< a comma
  "tSemicolon",                       ///< a semicolon
  "tColon",                           ///< a colon
  "tDot",                             ///< a dot
  "tLParens",                         ///< a left parenthesis
  "tRParens",                         ///< a right parenthesis
  "tLBrak",                           ///< a left bracket
  "tRBrak",                           ///< a right bracket

  "tModule",                          ///< 'module'
  "tProcedure",                       ///< 'procedure'
  "tFunction",                        ///< 'function'
  "tVarDecl",                         ///< 'var'
  "tConstDecl",                       ///< 'const'
  "tInteger",                         ///< 'integer'
  "tBoolean",                         ///< 'boolean'
  "tChar",                            ///< 'char'
  "tBegin",                           ///< 'begin'
  "tEnd",                             ///< 'end'
  "tIf",                              ///< 'if'
  "tThen",                            ///< 'then'
  "tElse",                            ///< 'else'
  "tWhile",                           ///< 'while'
  "tDo",                              ///< 'do'
  "tReturn",                          ///< 'return'

  "tComment",                         ///< comment ('// .... \n')
  "tEOF",                             ///< end of file
  "tIOError",                         ///< I/O error
  "tInvCharConst",                    ///< invalid character constant
  "tInvStringConst",                  ///< invalid string constant
  "tUndefined",                       ///< undefined
};


//------------------------------------------------------------------------------
// format strings used for printing tokens
//

char ETokenStr[][TOKEN_STRLEN] = {
  "tIdent (%s)",                      ///< ident
  "tNumber (%s)",                     ///< number
  "tBoolConst (%s)",                  ///< boolean constant
  "tCharConst (%s)",                  ///< character constant
  "tStringConst (%s)",                ///< string constant
  "tPlusMinus (%s)",                  ///< '+' or '-'
  "tMulDiv (%s)",                     ///< '*' or '/'
  "tOr",                              ///< '||'
  "tAnd",                             ///< '&&'
  "tNot",                             ///< '!'
  "tRelOp (%s)",                      ///< relational operator
  "tAssign",                          ///< assignment operator
  "tComma",                           ///< a comma
  "tSemicolon",                       ///< a semicolon
  "tColon",                           ///< a colon
  "tDot",                             ///< a dot
  "tLParens",                         ///< a left parenthesis
  "tRParens",                         ///< a right parenthesis
  "tLBrak",                           ///< a left bracket
  "tRBrak",                           ///< a right bracket

  "tModule",                          ///< 'module'
  "tProcedure",                       ///< 'procedure'
  "tFunction",                        ///< 'function'
  "tVarDecl",                         ///< 'var'
  "tConstDecl",                       ///< 'const'
  "tInteger",                         ///< 'integer'
  "tBoolean",                         ///< 'boolean'
  "tChar",                            ///< 'char'
  "tBegin",                           ///< 'begin'
  "tEnd",                             ///< 'end'
  "tIf",                              ///< 'if'
  "tThen",                            ///< 'then'
  "tElse",                            ///< 'else'
  "tWhile",                           ///< 'while'
  "tDo",                              ///< 'do'
  "tReturn",                          ///< 'return'

  "tComment (%s)",                    ///< comment ('// .... \n')
  "tEOF",                             ///< end of file
  "tIOError",                         ///< I/O error
  "tInvCharConst (%s)",               ///< invalid character constant
  "tInvStringConst (%s)",             ///< invalid string constant
  "tUndefined",                       ///< undefined
};


//------------------------------------------------------------------------------
// reserved keywords
//
pair<const char*, EToken> Keywords[] =
{
  make_pair("module", tModule),
  make_pair("procedure", tProcedure),
  make_pair("function", tFunction),
  make_pair("var", tVarDecl),
  make_pair("const", tConstDecl),
  make_pair("integer", tInteger),
  make_pair("boolean", tBoolean),
  make_pair("char", tChar),
  make_pair("begin", tBegin),
  make_pair("end", tEnd),
  make_pair("if", tIf),
  make_pair("then", tThen),
  make_pair("else", tElse),
  make_pair("while", tWhile),
  make_pair("do", tDo),
  make_pair("return", tReturn),
  make_pair("true", tBoolConst),
  make_pair("false", tBoolConst),
};

//------------------------------------------------------------------------------
// CToken
//
CToken::CToken()
{
  _type = tUndefined;
  _value = "";
  _line = _char = 0;
}

CToken::CToken(int line, int charpos, EToken type, const string value)
{
  _type = type;
  // if ((type==tStringConst) || (type==tCharConst)) _value = escape(type, value);
  if (type == tStringConst) _value = "\"" + escape(type, value) + "\"";
  else if (type == tCharConst) _value = escape(type, value);
  else _value = value;
  _line = line;
  _char = charpos;
}

CToken::CToken(const CToken &token)
{
  _type = token.GetType();
  _value = token.GetValue();
  _line = token.GetLineNumber();
  _char = token.GetCharPosition();
}

CToken::CToken(const CToken *token)
{
  _type = token->GetType();
  _value = token->GetValue();
  _line = token->GetLineNumber();
  _char = token->GetCharPosition();
}

const string CToken::Name(EToken type)
{
  return string(ETokenName[type]);
}

const string CToken::GetName(void) const
{
  return CToken::Name(GetType());
}

ostream& CToken::print(ostream &out) const
{
  #define MAX_STRLEN 128
  int str_len = _value.length();
  str_len = TOKEN_STRLEN + (str_len < MAX_STRLEN ? str_len : MAX_STRLEN);
  char *str = (char*)malloc(str_len);
  snprintf(str, str_len, ETokenStr[GetType()], _value.c_str());
  out << dec << _line << ":" << _char << ": " << str;
  free(str);
  return out;
}


string CToken::escape(EToken type, const string text)
{
  // inverse of CToken::unescape()

  const char *t = text.c_str();
  string s;

  while ((type == tCharConst) || (*t != '\0')) {
    char c = *t;

    switch (c) {
      case '\n': s += "\\n";  break;
      case '\t': s += "\\t";  break;
      case '\0': s += "\\0";  break;
      case '\'': if (type == tCharConst) s += "\\'";
                 else s += c;
                 break;
      case '\"': if (type == tStringConst) s += "\\\"";
                 else s += c;
                 break;
      case '\\': s += "\\\\"; break;
      default :  if ((c < ' ') || (c == '\x7f')) {
                   // ASCII characters 0x80~0xff satisfy (signed char c < ' ')
                   char str[5];
                   snprintf(str, sizeof(str), "\\x%02x", (unsigned char)c);
                   s += str;
                 } else {
                   s += c;
                 }
    }
    if (type == tCharConst) break;
    t++;
  }

  return s;
}

string CToken::unescape(const string text)
{
  // inverse of CToken::escape()

  const char *t = text.c_str();
  char c;
  string s;

  while (*t != '\0') {
    if (*t == '\\') {
      switch (*++t) {
        case 'n':  s += "\n";  break;
        case 't':  s += "\t";  break;
        case '0':  s += "\0";  break;
        case '\'': s += "'";  break;
        case '"':  s += "\""; break;
        case '\\': s += "\\"; break;
        case 'x':  c  = digitValue(*++t)<<4;
                   s += (c + digitValue(*++t)); break;
        default :  s += '?'; // error
      }
    } else {
      s += *t;
    }
    t++;
  }

  return s;
}

int CToken::digitValue(char c)
{
  c = tolower(c);
  if (('0' <= c) && (c <= '9')) return c - '0';
  if (('a' <= c) && (c <= 'f')) return c - 'a' + 10;
  return -1;
}

ostream& operator<<(ostream &out, const CToken &t)
{
  return t.print(out);
}

ostream& operator<<(ostream &out, const CToken *t)
{
  return t->print(out);
}


//------------------------------------------------------------------------------
// CScanner
//
map<string, EToken> CScanner::keywords;

CScanner::CScanner(istream *in)
{
  InitKeywords();
  _in = in;
  _delete_in = false;
  _line = _char = 1;
  _token = NULL;
  _good = in->good();
  NextToken();
}

CScanner::CScanner(string in)
{
  InitKeywords();
  _in = new istringstream(in);
  _delete_in = true;
  _line = _char = 1;
  _token = NULL;
  _good = true;
  NextToken();
}

CScanner::~CScanner()
{
  if (_token != NULL) delete _token;
  if (_delete_in) delete _in;
}

void CScanner::InitKeywords(void)
{
  if (keywords.size() == 0) {
    int size = sizeof(Keywords) / sizeof(Keywords[0]);
    for (int i=0; i<size; i++) {
      keywords[Keywords[i].first] = Keywords[i].second;
    }
  }
}

CToken CScanner::Get()
{
  CToken result(_token);

  EToken type = _token->GetType();
  _good = !(type == tIOError);

  NextToken();
  return result;
}

CToken CScanner::Peek() const
{
  return CToken(_token);
}

void CScanner::NextToken()
{
  if (_token != NULL) delete _token;

  _token = Scan();
}

void CScanner::RecordStreamPosition(void)
{
  _saved_line = _line;
  _saved_char = _char;
}

void CScanner::GetRecordedStreamPosition(int *lineno, int *charpos)
{
  *lineno = _saved_line;
  *charpos = _saved_char;
}

CToken* CScanner::NewToken(EToken type, const string token)
{
  return new CToken(_saved_line, _saved_char, type, token);
}

CToken* CScanner::Scan()
{
  EToken token;
  string tokval;
  char c;

  while (_in->good() && IsWhite(PeekChar())) GetChar();

  RecordStreamPosition();

  if (_in->eof()) return NewToken(tEOF);
  if (!_in->good()) return NewToken(tIOError);

  c = GetChar();
  tokval = c;
  token = tUndefined;

  switch (c) {
    case ':':
      if (PeekChar() == '=') {
        tokval += GetChar();
        token = tAssign;
      } else token = tColon;
      break;

    case '+':
    case '-':
      token = tPlusMinus;
      break;
    case '|':
      // TODO: Is the else statement unnecessary?
      if (PeekChar() == '|') {
        token = tOr;
        tokval += GetChar();
      } else tokval = "invalid character '|'";
      break;

    case '*':
      token = tMulDiv;
      break;
    case '/':
      if (PeekChar() == '/') {
        while (_in->good() && PeekChar() != '\n')
          GetChar();

        return Scan();
      } else token = tMulDiv;
      break;
    case '&':
      if (PeekChar() == '&') {
        token = tAnd;
        tokval += GetChar();
      } else tokval = "invalid character '&'";
      break;

    case '=':
    case '#':
      token = tRelOp;
      break;
    case '>':
    case '<':
      token = tRelOp;
      if (PeekChar() == '=')
        tokval += GetChar();
      break;

    case '!':
      token = tNot;
      break;

    case ';':
      token = tSemicolon;
      break;

    case '.':
      token = tDot;
      break;

    case ',':
      token = tComma;
      break;

    case '(':
      token = tLParens;
      break;

    case ')':
      token = tRParens;
      break;

    case '[':
      token = tLBrak;
      break;

    case ']':
      token = tRBrak;
      break;

    case '\'':
      if (PeekChar() == '\\') {
        GetChar();
        switch (PeekChar()) {
          case 'n':
            GetChar();
            if (PeekChar() == '\'') {
              token = tCharConst;
              tokval = '\n';
              GetChar();
            } else {
              RecordStreamPosition();
              tokval = "invalid multiple characters in single quotes";
            }
            break;
          case 't':
            GetChar();
            if (PeekChar() == '\'') {
              token = tCharConst;
              tokval = '\t';
              GetChar();
            } else {
              RecordStreamPosition();
              tokval = "invalid multiple characters in single quotes";
            }
            break;
          case '"':
            GetChar();
            if (PeekChar() == '\'') {
              token = tCharConst;
              tokval = '\"';
              GetChar();
            } else {
              RecordStreamPosition();
              tokval = "invalid multiple characters in single quotes";
            }
            break;
          case '\'':
            GetChar();
            if (PeekChar() == '\'') {
              token = tCharConst;
              tokval = '\'';
              GetChar();
            } else {
              RecordStreamPosition();
              tokval = "invalid multiple characters in single quotes";
            }
            break;
          case '\\':
            GetChar();
            if (PeekChar() == '\'') {
              token = tCharConst;
              tokval = '\\';
              GetChar();
            } else {
              RecordStreamPosition();
              tokval = "invalid multiple characters in single quotes";
            }
            break;
          case '0':
            GetChar();
            if (PeekChar() == '\'') {
              token = tCharConst;
              tokval = '\0';
              GetChar();
            } else {
              RecordStreamPosition();
              tokval = "invalid multiple characters in single quotes";
            }
            break;
          case 'x':
            GetChar();
            try {
              if (!IsHexDigit(PeekChar()))
                throw string("invalid hex encoding");
              unsigned char first = GetChar();

              if (!IsHexDigit(PeekChar()))
                throw string("invalid hex encoding");
              unsigned char second = GetChar();

              if (PeekChar() != '\'')
                throw string("invalid multiple characters in single quotes");

              GetChar();
              unsigned char sum = HexEncodedToChar(first) * 16;
              sum += HexEncodedToChar(second);

              token = tCharConst;
              tokval = sum;
            } catch (string exception) {
              RecordStreamPosition();
              tokval = exception;
            }
            break;
          default:
            RecordStreamPosition();
            tokval = "invalid escaped sequence";
        }
      } else if (PeekChar() != '\'') {
        tokval = GetChar();

        if (PeekChar() == '\'') {
          token = tCharConst;
          GetChar();
        } else {
          RecordStreamPosition();
          tokval = "invalid multiple characters in single quotes";
        }
      } else {
        RecordStreamPosition();
        tokval = "invalid empty character constant";
      }
      break;

    case '"':
      token = tStringConst;
      tokval = "";
      try {
        while (_in->good() && PeekChar() != '"') {
          if (PeekChar() == '\n') {
            throw string("invalid multiline string constant");
          } else if (PeekChar() == '\\') {
            GetChar();
            switch (PeekChar()) {
              case 'n':
                GetChar();
                tokval += '\n';
                break;
              case 't':
                GetChar();
                tokval += '\t';
                break;
              case '"':
                GetChar();
                tokval += '"';
                break;
              case '\'':
                GetChar();
                tokval += '\'';
                break;
              case '\\':
                GetChar();
                tokval += '\\';
                break;
              case 'x': {
                GetChar();
                if (!IsHexDigit(PeekChar()))
                  throw string("invalid hexencoding");
                unsigned char first = GetChar();

                if (!IsHexDigit(PeekChar()))
                  throw string("invalid hexencoding");
                unsigned char second = GetChar();

                unsigned char sum = HexEncodedToChar(first) * 16;
                sum += HexEncodedToChar(second);

                tokval += sum;
                break;
              }
              case '0':
                throw string("invalid null character inside string constant");
              default:
                throw string("invalid escape sequence");
            }
          } else {
            tokval += GetChar();
          }
        }

        if (!_in->good())
          throw string("invalid string constant");

        GetChar();
        break;
      } catch (string exception) {
        RecordStreamPosition();
        token = tInvStringConst;
        tokval = exception;
        break;
      }

    default:
      if (('0' <= c) && (c <= '9')) {
        while (IsNum(PeekChar()))
          tokval += GetChar();

        token = tNumber;
      } else
      if (
        c == '_' ||
        ('a' <= c && c <= 'z') ||
        ('A' <= c && c <= 'Z')
      ) {
        while (
          _in->good() &&
          !IsWhite(PeekChar()) &&
          IsIDChar(PeekChar())
        ) {
          tokval += GetChar();
        }

        if (keywords[tokval]) {
          token = keywords[tokval];
        } else {
          token = tIdent;
        }
      } else {
        RecordStreamPosition();
        tokval = "invalid character '";
        tokval += c;
        tokval += "'";
      }
      break;
  }

  return NewToken(token, tokval);
}

unsigned char CScanner::PeekChar()
{
  return (unsigned char)_in->peek();
}

unsigned char CScanner::GetChar()
{
  unsigned char c = _in->get();
  if (c == '\n') { _line++; _char = 1; } else _char++;
  return c;
}

string CScanner::GetChar(int n)
{
  string str;
  for (int i=0; i<n; i++) str += GetChar();
  return str;
}

bool CScanner::IsWhite(unsigned char c)
{
  return ((c == ' ') || (c == '\t') || (c == '\n'));
}

bool CScanner::IsAlpha(unsigned char c)
{
  return ((('a' <= c) && (c <= 'z')) || (('A' <= c) && (c <= 'Z')) || (c == '_'));
}

bool CScanner::IsNum(unsigned char c)
{
  return (('0' <= c) && (c <= '9'));
}

bool CScanner::IsHexDigit(unsigned char c)
{
  return (('0' <= c) && (c <= '9')) ||
         (('a' <= c) && (c <= 'f')) ||
         (('A' <= c) && (c <= 'F'));
}

bool CScanner::IsIDChar(unsigned char c)
{
  return (IsAlpha(c) || IsNum(c));
}

unsigned char CScanner::HexEncodedToChar(unsigned char hexdigit)
{
  if (IsNum(hexdigit)) {
    return hexdigit - '0';
  } else {
    switch (hexdigit) {
      case 'A':
      case 'a':
        return 10;
      case 'B':
      case 'b':
        return 11;
      case 'C':
      case 'c':
        return 12;
      case 'D':
      case 'd':
        return 13;
      case 'E':
      case 'e':
        return 14;
      case 'F':
      case 'f':
        return 15;
      default:
        throw string("invalid hexencoded character");
    }
  }
}

// //------------------------------------------------------------------------------
// // CToken
// //
// CToken::CToken()
// {
//   _type = tUndefined;
//   _value = "";
//   _line = _char = 0;
// }

// CToken::CToken(int line, int charpos, EToken type, const string value)
// {
//   _type = type;
//   if ((type==tStringConst) || (type==tCharConst)) _value = escape(type, value);
//   else _value = value;
//   _line = line;
//   _char = charpos;
// }

// CToken::CToken(const CToken &token)
// {
//   _type = token.GetType();
//   _value = token.GetValue();
//   _line = token.GetLineNumber();
//   _char = token.GetCharPosition();
// }

// CToken::CToken(const CToken *token)
// {
//   _type = token->GetType();
//   _value = token->GetValue();
//   _line = token->GetLineNumber();
//   _char = token->GetCharPosition();
// }

// const string CToken::Name(EToken type)
// {
//   return string(ETokenName[type]);
// }

// const string CToken::GetName(void) const
// {
//   return CToken::Name(GetType());
// }

// ostream& CToken::print(ostream &out) const
// {
//   #define MAX_STRLEN 128
//   int str_len = _value.length();
//   str_len = TOKEN_STRLEN + (str_len < MAX_STRLEN ? str_len : MAX_STRLEN);
//   char *str = (char*)malloc(str_len);
//   snprintf(str, str_len, ETokenStr[GetType()], _value.c_str());
//   out << dec << _line << ":" << _char << ": " << str;
//   free(str);
//   return out;
// }

// string CToken::escape(EToken type, const string text)
// {
//   // inverse of CToken::unescape()

//   const char *t = text.c_str();
//   string s;

//   while ((type == tCharConst) || (*t != '\0')) {
//     char c = *t;

//     switch (c) {
//       case '\n': s += "\\n";  break;
//       case '\t': s += "\\t";  break;
//       case '\0': s += "\\0";  break;
//       case '\'': if (type == tCharConst) s += "\\'";  
//                  else s += c;
//                  break;
//       case '\"': if (type == tStringConst) s += "\\\""; 
//                  else s += c;
//                  break;
//       case '\\': s += "\\\\"; break;
//       default :  if ((c < ' ') || (c == '\x7f')) {
//                    // ASCII characters 0x80~0xff satisfy (signed char c < ' ')
//                    char str[5];
//                    snprintf(str, sizeof(str), "\\x%02x", (unsigned char)c);
//                    s += str;
//                  } else {
//                    s += c;
//                  }
//     }
//     if (type == tCharConst) break;
//     t++;
//   }

//   return s;
// }

// string CToken::unescape(const string text)
// {
//   // inverse of CToken::escape()

//   const char *t = text.c_str(); 
//   char c;
//   string s;

//   while (*t != '\0') {
//     if (*t == '\\') {
//       switch (*++t) {
//         case 'n':  s += "\n";  break;
//         case 't':  s += "\t";  break;
//         case '0':  s += "\0";  break;
//         case '\'': s += "'";  break;
//         case '"':  s += "\""; break;
//         case '\\': s += "\\"; break;
//         case 'x':  c  = digitValue(*++t)<<4;
//                    s += (c + digitValue(*++t)); break;
//         default :  s += '?'; // error
//       }
//     } else {
//       s += *t;
//     }
//     t++;
//   }

//   return s;
// }

// int CToken::digitValue(char c)
// {
//   c = tolower(c);
//   if (('0' <= c) && (c <= '9')) return c - '0';
//   if (('a' <= c) && (c <= 'f')) return c - 'a' + 10;
//   return -1;
// }

// ostream& operator<<(ostream &out, const CToken &t)
// {
//   return t.print(out);
// }

// ostream& operator<<(ostream &out, const CToken *t)
// {
//   return t->print(out);
// }


// //------------------------------------------------------------------------------
// // CScanner
// //
// map<string, EToken> CScanner::keywords;

// CScanner::CScanner(istream *in)
// {
//   InitKeywords();
//   _in = in;
//   _delete_in = false;
//   _line = _char = 1;
//   _token = NULL;
//   _good = in->good();
//   NextToken();
// }

// CScanner::CScanner(string in)
// {
//   InitKeywords();
//   _in = new istringstream(in);
//   _delete_in = true;
//   _line = _char = 1;
//   _token = NULL;
//   _good = true;
//   NextToken();
// }

// CScanner::~CScanner()
// {
//   if (_token != NULL) delete _token;
//   if (_delete_in) delete _in;
// }

// void CScanner::InitKeywords(void)
// {
//   if (keywords.size() == 0) {
//     int size = sizeof(Keywords) / sizeof(Keywords[0]);
//     for (int i=0; i<size; i++) {
//       keywords[Keywords[i].first] = Keywords[i].second;
//     }
//   }
// }

// CToken CScanner::Get()
// {
//   CToken result(_token);

//   EToken type = _token->GetType();
//   _good = !(type == tIOError);

//   NextToken();
//   return result;
// }

// CToken CScanner::Peek() const
// {
//   return CToken(_token);
// }

// void CScanner::NextToken()
// {
//   if (_token != NULL) delete _token;

//   _token = Scan();
// }

// void CScanner::RecordStreamPosition(void)
// {
//   _saved_line = _line;
//   _saved_char = _char;
// }

// void CScanner::GetRecordedStreamPosition(int *lineno, int *charpos)
// {
//   *lineno = _saved_line;
//   *charpos = _saved_char;
// }

// CToken* CScanner::NewToken(EToken type, const string token)
// {
//   return new CToken(_saved_line, _saved_char, type, token);
// }

// CToken* CScanner::Scan()
// {
//   EToken token;
//   string tokval;
//   char c;

//   while (_in->good() && IsWhite(PeekChar())) GetChar();

//   RecordStreamPosition();

//   if (_in->eof()) return NewToken(tEOF);
//   if (!_in->good()) return NewToken(tIOError);

//   c = GetChar();
//   tokval = c;
//   token = tUndefined;

//   switch (c) {
//     case ':':
//       if (PeekChar() == '=') {
//         tokval += GetChar();
//         token = tAssign;
//       }
//       break;

//     case '+':
//     case '-':
//       token = tPlusMinus;
//       break;

//     case '*':
//     case '/':
//       token = tMulDiv;
//       break;

//     case '=':
//     case '#':
//       token = tRelOp;
//       break;

//     case ';':
//       token = tSemicolon;
//       break;

//     case '.':
//       token = tDot;
//       break;

//     case '(':
//       token = tLBrak;
//       break;

//     case ')':
//       token = tRBrak;
//       break;

//     default:
//       if (('0' <= c) && (c <= '9')) {
//         token = tDigit;
//       } else
//       if (('a' <= c) && (c <= 'z')) {
//         token = tLetter;
//       } else {
//         tokval = "invalid character '";
//         tokval += c;
//         tokval += "'";
//       }
//       break;
//   }

//   return NewToken(token, tokval);
// }

// unsigned char CScanner::PeekChar()
// {
//   return (unsigned char)_in->peek();
// }

// unsigned char CScanner::GetChar()
// {
//   unsigned char c = _in->get();
//   if (c == '\n') { _line++; _char = 1; } else _char++;
//   return c;
// }

// string CScanner::GetChar(int n)
// {
//   string str;
//   for (int i=0; i<n; i++) str += GetChar();
//   return str;
// }

// bool CScanner::IsWhite(unsigned char c)
// {
//   return ((c == ' ') || (c == '\t') || (c == '\n'));
// }

// bool CScanner::IsAlpha(unsigned char c)
// {
//   return ((('a' <= c) && (c <= 'z')) || (('A' <= c) && (c <= 'Z')) || (c == '_'));
// }

// bool CScanner::IsNum(unsigned char c)
// {
//   return (('0' <= c) && (c <= '9'));
// }

// bool CScanner::IsHexDigit(unsigned char c)
// {
//   return (('0' <= c) && (c <= '9')) ||
//          (('a' <= c) && (c <= 'f')) ||
//          (('A' <= c) && (c <= 'F'));
// }

// bool CScanner::IsIDChar(unsigned char c)
// {
//   return (IsAlpha(c) || IsNum(c));
// }

