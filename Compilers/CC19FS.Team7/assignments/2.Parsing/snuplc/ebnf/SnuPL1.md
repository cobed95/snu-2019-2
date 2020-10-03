# SnuPL/1
SnuPL/1 is an imperative procedural language closely related to the [Oberon programming language](https://www.inf.ethz.ch/personal/wirth/Oberon/Oberon07.Report.pdf), one of the many languages developed by Prof. Niklaus Wirth. SnuPL/1 does not support object-orientation and the only composite data type supported are arrays. Records or enumerations are not supported. Nevertheless, SnuPL/1 is complex enough to illustrate the basic concepts of a compiler.

This document only contains the EBNF and an example program. For the full language description including semanitcs, type system, etc refer to the project handout.

## EBNF
    module            = "module" ident ";"
                        constDeclaration varDeclaration { subroutineDecl }
                        "begin" statSequence "end" ident ".".
    
    letter            = "A".."Z" | "a".."z" | "_".
    digit             = "0".."9".
    hexdigit          = digit | "A".."F" | "a".."f".
    character         = LATIN1 char | "\n" | "\t" | "\"" | "\'" | "\\" | hexencoded.
    hexedcoded        = "\x" hexdigit hexdigit.
    char              = "'" character  | "\0" "'".
    string            = '"' { character } '"'.
    
    ident             = letter { letter | digit }.
    number            = digit { digit }.
    boolean           = "true" | "false".
    type              = basetype | type "[" [ simpleexpr ] "]".
    basetype          = "boolean" | "char" | "integer".
    
    qualident         = ident { "[" simpleexpr "]" }.
    factOp            = "*" | "/" | "&&".
    termOp            = "+" | "-" | "||".
    relOp             = "=" | "#" | "<" | "<=" | ">" | ">=".
    
    factor            = qualident | number | boolean | char | string |
                       "(" expression ")" | subroutineCall | "!" factor.
    term              = factor { factOp factor }.
    simpleexpr        = ["+"|"-"] term { termOp term }.
    expression        = simpleexpr [ relOp simplexpr ].
    
    assignment        = qualident ":=" expression.
    subroutineCall    = ident "(" [ expression {"," expression} ] ")".
    ifStatement       = "if" "(" expression ")" "then" statSequence
                        [ "else" statSequence ] "end".
    whileStatement    = "while" "(" expression ")" "do" statSequence "end".
    returnStatement   = "return" [ expression ].
    
    statement         = assignment | subroutineCall | ifStatement
                        | whileStatement | returnStatement.
    statSequence      = [ statement { ";" statement } ].
    
    constDeclaration  = [ "const" constDeclSequence ].
    constDeclSequence = constDecl ";" { constDecl ";" }
    constDecl         = varDecl "=" expression.
    
    varDeclaration    = [ "var" varDeclSequence ";" ].
    varDeclSequence   = varDecl { ";" varDecl }.
    varDecl           = ident { "," ident } ":" type.
    
    subroutineDecl    = (procedureDecl | functionDecl)
                        subroutineBody ident ";".
    procedureDecl     = "procedure" ident [ formalParam ] ";".
    functionDecl      = "function" ident [ formalParam ] ":" type ";".
    formalParam       = "(" [ varDeclSequence ] ")".
    subroutineBody    = constDeclaration varDeclaration
                        "begin" statSequence "end".
    
    comment           = "//" {[^\n]} \n.
    whitespace        = { " " | \t | \n }.


## Examples
The following shows a valid test program exercising (almost) all features of the language.

    //
    // Matrix Add
    //
    // A valid SnuPL/1 test program
    //
    
    module MatrixAdd;
    
    const
      N : integer = 2*(2+2);
      ProgramName : char[] = "Matrix\t Adder\n\n";
    
    var
      A, B, C : integer[N][N];
    
    procedure minit(m: integer[][]);
    var x,y,v: integer;
    begin
      v := 1;
      while (y < N) do
        x := 0;
        while (x < N) do
          m[y][x] := v;
          v := v+1;
          if (v = 10) then v := 0 end;
          x := x+1
        end;
        y := y+1
      end
    end minit;
    
    procedure madd(sum: integer[N][N]; a,b: integer[N][N]);
    var x,y: integer;
    begin
      y := 0;
      while (y < N) do
        x := 0;
        while (x < N) do
          sum[y][x] := a[y][x] + b[y][x];
          x := x+1
        end;
        y := y+1
      end
    end madd;
    
    procedure mprint(m: integer[][]; title: char[]);
    const MStr : char[] = ". Matrix ";
    var N,M,x,y: integer;
    begin
      M := DIM(m, 1);
      N := DIM(m, 2);
    
      WriteStr(title); WriteStr(MStr); WriteInt(M); WriteChar('x'); WriteInt(N); 
      WriteLn();
      WriteStr("[\n");
    
      while (y < M) do
        WriteStr("  "); WriteInt(y); WriteStr(":  [   ");
    
        x := 0;
        while (x < N) do
          WriteInt(m[y][x]); WriteStr("   ");
          x := x+1
        end;
    
        WriteStr("]\n");
        y := y+1
      end;
    
      WriteStr("]\n\n")
    end mprint;
    
    begin
      WriteStr(ProgramName); WriteLn();
    
      minit(A);
      minit(B);
      minit(C);
    
      mprint(A, "A");
      mprint(B, "B");
    
      madd(C, A, B);
    
      mprint(C, "C = A+B")
    end MatrixAdd.

    
