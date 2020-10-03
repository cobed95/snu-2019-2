//
// test07
//
// strings
//
// expected output: "Hello, world!" twice
//

module test07;

const
  HelloWorld : char[] = "Hello, world!";

begin
  WriteStr("Hello, world!"); WriteLn();
  WriteStr(HelloWorld); WriteLn()
end test07.
