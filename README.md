# haskell_stuff
Repo for stuff I made in haskell 

## ast_parser.hs
some tools for parsing/evaling math expressions with:
- a lexer which converts a string math expression into a sequence of "tokens" (i.e. strip spaces and collect parantheses, arithmetic operations and numbers together)
- a parser which converts the token sequence into an abstract syntax tree (ast)
- an evaluator which uses the syntax tree to recursively evaluate everything

was a fun exercise. implementation was a bit shoddy, and the parser was something i cooked up from scratch (already knew theory of lexing + AST). with haskell being functional, stuff like parsing for expressions while accounting brackets was quite easy! there's a nice trick of handing off "the rest of the tokens needed to parse" from the parsing function itself - may have abused it a bit too much, but i assume it's idiomatic to haskell 'cause lists are linked lists.

tricky part was operator precedence, but we can note there's two ways to solve the issue - either capture a sequence of operators increasing by precedence, subtree them together under repeated right branches and use that entire tree as the left subtree for the next operator and repeat, or construct the subtree upwards with left branches for a sequence of operators decreasing by precedence and then subtree the rest under the right branch of that and repeat.

nonetheless, (i think) two levels of recursion are required, otherwise it becomes too stateful. was being a bit pedantic on what data is passed into the second level of recursion whilst ensuring its as clean as possible - the current approach passes the previous operator + the term ssubsequent to it and uses function overloading to handle empty list/right parenthesis cases. i believe it works somewhat-best as function pattern matching is used well, not too many function arguments are passed and each function is generally responsible only for one thing (i.e. not too many if/case statements). 

probably didn't follow typical haskell style convention very well :P lots of snake casing and "verbose" variable names (personally i like long variable names but this definitely errs on too long :D)
