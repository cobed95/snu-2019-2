type token =
  | TRUE
  | FALSE
  | AND
  | OR
  | IF
  | THEN
  | ELSE
  | LET
  | IN
  | END
  | FN
  | READ
  | WRITE
  | RARROW
  | EQUAL
  | PLUS
  | MINUS
  | LP
  | RP
  | VAL
  | COLONEQ
  | BANG
  | MALLOC
  | SEMICOLON
  | REC
  | EOF
  | DOT
  | COMMA
  | NUM of (int)
  | ID of (string)
  | STRING of (string)

open Parsing;;
let _ = parse_error;;
# 7 "parser.mly"
 
exception EmptyBinding
let rec desugarLet =
  function ([], e) -> raise EmptyBinding
   | (a::[], e) -> M.M.LET(a,e)
   | (a::r, e) -> M.M.LET(a, desugarLet(r,e))

exception IncorrectSelection
let whichSel = function (e, 1) -> M.M.FST e
       | (e, 2) -> M.M.SND e
       | _ -> raise IncorrectSelection
# 49 "parser.ml"
let yytransl_const = [|
  257 (* TRUE *);
  258 (* FALSE *);
  259 (* AND *);
  260 (* OR *);
  261 (* IF *);
  262 (* THEN *);
  263 (* ELSE *);
  264 (* LET *);
  265 (* IN *);
  266 (* END *);
  267 (* FN *);
  268 (* READ *);
  269 (* WRITE *);
  270 (* RARROW *);
  271 (* EQUAL *);
  272 (* PLUS *);
  273 (* MINUS *);
  274 (* LP *);
  275 (* RP *);
  276 (* VAL *);
  277 (* COLONEQ *);
  278 (* BANG *);
  279 (* MALLOC *);
  280 (* SEMICOLON *);
  281 (* REC *);
    0 (* EOF *);
  282 (* DOT *);
  283 (* COMMA *);
    0|]

