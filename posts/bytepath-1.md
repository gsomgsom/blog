## Introduction

This tutorial series will cover the creation of a complete game with [Lua](https://www.lua.org/) and [LÖVE](https://love2d.org/). It's aimed at peogrammers who have some experience but are just starting out with game development, or game developers who already have some experience with other languages or frameworks but want to figure out Lua or LÖVE better.

The game that will be created is called 「ＢＹＴＥＰＡＴＨ」 and it's a mix of [Bit Blaster XL](http://store.steampowered.com/app/433950/) and [Path of Exile's Passive Skill Tree](https://www.pathofexile.com/passive-skill-tree). It's simple enough that it can be covered in a number of articles without extending for too long, but with enough content that a beginner would feel uncomfortable with the code and end up giving up before finishing.

<p align="center">
    <img src="https://github.com/adonaac/blog/raw/master/images/bytepath-gameplay.gif"/>
</p>

It's also at a level of complexity that most game development tutorials don't cover. Most of the problems beginners have when starting out with game development has to do with scope. The usual advice is to start small and work your way up, and while that might be a good idea, if the types of projects you're interested in cannot be made any smaller then there are very few resources out there that attempt to guide you through the problems that come up.

<p align="center">
    <img src="https://github.com/adonaac/blog/raw/master/images/bytepath-tree.gif"/>
</p>

In my case, I've always been interested in making games with lots and lots of items/passives/skills and so when I was starting out it was really hard to figure out a good way to structure my code so that I wouldn't get lost. Hopefully these tutorials can help someone with that.

<br>

## Requirements

Before you start there are some programming knowledge requirements:

* The basics of programming, like variables, loops, conditionals, basic data structures and so on;

* The basics of OOP, like knowing what classes, instances, attributes and methods are;

* And the very basics of Lua, [this quick tutorial](http://tylerneylon.com/a/learn-lua/) should be good enough.

Essentially this is not for people who are just getting started with programming in general. Also, this tutorial series will have exercises. If you've ever been in the situation where you finish a tutorial and you don't know what to do next it's probably because it had no exercises, so if you don't want that to happen here then I recommend at least trying to do them.

<br>

## START

To start off you need to install LÖVE on your system and then figure out how to run LÖVE projects. You can follow the steps from [here](https://love2d.org/wiki/Getting_Started) for that.

Once that's done you should create a `main.lua` file in your project folder with the following contents:

```lua
function love.load()

end

function love.update(dt)

end

function love.draw()

end
```

If you run this you should see a window popup and it should show a black screen. In the code above, once your LÖVE project is run the `love.load` function is run once at the start of the program and `love.update` and `love.draw` are run every frame. So, for instance, if you wanted to load an image and draw it, you'd do something like this:

```lua
function love.load()
    image = love.graphics.newImage('image.png')
end

function love.update(dt)

end

function love.draw()
    love.graphics.draw(image, 0, 0)
end
```

`love.graphics.newImage` loads the image texture to the `image` variable and then every frame it's drawn at position 0, 0. To see that `love.draw` actually draws the image on every frame, try this:

```lua
love.graphics.draw(image, love.math.random(0, 800), love.math.random(0, 600))
```

The default size of the window is 800x600, so what this should do is randomly draw the image around the screen really fast:

<p align="center">
  <img src="https://vgy.me/vY9nLX.gif"/>
</p>

Note that between every frame the screen is cleared, otherwise the image you're drawing randomly would slowly fill the entire screen as it is drawn in random positions. This happens because LÖVE provides a default game loop for its projects that clears the screen at the end of every frame. I'll go over this game loop and how you can change it now.

<br>

## Game Loop

The default game loop LÖVE uses can be found in the [`love.run`](https://love2d.org/wiki/love.run) page, and it looks like this:

```lua
function love.run()
    if love.math then
		love.math.setRandomSeed(os.time())
	end

	if love.load then love.load(arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end
end
```

When the program starts `love.run` is run and then from there everything happens. The function is fairly well commented and you can find out what each function does on the LÖVE wiki. But I'll go over the basics:

```lua
if love.math then
    love.math.setRandomSeed(os.time())
end
```

In the first line we're checking to see if `love.math` is not nil. In Lua all values are true, except for false and nil, so the `if love.math` condition will be true if `love.math` is defined as anything at all. In the case of LÖVE these variables are set to be enabled or not in the [`conf.lua`](https://love2d.org/wiki/Config_Files) file. You don't need to worry about this file for now, but I'm just mentioning it because it's in that file that you can enable or disable individual systems like `love.math`, and so that's why there's a check to see if it's enabled or not before anything is done with one of its functions.

In general, if a variable is not defined in Lua and you refer to it in any way, it will return a nil value. So if you ask `if random_variable` then this will be false unless you defined it before, like `random_variable = 1`.

In any case, if the `love.math` module is enabled (which it is by default) then its seed is set based on the current time. See [`love.math.setRandomSeed`](https://love2d.org/wiki/love.math.setRandomSeed) and [`os.time`](https://www.lua.org/pil/22.1.html). After doing this, the `love.load` function is called:

```lua
if love.load then love.load(arg) end
```

`arg` are the command line arguments passed to the LÖVE executable when it runs the project. And as you can see, the reason why [`love.load`](https://love2d.org/wiki/love.load) only runs once is because it's only called once, while the update and draw functions are called multiple times inside a loop (and each iteration of that loop corresponds to a frame).

```lua
-- We don't want the first frame's dt to include time taken by love.load.
if love.timer then love.timer.step() end

local dt = 0
```

After calling `love.load` and after that function does all its work, we verify that `love.timer` is defined and call [`love.timer.step`](https://love2d.org/wiki/love.timer.step), which measures the time taken between the two last frames. As the comment explains, `love.load` might take a long time to process (because it might load all sorts of things like images and sounds) and that time shouldn't be the first thing returned by `love.timer.getDelta` on the first frame of the game.

`dt` is also initialized to 0 here. Variables in Lua are global by default, so by saying `local dt` it's being defined only to the local scope of the current block, which in this case is the `love.run` function. See more on blocks [here](https://www.lua.org/pil/4.2.html).

```lua
-- Main loop time.
while true do
    -- Process events.
    if love.event then
        love.event.pump()
        for name, a,b,c,d,e,f in love.event.poll() do
            if name == "quit" then
                if not love.quit or not love.quit() then
                    return a
                end
            end
            love.handlers[name](a,b,c,d,e,f)
        end
    end
end
```

This is where the main loop starts. The first thing that is done on each frame is the processing of events. [`love.event.pump`](https://love2d.org/wiki/love.event.pump) pushes events to the event queue and according to its description those events are generated by the user in some way, so think key presses, mouse clicks, window resizes, window focus lost/gained and stuff like that. The loop using [`love.event.poll`](https://love2d.org/wiki/love.event.poll) goes over the event queue and handles each event. `love.handlers` is a table of functions that calls the relevant callbacks. So, for instance, `love.handlers.quit` will call the `love.quit` function if it exists.

One of the things about LÖVE is that you can define callbacks in the `main.lua` file that will get called when an event happens. A full list of all callbacks is available [here](https://love2d.org/wiki/love). I'll go over callbacks in more detail later, but this is how all that happens. The `a, b, c, d, e, f` arguments you can see passed to `love.handlers[name]` are all the possible arguments that can be used by the relevant functions. For instance, [`love.keypressed`](https://love2d.org/wiki/love.keypressed) receives as arguments the key pressed, its scancode and if the key press event is a repeat. So in the case of `love.keypressed` the `a, b, c` values would be defined as something while `d, e, f` would be nil.

```lua
-- Update dt, as we'll be passing it to update
if love.timer then
    love.timer.step()
    dt = love.timer.getDelta()
end

-- Call update and draw
if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
```

[`love.timer.step`](https://love2d.org/wiki/love.timer.step) measures the time between the two last frames and changes the value returned by [`love.timer.getDelta`](https://love2d.org/wiki/love.timer.getDelta). So in this case `dt` will contain the time taken for the last frame to run. This is useful because then this value is passed to the `love.update` function, and from there it can be used in the game to define things with constant speeds, despite frame rate changes.

```lua
if love.graphics and love.graphics.isActive() then
    love.graphics.clear(love.graphics.getBackgroundColor())
    love.graphics.origin()
    if love.draw then love.draw() end
    love.graphics.present()
end
```

After calling `love.update`, `love.draw` is called. But before that we verify that the `love.graphics` module exists and that we can draw to the screen via [`love.graphics.isActive`](https://love2d.org/wiki/love.graphics.isActive). The screen is cleared to the defined background color (initially black) via [`love.graphics.clear`](https://love2d.org/wiki/love.graphics.clear), transformations are reset via [`love.graphics.origin`](https://love2d.org/wiki/love.graphics.origin), `love.draw` is finally called and then [`love.graphics.present`](https://love2d.org/wiki/love.graphics.present) is used to push everything drawn in `love.draw` to the screen. And then finally:

```lua
if love.timer then love.timer.sleep(0.001) end
```

I never understood why [`love.timer.sleep`](https://love2d.org/wiki/love.timer.sleep) needs to be here at the end of the frame, but the [explanation given by a LÖVE developer here](https://love2d.org/forums/viewtopic.php?f=4&t=76998&p=198629&hilit=love.timer.sleep#p160881) seems reasonable enough.

And with that the `love.run` function ends. Everything that happens inside the `while true` loop is referred to as a frame, which means that `love.update` and `love.draw` are called once per frame. The entire game is basically repeating the contents of that loop really fast (like at 60 frames per second), so get used to that idea. I remember when I was starting it took me a while to get an instinctive handle on how this worked for some reason.

There's a helpful discussion on this function on the [LÖVE forums](https://love2d.org/forums/viewtopic.php?t=83578) if you want to read more about it.

Anyway, if you don't want to you don't need to understand all of this at the start, but it's helpful to be somewhat comfortable with editing how your game loop works and to figure out how you want it to work exactly. There's an excellent article that goes over different game loop techniques and does a good job of explaining each. You can find it [here](http://gafferongames.com/game-physics/fix-your-timestep/).

<br>

### Game Loop Exercises

**1\.** Implement the `Fixed Delta Time` loop from the Fix Your Timestep article by changing `love.run`.

**2\.** Implement the `Variable Delta Time` loop from the Fix Your Timestep article by changing `love.run`.

**3\.** Implement the `Semi-Fixed Timestep` loop from the Fix Your Timestep article by changing `love.run`.

**4\.** Implement the `Free the Physics` loop from the Fix Your Timestep article by changing `love.run`.

<br>

### Game Loop Exercises HELP!

I'm going to go over the solution for the first two exercises. In general I'm not going to provide answers to exercises because it would take me a lot of time to do so and because the process you take to get to the answers is the most important part of it all, and often that will involve some googling. But for these first parts I'll go over a few of the solutions to help a little.

---

For the first question, we want to implement the `Fixed Delta Time` loop. As the article states, this one uses a fixed delta of 1/60s. In the default `love.run` function the delta changes based on the value returned by `love.timer.getDelta`, and that changes based on the time taken between the two last frames. So the default implementation is definitely not a fixed delta of 1/60s. To achieve that, we need to first remove the sections that change the delta in any way. So this piece of code will be commented out:

```lua
if love.timer then
    love.timer.step()
    dt = love.timer.getDelta()
end
```

And then we need to define our `dt` variable to the value we want it to have, which is 1/60:

```lua
local dt = 1/60
```

And then the final `love.run` function would look like this:

```lua
function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
	end

	if love.load then love.load(arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	-- if love.timer then love.timer.step() end

	local dt = 1/60

	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

    --[[
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
    ]]--

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end
end
```

So we commented out sections that updated `dt` or that called `love.timer.step`. (`--` is used to comment out a line and `--[[]]--` is used to comment out blocks of code in Lua) We defined `dt` as 1/60 and the rest of the function remains exactly the same. The problems with this approach are explained in the article, but that's how you'd do it if you wanted to for some reason.

---

The second question asks for the implementation of the `Variable Delta Time` loop. The way this is described is as follows:

> Just measure how long the previous frame takes, then feed that value back in as the delta time for the next frame.

If we go back to the description of the `love.timer.step` and `love.timer.getDelta` functions, that's exactly what they do. So, as it turns out, there seems to be no differences between the default `love.run` implementation and `Variable Delta Time`.

<br>

## END

And with that this part of the tutorial is over. By now you should be able to run basic LÖVE projects and have some understanding of how its game loop works. For the next part I'll introduce some useful libraries that will be used throughout the entire project.
