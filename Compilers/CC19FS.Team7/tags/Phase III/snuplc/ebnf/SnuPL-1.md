# SnuPL/-1
SnuPL/-1 defines a simple grammar consisting of assignments to 'variables' formed by expressions of constant digits using addition, subtraction, multiplication, and division. Expressions can be compared for equality (=) or inequality (#). All variable names are lower-caps and are only one character long. Separate assignment statements are separated by a semicolon (;). The end of the program is marked by a dot.

## EBNF
    module       = statSequence "."
    digit        = "0".."9".
    letter       = "a".."z".
    factOp       = "*" | "/".
    termOp       = "+" | "-".
    relOp        = "=" | "#".
    factor       = digit | "(" expression ")".
    term         = factor { factOp factor }.
    simpleexpr   = term { termOp term }.
    expression   = simpleexpr [ relOp simpleexpr ].
    assignment   = letter ":=" expression.
    statement    = assignment.
    statSequence = [ statement { ";" statement } ].
    whitespace   = { " " | \n }+.

## Examples
A valid SnuPL/-1 program.

    a := 5 + (10 * 5 / 25) - 2;
    b := (1 + 1);
    c := (2 * 3) = (3 * 2);
    d    :=1      +2/3*    2=    5
    .
Some invalid statements.
    
    a := 1 +/ 2 3; 
    b := 1 = 2 = 3;      // only one relOp is allowed
    cd := 12 + 13;       // variables/numbers must be one character/digit only
    
