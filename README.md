# Cat++

Language: Cat++

Extension: `.meow`

Name for compiler: CATNIP

Features of Cat++

| Language Feature | Code Example |
| :---------------- | ------------ |
| Integer Scalar Variables | `meow x :3` <br> `meow y :3` <br> `meow z :3` <br> `meow avg :3`
| One-dimensional Arrays of Integers | `meow a[12] :3` <br> `a[0] = 3 :3`
| Assignment Statements | `meow x = 1 :3` <br> `x = 2 :3`
| Arithmetic Operators | `meow x = 1 + 1 :3` <br> `x = x + 1 :3` <br> `meow y = x - 1 :3` <br> `y = x * y :3` <br> `meow z = y / 2 :3` <br> `z = 1 + x - y * z / 4 :3` 
| Relational Operators | `x != y :3` <br> `x < y :3` <br> `x > y :3` <br> `x <= y :3` <br> `x >= y :3` <br> `x == y :3`
| While Loop | Traditional: <br> `hunt(x < 10) {`<br> &emsp; `x = x + 1 :3` <br> `}` <br> With break statement: <br> `hunt(x > 10) {` <br> &emsp; `purrhaps(x == 10000) {` <br> &emsp; &emsp; `neuter :3` <br> &emsp; `}` <br> `}` <br> With continue statement:  <br>`hunt(x > 10) {` <br> &emsp; `purrhaps(x == 10000) {` <br> &emsp; &emsp; `keep_going :3` <br>&emsp;`}` <br> `}`
| If-then-else Statements | `purrhaps(y < 3) {` <br> &emsp; `y = y + 1 :3` <br>`}` <br> `else purrhaps(y > 3) {` <br> &emsp; `y = y - 1 :3` <br> `}` <br> `else {` <br> &emsp; `x = x + 1 :3` <br> `}`
| Read and Write Statements | Print to terminal: <br> `scratch(x) :3` <br> `scratch(x + 2) :3` <br> Read from terminal: <br> `litter(x) :3` 
| Comments | `O_O this is a comment` <br> `meow x = 2 :3 O_O this will be ignored`
| Functions | `purr meow add(meow x, meow y) {` <br> &emsp; `meow z = x + z :3` <br> &emsp; `knead z :3` <br> `}` <br> `purr meow main() {`<br> &emsp; `meow a = add(x, y) :3` <br> `}`

| Symbol in Language | Token Name |
| :----------------- | ---------- |
| `purr` | FUNCTION |
| `meow` | INTEGER |
| `:3` | SEMICOLON |
| `neuter` | BREAK |
| `keep_going` | CONTINUE |
| `purrhaps` | IF |
| `O_O` | COMMENT |
| `scratch` | PRINT |
| `litter` | READ |
| `knead` | RETURN |
| `hunt` | WHILE |
| `=` | ASSIGN |
| `-` | SUB |
| `+` | ADD |
| `*` | MULT |
| `/` | DIV |
| `%` | MOD |
| `else` | ELSE |
| `,` | COMMA |
| `(` | LEFT_PARENTHESIS |
| `)` | RIGHT_PARENTHESIS |
| `[` | LEFT_SQUARE_BRACKET |
| `]` | RIGHT_SQUARE_BRACKET |
| `{` | LEFT_CURLY |
| `}` | RIGHT_CURLY |
| identifier | IDENTIFIER identifier |
| number | NUMBER number |
| `==` | EQUALS |
| `<` | LESSTHAN |
| `>` | GREATERTHAN |
| `<=` | LESSOREQUAL |
| `>=` | GREATOREQUAL |
| `hairball` | VOID |