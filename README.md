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
| While Loop | Tradtional: <br> `while(x < 10) {`<br> &emsp; `x = x + 1 :3` <br> `}` <br> With break statement: <br> `while(x > 10) {` <br> &emsp; `if(x == 10000)` <br> &emsp; &emsp; `GROWL :3` <br> `}` <br> With continue statement:  <br>`while(x > 10) {` <br> &emsp; `if(x == 10000)` <br> &emsp; &emsp; `keep going :3` <br> `}`
| If-then-else Statements | `if(y < 3) {` <br> &emsp; `y = y + 1 :3` <br>`}` <br> `else if(y > 3) {` <br> &emsp; `y = y - 1 :3` <br> `}` <br> `else {` <br> &emsp; `x = x + 1 :3` <br> `}`
| Read and Write Statements | Print to terminal: <br> `scratch(x) :3` <br> `scratch(x + 2) :3` <br> Read from terminal: <br> `litter(x) :3` 
| Comments | `O_O this is a comment` <br> `meow x = 2 :3 O_O this will be ignored`
| Functions | `purr meow add(meow x, meow y) {` <br> &emsp; `meow z = x + z :3` <br> &emsp; `return z :3` <br> `}` <br> `meow a = add(x, y) :3`

| Symbol in Language | Token Name |
| :----------------- | ---------- |
| 