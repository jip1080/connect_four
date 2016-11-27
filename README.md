== Connect Four

Connect Four is a two player strategy game where players take turns dropping
colored discs into a six row by seven column grid. The first player to
connect four or more discs of their color in a line wins. The line may be
horizontal, vertical or diagonal.

This implementation of Connect Four uses a bitboard to store the current state of the board. Actually, it uses multiple bitboards. One to store the available columns and one bitboard for each player's moves. Since we can shift bits very quickly programatically and can quickly do bitwise comparisons, checking the state of the game is very quick. However, the math to do all of this programatically can be somewhat complex.

What does a bitboard look like?
```ruby
0
```
Not very interesting.  Let's check a different example for the following board:


col1 | col2 | col3 | col4
----- | ------ | ------ | ------
 a | b | b | a
 b | r | b | a
 r | r | r | r
 
 where a = available, b = black, r = red
 There will be three bitboards to represent this state.  They will be:<br>
```
 Available: `515`
 Red:       `2468`
 Black:     `1112`
``` 
 Still not interesting.  So let's make them a little more interesting by doing a `.to_s(2)` on them:<br>
 ```
 Available: `0b001000000011`
 Red:       `0b100110100100`
 Black:     `0b010001011000`
 ```
 
 Let's break down the available board to show the correspondence now.  Let's split it to 4 columns of 3 rows:
 ```
001
000
000
011
 ```
 "Wait, that is 4 rows of 3 columns!" - says the person reading this right now
 Yep.  Now tilt your head to the right 90 degrees; do the 1's suddenly correspond to the entries in the table above for the available spots?  That's because we count from the lower left position as our leading bit, and count up the rows within the first column until we hit the top.  Then we wrap around to the bottom of the next column.
 
 The red and black player boards will look like this respectively:
```
Red:
100
110
100
100
 ```
 ```
 Black:
 010
 001
 011
 000
 ```
 So now we have our bitboard representations of the available board, the red player and the black player.  Let's shift this a bit! (sorry for the pun...).  We can see that red has 4-in-a-row along the bottom.  How would we know from the bitboard representation though?
 Easy!  Like this (shorthanding the board as `red`):
```
shift_1 = (red & (red >> 3) 
shift_1 & (shift_1 >> (2 * 3)) > 0
```
Simple!  And really fast!  OK, so maybe a little harder to grok than just reading the equation, so let's look at the bitboard representation to see what is happening:
`red >> 3` means to shift the board 3 bits (or 1 column) to the right, which results in this:
```
000
100
110
100
```
When we logically and (`&`) the shifted board with the original we end up with:
```
100   000   000
110   100   100
100 & 110 = 100
100   100   100
```
So that is our `shift_1` variable which represents the one-column shifted overlap (we can see where there are neighboring bits in other words).
Next we take our shift_1 value and shift it again:
`shift_1 >> (2 * 3))`
This is moving all of these neighbor indicating bits two columns to the right, resulting in:
```
000
000
000
100
```
The neighbor shifting shows us that we have three in a row , and logically and'ing this with the original shift shows us we have four-in-a-row with:
`shift_1 & (shift_1 >> (2*3))`
resulting in:
```
000   000   000
000   000   000
000 & 000 = 000
100   100   100
```
which is greater than 0, meaning we hit on all our shifts in at least one location.

The equations for checking are as follows:
```
row win # | check as data is represented, - as board is displayed
shift_1 = board & (board  >> 1)
shift_1 & (shift_1 >> 2) >0

column win # - check as data is represented, | as board is displayed
shift_1 = board & (board >> (row_count))
shift_1 & (shift_1 >> (2 * row_count)) > 0

forward diagonal # / check as data is represented, \ as displayed
shift_1 = board & (board >> (row_count - 1))
shift_1 & (shift_1 >> (2 * (row_count -1))) > 0

backward diagonal # \ check as data is represented, / as displayed
shift_1 = board & (board >> (row_count + 1))
shift_1 & (shift_1 >> (2 * (row_count + 1)) > 0
```

