`2016-02-05 13:46`

Yesterday I read a blog post, [this one](http://benmccormick.org/2016/01/08/reusable-code-patterns/), about code reuse patterns. I think it's mostly correct in its assessments but IMO it doesn't do justice to the **Copy and Paste** technique. So in this post I'll explain why I think copypasting your own code instead of properly making it reusable is a good idea more often than you'd think, especially if you're an indie developer working on an indie game. Also, if you're surprised like [this guy](https://www.reddit.com/r/gamedev/comments/445dr1/state_of_game_code/) at how "bad" game code can be, hopefully this article will shed some light into why that's often true.

<br>

## Reuse

My main argument is that the costs of copypasting are often lower than the ongoing costs of properly making things reusable. So first let's try an example showing the process of making reusable code. This example will use functions but the same thought process applies to classes, mixins, components, inheritance and what have you that you decide to use to reuse code.

So assume we want to add functionality `X` to the codebase and it's made up of three logical parts, `A`, `B` and `C`. I'd do that like this:

```lua
-- A, explains what A does
block 1
block 2
block 3

-- B, explains what B does
block 4
block 5

-- C, explains what C does
block 6
block 7
block 8
```

If I'm only using `X` in one place I'd probably write it like I wrote it up there, with simple comments (-- are comments) dividing the different logical sections and explaining what each section does when necessary. If I'm calling `X` from multiple places then I'd wrap the above code in a function named `X`.

This is all good and simple so far. But now suppose we want to add functionality `Y`. And this new functionality is really similar to `X`, in that it uses `A`, `B` and `C`, except `A` has to be a bit different, maybe `block 2` has to be changed for `block 9`, and after `block 3` there should be an additional `block 10`.

So now first what we can do is take `B` and `C` out into their own functions, since they're going to be reused by `X` and `Y`:

```lua
function B()
  block 4
  block 5
end

function C()
  block 6
  block 7
  block 8
end
```

And then what we can do is either create a new function `D`, which will be the modified `A`, or modify `A` such that it takes into account the possibilities that functionality `Y` needs. The first solution would look like this:

```lua
...
function A()
  block 1
  block 2
  block 3
end

function D()
  block 1
  block 9
  block 3
  block 10
end

function X()
  A()
  B()
  C()
end

function Y()
  D()
  B()
  C()
end
```

The problem with this solution is that now `block 1` and `block 3` are repeated on `A` and `D` and since we want to minimize code repetition this won't work.

The second solution avoids code duplication by doing this:

```lua
...
function A(y_flag)
  block 1

  if d_flag
    block 9
  else
    block 2

  block 3

  if d_flag
    block 10
end

function X()
  A()
  B()
  C()
end

function Y()
  A(y_flag = true)
  B()
  C()
end
```

This solution is better from a code duplication perspective because it gets rid of it, but it also has its own problems in that as the needs of `A` grow with more and more functionalities, it will become a confusing land of random conditionals and settings that is going to be really hard to logically follow.

Anyway, either solution chosen, suppose now that we want to add functionality `Z`, which, again, is really similar to both `X` and `Y` but slightly different. Now `A` is also a little different where `block 3` needs to be `block 12`. And again, we can go through the same exercise of either choosing to create a new function `E` that will be exactly what `Z` needs:

```lua
function A()
  block 1
  block 2
  block 3
end

function D()
  block 1
  block 9
  block 3
  block 10
end

function E()
  block 1
  block 2
  block 12
end

function X()
  A()
  B()
  C()
end

function Y()
  D()
  B()
  C()
end

function Z()
  E()
  B()
  C()
end
```

Or changing `A` to suit `Z`'s needs:

```lua
...
function A(y_flag, z_flag)
  block 1

  if y_flag
    block 9
  else
    block 2

  if z_flag
    block 12
  else
    block 3

  if y_flag
    block 10
end

function X()
  A()
  B()
  C()
end

function Y()
  A(y_flag = true)
  B()
  C()
end

function Z()
  A(z_flag = true)
  B()
  C()
end
```

Either way we choose, we lose. This is because this exercise will keep going on and on forever as we add new functionality to our codebase, and as the codebase grows, whatever we did to minimize code duplication will make it fundamentally more complex. The solution where you add a new function adds a new node to your code, and with a new node now you have more dependencies to think about and worry about. The solution where you add flags and settings adds logical complexity to the flow of the affected function, which makes the code a lot harder to reason about. Any other solution out of this problem will do either of those things and complexity will grow.

The point here is not that code reuse is bad, but that there are ongoing costs to making things reusable. The cost here is that at each point you have to add a new functionality, you'll have to think about which solution to choose to minimize duplication and which previous components/functions that exist in the codebase that you should look at to change and/or use. The process of building reusable code is one where you have to think about how to integrate new functionality against existing code instead of just adding new functionality. This is a huge mental resource drain that most people forget to take into account.

<br>

## Copypasting

Now let's look at the same example through a copypasting lens. We add functionality `X`:

```lua
function X()
  -- A
  block 1
  block 2
  block 3

  -- B
  block 4
  block 5

  -- C
  block 6
  block 7
  block 8
end
```

Now we want to add functionality `Y`, which is a bit different from `X` in the ways described earlier. Instead of worrying about what can and can't be reused, we'll just copy paste `X` and change what needs to be changed:

```lua
function Y()
  -- A
  block 1
  block 9
  block 3
  block 10

  -- B
  block 4
  block 5

  -- C
  block 6
  block 7
  block 8
end
```

Now we want to add functionality `Z`, which is similar to `X` and `Y`. Again, instead of worrying about what can and can't be reused, we'll just copy paste `X` again and change what needs to be changed:

```lua
function Z()
  -- A
  block 1
  block 2
  block 11

  -- B
  block 4
  block 5

  -- C
  block 6
  block 7
  block 8
end
```

Isn't this process much much simpler? This takes no mental effort at all. You literally just copypaste and change what needs to be changed. Yes, there are very obvious problems with copypasting. If we want to change how `B` works for instance now we have 3 places where we have to make that change. And that's a bad thing! But my point is that people should know when the costs of doing this are higher than the ongoing costs of making things reusable and when they aren't.

The upfront costs of copypasting are usually a lot lower than the upfront costs of making things reusable. This is a fact. The long term costs of copypasting are usually a lot higher than the long term costs of making things reusable. This is another fact. But people often forget about the first fact and that they can use both of them to make reasonable and responsible trades in their codebase. The lower upfront costs of copypasting can be extremely useful in a huge number of situations, but a lot of people default to reuse always, and that's a huge waste of mental resources and a huge unnecessary increase in complexity.

<br>

## Frequency of Change

One of the ways you can use to figure out when using copypasting actually makes sense is looking at the frequency of change of some part of your codebase. If in the example above we know (through experience or instinct) that `C` is a piece of code that has a very low frequency of change, then it makes a lot of sense to not care about it from a code duplication perspective, because most of the time it won't be changed.

For instance, suppose that for every 20 functionalities we add that are similar enough to `X`, only once does `C` change. In this case it makes sense to put `C` away as a function, call it from `X` and then just copypaste `X` each time for each new functionality. When `C` changes (which doesn't happen often), we'll either have to change the function itself or add a new function similar enough to `C`, which is exactly what we did for `A` in the example above. The difference here is that instead of defaulting to reuse, we default to copypaste and use reuse where it actually makes sense to use it. And we do this because the situation called for it, not because we just decided that this was going to be a rule that we always follow.

<br>

## Example

So now for a real example. This is an attack in one of the games I'm working on:

<p align="center">
    <img src="https://github.com/adonaac/blog/raw/master/images/punch.gif"/>
</p>

It's a 3 part melee attack, light -> medium -> heavy punches as the player presses the same key over and over. All that's happening to make this happen is: player presses key, character plays some animation, a hitbox is created to see if the attack hit anyone, then if it hit someone a series of events happen, like the enemy gets pushed back and loses some HP, and the camera shakes, and some particles fly around and so on. To get this attack going I need 3 main files.

The first file is an attack object. This gets attached to the player and then input is directed to the current attack attached to the key pressed. The attack object has state and logic needed to make the player side of this attack work, which is logic needed for which animation to play (if the sequence is in light, medium or heavy punch stage), cooldowns, pushing the player forward or backwards a bit and so on. This is also where the melee hitbox gets created.

The second file is the melee hitbox. This is just a normal hitbox that collides with relevant enemies to see if the attack hit them or not. If it collides, this calls the appropriate function for this attack and passes as arguments to it the hitbox, the player, the enemy hit and some other additional necessary data.

The third file is the function that gets called by the melee hitbox. I call these functions events. Basically they're functions that will receive all interested parties of this attack and do things to them, like deal damage to enemies, give HP back to the player if it has some life leech passive, shake the screen, add some effects, create particles and so on.

Out of these files, the first and third ones are the ones I'm constantly copy pasting. If I want to add another 3 stage attack for instance, but with kick animations instead of punches, I'll just copy paste the 3 stage punch and change what's needed to change. The same goes for the third file. If some event is similar enough to the event of another attack I'll just copy paste it. And this is the optimal course of action for attacks. Because I'm constantly adding attacks to the game and very rarely changing how attacks in general work. The times where I need to change something for all attacks happen, but they're really rare compared to the times where I have to add a new attack. So it makes the most sense to minimize costs of adding new attacks by levering the low upfront costs of copypasting.

---

The general rule here is that a lot of the times it's better to optimize for *process simplification* than it is to optimize for code reuse. And this is especially true with indie game development. Simple processes for doing things to your game require less mental effort, which means you can work for longer and you're less likely to get demotivated by high complexity.

At the same time, when you do need to do something dumb like changing the general case in 20 places because you didn't abstract things properly, this is dumb work that is also very easy to do and that you don't need to think about, which also minimizes mental effort spent. And on top of this, since gameplay code is often changing in unexpected ways, it's usually better to start from dumb code and generalize from there than it is to start from generalized code and working your way backwards.

<br>

## END

Hopefully we've all learned something from this. One thing I noticed is that often times I see indie developers with amazing games, but by all normal standards if you were to look at their code they would be considered bad coders who just don't know any good practices.

I think intuitively people realize that doing things like what I outlined in this article is a good idea, and so you get lots of "dumb" code that works. However, you don't need to go that far. If you're able to analyze these tradeoffs properly you can make informed decisions instead of just doing the dumb thing because you didn't know any better, and this will result in less costs for you even though it looks like it costs a lot.