let yytransl_block = [|
  284 (* NUM *);
  285 (* ID *);
  286 (* STRING *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
\002\000\002\000\002\000\004\000\004\000\004\000\004\000\004\000\
\004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
\004\000\005\000\005\000\003\000\003\000\000\000"

let yylen = "\002\000\
\002\000\001\000\002\000\003\000\003\000\003\000\003\000\003\000\
\003\000\003\000\003\000\003\000\001\000\001\000\001\000\001\000\
\001\000\001\000\004\000\005\000\006\000\002\000\002\000\002\000\
\005\000\001\000\002\000\004\000\007\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\015\000\016\000\000\000\000\000\000\000\018\000\
\000\000\000\000\000\000\000\000\013\000\017\000\014\000\030\000\
\000\000\002\000\000\000\000\000\000\000\026\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\001\000\000\000\003\000\000\000\000\000\
\000\000\000\000\027\000\000\000\012\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\011\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\020\000\
\025\000\000\000\000\000\000\000\000\000"

let yydgoto = "\002\000\
\016\000\017\000\022\000\018\000\023\000"

let yysindex = "\255\255\
\022\002\000\000\000\000\000\000\022\002\239\254\229\254\000\000\
\022\002\022\002\022\002\022\002\000\000\000\000\000\000\000\000\
\001\000\000\000\154\255\236\254\237\254\000\000\251\254\004\255\
\158\001\113\255\054\002\054\002\022\002\022\002\022\002\022\002\
\022\002\022\002\022\002\000\000\247\254\000\000\022\002\008\255\
\009\255\022\002\000\000\022\002\000\000\022\002\054\002\035\002\
\248\001\035\002\035\002\188\001\128\001\000\000\186\255\022\002\
\014\255\220\255\128\001\068\001\022\002\098\001\254\254\000\000\
\000\000\218\001\012\255\022\002\098\001"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\240\000\000\000\029\000\054\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\079\000\103\000\
\174\000\127\000\151\000\218\000\007\001\000\000\000\000\000\000\
\000\000\000\000\041\001\000\000\000\000\252\254\000\000\000\000\
\000\000\196\000\000\000\000\000\253\254"

let yygindex = "\000\000\
\000\000\002\000\005\000\040\000\000\000"

let yytablesize = 852
let yytable = "\001\000\
\036\000\024\000\020\000\042\000\028\000\029\000\019\000\021\000\
\040\000\041\000\025\000\026\000\027\000\028\000\020\000\028\000\
\029\000\044\000\054\000\021\000\028\000\029\000\056\000\057\000\
\063\000\068\000\067\000\043\000\024\000\000\000\047\000\048\000\
\049\000\050\000\051\000\052\000\053\000\000\000\000\000\000\000\
\055\000\000\000\000\000\058\000\000\000\059\000\000\000\060\000\
\000\000\000\000\000\000\000\000\000\000\023\000\000\000\000\000\
\038\000\062\000\038\000\000\000\000\000\000\000\066\000\000\000\
\038\000\038\000\038\000\038\000\000\000\069\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\007\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\038\000\038\000\
\038\000\038\000\038\000\038\000\038\000\000\000\038\000\000\000\
\000\000\038\000\038\000\038\000\000\000\038\000\008\000\000\000\
\000\000\038\000\000\000\000\000\038\000\000\000\000\000\000\000\
\000\000\003\000\004\000\029\000\030\000\005\000\000\000\000\000\
\006\000\000\000\000\000\007\000\008\000\009\000\004\000\031\000\
\032\000\033\000\010\000\045\000\000\000\034\000\011\000\012\000\
\035\000\000\000\037\000\046\000\013\000\014\000\015\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\005\000\000\000\
\000\000\000\000\003\000\004\000\029\000\030\000\005\000\039\000\
\000\000\006\000\000\000\000\000\007\000\008\000\009\000\000\000\
\031\000\032\000\033\000\010\000\000\000\006\000\034\000\011\000\
\012\000\035\000\000\000\037\000\000\000\013\000\014\000\015\000\
\000\000\000\000\003\000\004\000\029\000\030\000\005\000\000\000\
\061\000\006\000\000\000\021\000\007\000\008\000\009\000\000\000\
\031\000\032\000\033\000\010\000\000\000\000\000\034\000\011\000\
\012\000\035\000\000\000\037\000\000\000\013\000\014\000\015\000\
\000\000\010\000\000\000\000\000\003\000\004\000\029\000\030\000\
\005\000\000\000\000\000\006\000\000\000\064\000\007\000\008\000\
\009\000\000\000\031\000\032\000\033\000\010\000\000\000\022\000\
\034\000\011\000\012\000\035\000\000\000\037\000\000\000\013\000\
\014\000\015\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\003\000\004\000\029\000\030\000\005\000\009\000\000\000\
\006\000\000\000\000\000\007\000\008\000\009\000\000\000\031\000\
\032\000\033\000\010\000\000\000\000\000\034\000\011\000\012\000\
\035\000\000\000\037\000\000\000\013\000\014\000\015\000\024\000\
\024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
\019\000\024\000\000\000\024\000\024\000\024\000\000\000\024\000\
\024\000\024\000\000\000\000\000\024\000\024\000\000\000\024\000\
\023\000\023\000\023\000\023\000\023\000\023\000\023\000\023\000\
\023\000\000\000\023\000\000\000\023\000\023\000\023\000\000\000\
\023\000\023\000\023\000\000\000\000\000\023\000\023\000\000\000\
\023\000\007\000\007\000\007\000\007\000\007\000\007\000\007\000\
\007\000\007\000\000\000\007\000\000\000\007\000\007\000\007\000\
\000\000\007\000\007\000\007\000\000\000\000\000\007\000\007\000\
\000\000\007\000\008\000\008\000\008\000\008\000\008\000\008\000\
\008\000\008\000\000\000\008\000\000\000\008\000\008\000\008\000\
\000\000\008\000\008\000\008\000\000\000\000\000\008\000\008\000\
\000\000\008\000\004\000\004\000\004\000\004\000\004\000\004\000\
\004\000\004\000\000\000\004\000\000\000\004\000\004\000\004\000\
\000\000\004\000\004\000\004\000\000\000\000\000\004\000\004\000\
\000\000\004\000\005\000\005\000\005\000\005\000\005\000\005\000\
\005\000\005\000\000\000\005\000\000\000\005\000\005\000\005\000\
\000\000\005\000\005\000\005\000\000\000\000\000\005\000\005\000\
\000\000\005\000\006\000\006\000\006\000\006\000\006\000\006\000\
\006\000\000\000\006\000\000\000\006\000\000\000\000\000\000\000\
\006\000\006\000\006\000\000\000\000\000\006\000\006\000\000\000\
\006\000\021\000\021\000\021\000\021\000\021\000\021\000\000\000\
\021\000\000\000\000\000\000\000\000\000\000\000\021\000\021\000\
\021\000\000\000\000\000\021\000\021\000\000\000\021\000\010\000\
\010\000\010\000\010\000\010\000\010\000\000\000\010\000\000\000\
\000\000\000\000\000\000\000\000\010\000\010\000\000\000\000\000\
\000\000\010\000\010\000\000\000\010\000\022\000\022\000\022\000\
\022\000\022\000\022\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\022\000\022\000\000\000\000\000\000\000\022\000\
\022\000\000\000\022\000\000\000\009\000\009\000\000\000\009\000\
\009\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\009\000\009\000\000\000\000\000\000\000\009\000\009\000\
\000\000\009\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\019\000\019\000\
\000\000\019\000\019\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\019\000\019\000\000\000\000\000\000\000\
\019\000\019\000\000\000\019\000\003\000\004\000\029\000\030\000\
\005\000\000\000\000\000\006\000\000\000\000\000\007\000\008\000\
\009\000\000\000\031\000\032\000\033\000\010\000\065\000\000\000\
\034\000\011\000\012\000\035\000\000\000\037\000\000\000\013\000\
\014\000\015\000\003\000\004\000\029\000\030\000\005\000\000\000\
\000\000\006\000\000\000\000\000\007\000\008\000\009\000\000\000\
\031\000\032\000\033\000\010\000\000\000\000\000\034\000\011\000\
\012\000\035\000\000\000\037\000\000\000\013\000\014\000\015\000\
\003\000\004\000\029\000\030\000\005\000\000\000\000\000\006\000\
\000\000\000\000\007\000\008\000\009\000\000\000\031\000\032\000\
\033\000\010\000\000\000\000\000\034\000\011\000\012\000\000\000\
\000\000\037\000\000\000\013\000\014\000\015\000\003\000\004\000\
\029\000\030\000\005\000\000\000\000\000\000\000\000\000\000\000\
\000\000\008\000\009\000\000\000\031\000\032\000\033\000\010\000\
\000\000\000\000\034\000\011\000\012\000\000\000\000\000\037\000\
\000\000\013\000\014\000\015\000\003\000\004\000\029\000\030\000\
\005\000\000\000\000\000\000\000\000\000\000\000\000\000\008\000\
\000\000\000\000\031\000\032\000\033\000\010\000\000\000\000\000\
\034\000\011\000\012\000\000\000\000\000\037\000\000\000\013\000\
\014\000\015\000\003\000\004\000\029\000\030\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\008\000\000\000\000\000\
\031\000\032\000\033\000\010\000\000\000\000\000\000\000\011\000\
\012\000\000\000\000\000\037\000\000\000\013\000\014\000\015\000\
\003\000\004\000\029\000\030\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\008\000\000\000\000\000\000\000\032\000\
\033\000\010\000\000\000\000\000\000\000\011\000\012\000\000\000\
\000\000\037\000\000\000\013\000\014\000\015\000\003\000\004\000\
\000\000\000\000\005\000\000\000\000\000\006\000\000\000\000\000\
\007\000\008\000\009\000\003\000\004\000\029\000\000\000\010\000\
\000\000\000\000\000\000\011\000\012\000\000\000\008\000\000\000\
\000\000\013\000\014\000\015\000\010\000\000\000\003\000\004\000\
\011\000\012\000\000\000\000\000\037\000\000\000\013\000\014\000\
\015\000\008\000\000\000\000\000\000\000\000\000\000\000\010\000\
\000\000\000\000\000\000\011\000\012\000\000\000\000\000\037\000\
\000\000\013\000\014\000\015\000"

let yycheck = "\001\000\
\000\000\029\001\020\001\009\001\009\001\009\001\005\000\025\001\
\029\001\029\001\009\000\010\000\011\000\012\000\020\001\020\001\
\020\001\014\001\028\001\025\001\025\001\025\001\015\001\015\001\
\011\001\014\001\029\001\023\000\000\000\255\255\029\000\030\000\
\031\000\032\000\033\000\034\000\035\000\255\255\255\255\255\255\
\039\000\255\255\255\255\042\000\255\255\044\000\255\255\046\000\
\255\255\255\255\255\255\255\255\255\255\000\000\255\255\255\255\
\017\000\056\000\019\000\255\255\255\255\255\255\061\000\255\255\
\025\000\026\000\027\000\028\000\255\255\068\000\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\000\000\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\047\000\048\000\
\049\000\050\000\051\000\052\000\053\000\255\255\055\000\255\255\
\255\255\058\000\059\000\060\000\255\255\062\000\000\000\255\255\
\255\255\066\000\255\255\255\255\069\000\255\255\255\255\255\255\
\255\255\001\001\002\001\003\001\004\001\005\001\255\255\255\255\
\008\001\255\255\255\255\011\001\012\001\013\001\000\000\015\001\
\016\001\017\001\018\001\019\001\255\255\021\001\022\001\023\001\
\024\001\255\255\026\001\027\001\028\001\029\001\030\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\000\000\255\255\
\255\255\255\255\001\001\002\001\003\001\004\001\005\001\006\001\
\255\255\008\001\255\255\255\255\011\001\012\001\013\001\255\255\
\015\001\016\001\017\001\018\001\255\255\000\000\021\001\022\001\
\023\001\024\001\255\255\026\001\255\255\028\001\029\001\030\001\
\255\255\255\255\001\001\002\001\003\001\004\001\005\001\255\255\
\007\001\008\001\255\255\000\000\011\001\012\001\013\001\255\255\
\015\001\016\001\017\001\018\001\255\255\255\255\021\001\022\001\
\023\001\024\001\255\255\026\001\255\255\028\001\029\001\030\001\
\255\255\000\000\255\255\255\255\001\001\002\001\003\001\004\001\
\005\001\255\255\255\255\008\001\255\255\010\001\011\001\012\001\
\013\001\255\255\015\001\016\001\017\001\018\001\255\255\000\000\
\021\001\022\001\023\001\024\001\255\255\026\001\255\255\028\001\
\029\001\030\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\001\001\002\001\003\001\004\001\005\001\000\000\255\255\
\008\001\255\255\255\255\011\001\012\001\013\001\255\255\015\001\
\016\001\017\001\018\001\255\255\255\255\021\001\022\001\023\001\
\024\001\255\255\026\001\255\255\028\001\029\001\030\001\003\001\
\004\001\005\001\006\001\007\001\008\001\009\001\010\001\011\001\
\000\000\013\001\255\255\015\001\016\001\017\001\255\255\019\001\
\020\001\021\001\255\255\255\255\024\001\025\001\255\255\027\001\
\003\001\004\001\005\001\006\001\007\001\008\001\009\001\010\001\
\011\001\255\255\013\001\255\255\015\001\016\001\017\001\255\255\
\019\001\020\001\021\001\255\255\255\255\024\001\025\001\255\255\
\027\001\003\001\004\001\005\001\006\001\007\001\008\001\009\001\
\010\001\011\001\255\255\013\001\255\255\015\001\016\001\017\001\
\255\255\019\001\020\001\021\001\255\255\255\255\024\001\025\001\
\255\255\027\001\004\001\005\001\006\001\007\001\008\001\009\001\
\010\001\011\001\255\255\013\001\255\255\015\001\016\001\017\001\
\255\255\019\001\020\001\021\001\255\255\255\255\024\001\025\001\
\255\255\027\001\004\001\005\001\006\001\007\001\008\001\009\001\
\010\001\011\001\255\255\013\001\255\255\015\001\016\001\017\001\
\255\255\019\001\020\001\021\001\255\255\255\255\024\001\025\001\
\255\255\027\001\004\001\005\001\006\001\007\001\008\001\009\001\
\010\001\011\001\255\255\013\001\255\255\015\001\016\001\017\001\
\255\255\019\001\020\001\021\001\255\255\255\255\024\001\025\001\
\255\255\027\001\005\001\006\001\007\001\008\001\009\001\010\001\
\011\001\255\255\013\001\255\255\015\001\255\255\255\255\255\255\
\019\001\020\001\021\001\255\255\255\255\024\001\025\001\255\255\
\027\001\006\001\007\001\008\001\009\001\010\001\011\001\255\255\
\013\001\255\255\255\255\255\255\255\255\255\255\019\001\020\001\
\021\001\255\255\255\255\024\001\025\001\255\255\027\001\006\001\
\007\001\008\001\009\001\010\001\011\001\255\255\013\001\255\255\
\255\255\255\255\255\255\255\255\019\001\020\001\255\255\255\255\
\255\255\024\001\025\001\255\255\027\001\006\001\007\001\008\001\
\009\001\010\001\011\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\019\001\020\001\255\255\255\255\255\255\024\001\
\025\001\255\255\027\001\255\255\006\001\007\001\255\255\009\001\
\010\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\019\001\020\001\255\255\255\255\255\255\024\001\025\001\
\255\255\027\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\006\001\007\001\
\255\255\009\001\010\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\019\001\020\001\255\255\255\255\255\255\
\024\001\025\001\255\255\027\001\001\001\002\001\003\001\004\001\
\005\001\255\255\255\255\008\001\255\255\255\255\011\001\012\001\
\013\001\255\255\015\001\016\001\017\001\018\001\019\001\255\255\
\021\001\022\001\023\001\024\001\255\255\026\001\255\255\028\001\
\029\001\030\001\001\001\002\001\003\001\004\001\005\001\255\255\
\255\255\008\001\255\255\255\255\011\001\012\001\013\001\255\255\
\015\001\016\001\017\001\018\001\255\255\255\255\021\001\022\001\
\023\001\024\001\255\255\026\001\255\255\028\001\029\001\030\001\
\001\001\002\001\003\001\004\001\005\001\255\255\255\255\008\001\
\255\255\255\255\011\001\012\001\013\001\255\255\015\001\016\001\
\017\001\018\001\255\255\255\255\021\001\022\001\023\001\255\255\
\255\255\026\001\255\255\028\001\029\001\030\001\001\001\002\001\
\003\001\004\001\005\001\255\255\255\255\255\255\255\255\255\255\
\255\255\012\001\013\001\255\255\015\001\016\001\017\001\018\001\
\255\255\255\255\021\001\022\001\023\001\255\255\255\255\026\001\
\255\255\028\001\029\001\030\001\001\001\002\001\003\001\004\001\
\005\001\255\255\255\255\255\255\255\255\255\255\255\255\012\001\
\255\255\255\255\015\001\016\001\017\001\018\001\255\255\255\255\
\021\001\022\001\023\001\255\255\255\255\026\001\255\255\028\001\
\029\001\030\001\001\001\002\001\003\001\004\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\012\001\255\255\255\255\
\015\001\016\001\017\001\018\001\255\255\255\255\255\255\022\001\
\023\001\255\255\255\255\026\001\255\255\028\001\029\001\030\001\
\001\001\002\001\003\001\004\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\012\001\255\255\255\255\255\255\016\001\
\017\001\018\001\255\255\255\255\255\255\022\001\023\001\255\255\
\255\255\026\001\255\255\028\001\029\001\030\001\001\001\002\001\
\255\255\255\255\005\001\255\255\255\255\008\001\255\255\255\255\
\011\001\012\001\013\001\001\001\002\001\003\001\255\255\018\001\
\255\255\255\255\255\255\022\001\023\001\255\255\012\001\255\255\
\255\255\028\001\029\001\030\001\018\001\255\255\001\001\002\001\
\022\001\023\001\255\255\255\255\026\001\255\255\028\001\029\001\
\030\001\012\001\255\255\255\255\255\255\255\255\255\255\018\001\
\255\255\255\255\255\255\022\001\023\001\255\255\255\255\026\001\
\255\255\028\001\029\001\030\001"

let yynames_const = "\
  TRUE\000\
  FALSE\000\
  AND\000\
  OR\000\
  IF\000\
  THEN\000\
  ELSE\000\
  LET\000\
  IN\000\
  END\000\
  FN\000\
  READ\000\
  WRITE\000\
  RARROW\000\
  EQUAL\000\
  PLUS\000\
  MINUS\000\
  LP\000\
  RP\000\
  VAL\000\
  COLONEQ\000\
  BANG\000\
  MALLOC\000\
  SEMICOLON\000\
  REC\000\
  EOF\000\
  DOT\000\
  COMMA\000\
  "

let yynames_block = "\
  NUM\000\
  ID\000\
  STRING\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : M.M.exp) in
    Obj.repr(
# 43 "parser.mly"
                    (_1)
# 401 "parser.ml"
               : M.M.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'aexpr) in
    Obj.repr(
# 45 "parser.mly"
            (_1)
# 408 "parser.ml"
               : M.M.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : M.M.exp) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'aexpr) in
    Obj.repr(
# 46 "parser.mly"
                 (M.M.APP(_1,_2))
# 416 "parser.ml"
               : M.M.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : M.M.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 47 "parser.mly"
                     (M.M.BOP(M.M.ADD,_1,_3))
# 424 "parser.ml"
               : M.M.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : M.M.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 48 "parser.mly"
                      (M.M.BOP(M.M.SUB,_1,_3))
# 432 "parser.ml"
               : M.M.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : M.M.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 49 "parser.mly"
                      (M.M.BOP(M.M.EQ,_1,_3))
# 440 "parser.ml"
               : M.M.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : M.M.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 50 "parser.mly"
                    (M.M.BOP(M.M.AND,_1,_3))
# 448 "parser.ml"
               : M.M.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : M.M.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 51 "parser.mly"
                   (M.M.BOP(M.M.OR,_1,_3))
# 456 "parser.ml"
               : M.M.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : M.M.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 52 "parser.mly"
                          (M.M.SEQ (_1,_3))
# 464 "parser.ml"
               : M.M.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : M.M.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 53 "parser.mly"
                        (M.M.ASSIGN(_1,_3))
# 472 "parser.ml"
               : M.M.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : M.M.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 54 "parser.mly"
                   (whichSel (_1,_3))
# 480 "parser.ml"
               : M.M.exp))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : M.M.exp) in
    Obj.repr(
# 56 "parser.mly"
                  (_2)
# 487 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 57 "parser.mly"
          (M.M.CONST(M.M.N _1))
# 494 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 58 "parser.mly"
             (M.M.CONST(M.M.S _1))
# 501 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    Obj.repr(
# 59 "parser.mly"
           (M.M.CONST(M.M.B true))
# 507 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    Obj.repr(
# 60 "parser.mly"
            (M.M.CONST(M.M.B false))
# 513 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 61 "parser.mly"
         (M.M.VAR(_1))
# 520 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    Obj.repr(
# 62 "parser.mly"
           (M.M.READ)
# 526 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 63 "parser.mly"
                        (M.M.FN(_2,_4))
# 534 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'decls) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : M.M.exp) in
    Obj.repr(
# 64 "parser.mly"
                            (desugarLet(_2,_4))
# 542 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : M.M.exp) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : M.M.exp) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 65 "parser.mly"
                                  (M.M.IF(_2,_4,_6))
# 551 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 66 "parser.mly"
                 (M.M.WRITE (_2))
# 558 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 67 "parser.mly"
                  (M.M.MALLOC (_2))
# 565 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 68 "parser.mly"
                (M.M.BANG (_2))
# 572 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : M.M.exp) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : M.M.exp) in
    Obj.repr(
# 69 "parser.mly"
                            (M.M.PAIR (_2,_4))
# 580 "parser.ml"
               : 'aexpr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : M.M.decl) in
    Obj.repr(
# 71 "parser.mly"
            ([_1])
# 587 "parser.ml"
               : 'decls))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'decls) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : M.M.decl) in
    Obj.repr(
# 72 "parser.mly"
                 (_1 @ [_2])
# 595 "parser.ml"
               : 'decls))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 74 "parser.mly"
                        (M.M.VAL(_2, _4))
# 603 "parser.ml"
               : M.M.decl))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : M.M.exp) in
    Obj.repr(
# 75 "parser.mly"
                                     (M.M.REC(_2, _5, _7))
# 612 "parser.ml"
               : M.M.decl))
(* Entry program *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let program (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : M.M.exp)
;;