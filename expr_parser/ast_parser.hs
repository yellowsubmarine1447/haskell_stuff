import Data.Char

data Operator
 = Add
 | Multiply
 deriving (Show, Eq)

data Token
 = Number Int
 | OperatorToken Operator
 | LParen -- (
 | RParen -- )
 deriving Show

data Expr
 = Lit Int
 | OperatorExpr Operator Expr Expr
 deriving Show

precedence_value :: Operator -> Int
precedence_value Add = 0
precedence_value Multiply = 1 

instance Ord Operator where
 compare l r = compare (precedence_value l) (precedence_value r)

message_with_object :: Show a => String -> a -> String
message_with_object custom_message object = custom_message ++ ": '" ++ show object ++ "'"

lexer :: String -> [Token]
lexer [] = []
lexer (c : cs)
 | isSpace c = lexer cs
 | c == '+' = OperatorToken Add : lexer cs
 | c == '*' = OperatorToken Multiply : lexer cs
 | c == '(' = LParen : lexer cs
 | c == ')' = RParen : lexer cs
 | isNumber c =
  let (rest_of_digits, rest_of_chars) = span isNumber cs
      number = read (c : rest_of_digits)
  in Number number : lexer rest_of_chars
 | otherwise = error (message_with_object "Unable to parse token for character" c)

parser :: [Token] -> Expr
parser ts
 = let (expr, remaining_tokens) = parse_expression_body ts
   in case remaining_tokens of
    [] -> expr
    (t : _) -> error (message_with_object "Parsed expression but found at least remaining token starting from" t)

parse_single_term :: [Token] -> (Expr, [Token])
parse_single_term [] = error "No more tokens found when parsing term in expression"
parse_single_term (Number n : ts) = (Lit n, ts)
parse_single_term (LParen : ts)
 = let (expr, after_expression) = parse_expression_body ts
   in case after_expression of
    (RParen : rest_after_right_bracket) -> (expr, rest_after_right_bracket)
    (invalid_token : _) -> error (message_with_object "Expected right bracket to close expression but got" invalid_token)
    [] -> error "Expected right bracket to close expression but found no more tokens to parse"
parse_single_term (t : _) = error (message_with_object "Expected term for expression but found token" t)

parse_expression_body :: [Token] -> (Expr, [Token])
parse_expression_body [] = error "Expected expression body but ran out of tokens"
parse_expression_body ts
 = let (first_term, rest_after_first_term) = parse_single_term ts
   in parse_operator_chain first_term rest_after_first_term

parse_operator_chain :: Expr -> [Token] -> (Expr, [Token])
parse_operator_chain lhs [] = (lhs, [])
parse_operator_chain lhs (RParen : ts) = (lhs, (RParen : ts))
parse_operator_chain lhs (OperatorToken op : ts)
 = let (next_term, rest_after_next_term) = parse_single_term ts
       (rhs_subtree, rest_after_increasing_operators) = parse_operators_in_increasing_precedence op next_term rest_after_next_term
   in parse_operator_chain (OperatorExpr op lhs rhs_subtree) rest_after_increasing_operators
parse_operator_chain _ (t : _) = error (message_with_object "Expected expression to close or admit an operator but found token" t)

parse_operators_in_increasing_precedence :: Operator -> Expr -> [Token] -> (Expr, [Token])
parse_operators_in_increasing_precedence _ rhs [] = (rhs, []) -- rhs of previous operator 
parse_operators_in_increasing_precedence _ rhs (RParen : ts) = (rhs, (RParen : ts)) -- rhs of previous operator, and make sure to return RParen so ancestral parse_operator_chain can terminate
parse_operators_in_increasing_precedence previous_op lhs (OperatorToken next_op : ts) -- in this case, we are dealing with an lhs for the next operator we will parse from the list
 = if previous_op < next_op
   then
    let (next_term, rest_after_next_term) = parse_single_term ts
        (rhs, rest_after_rhs) = parse_operators_in_increasing_precedence next_op next_term rest_after_next_term
    in (OperatorExpr next_op lhs rhs, rest_after_rhs)
   else (lhs, (OperatorToken next_op : ts)) -- return next_op as well for use again
parse_operators_in_increasing_precedences _ _ (t : ts) = error (message_with_object "Expected expression to close or admit an operator but found token" t)

eval :: Expr -> Int
eval (Lit n) = n
eval (OperatorExpr Add l r) = (eval l) + (eval r)
eval (OperatorExpr Multiply l r) = (eval l) * (eval r) 
