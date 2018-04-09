## Введение

В этой части мы рассмотрим некоторые из библиотек Lua/LÖVE, которые необходимы для проекта, а также изучим являющиеся уникальными для Lua принципы, которые вам нужно начать осваивать. К концу этой части мы освоим четыре библиотеки. Одна из целей этой части — привыкание к идее загрузки библиотек, собранных другими людьми, к чтению их документации, изучению их работы и возможностей использования в своём проекте. Сами по себе Lua и LÖVE не обладают широкими возможностями, поэтому загрузка и использование кода, написанного другими людьми — стандартная и необходимая практика.

<br>

## Ориентация объектов

Первое, что я здесь рассмотрю — это ориентация объектов. Существует очень много способов реализации ориентации объектов в Lua, но мы просто воспользуемся библиотекой. Больше всего мне нравится ООП-библиотека [rxi/classic](https://github.com/rxi/classic) из-за её малого объёма и эффективности. Для её установки достаточно просто скачать её и перетащить папку classic внутрь папки проекта. Обычно я создаю папку libraries и скидываю все библиотеки туда.

Закончив с этим, мы можем импортировать библиотеку в игру в верхней части файла `main.lua` сделав следующее:

```lua
Object = require 'libraries/classic/classic'
```

Как написано на странице github, с этой библиотекой можно выполнять все обычные ООП-действия, и они должны нормально работать. При создании нового класса я обычно делаю это в отдельном файле и помещаю этот файл в папку `objects`. Тогда, например, создание класса `Test` и одного его экземпляра будет выглядеть так:

```lua
-- В файле objects/Test.lua
Test = Object:extend()

function Test:new()

end

function Test:update(dt)

end

function Test:draw()

end
```

```lua
-- В файле main.lua
Object = require 'libraries/classic/classic'
require 'objects/Test'

function love.load()
    test_instance = Test()
end
```

То есть при вызове `require 'objects/Test'` в `main.lua` выполняется всё то, что определено в файле `Test.lua`, а значит глобальная переменная `Test` теперь содержит определение класса Test. В нашей игре каждое определение класса будет выполняться таким образом, то есть названия классов должны быть уникальными, так как они привязываются к глобальной переменной. Если вы не хотите делать так, то можете внести следующие изменения:

```lua
-- В файле objects/Test.lua
local Test = Object:extend()
...
return Test
```

```lua
-- В файле main.lua
Test = require 'objects/Test'
```

Если мы сделаем переменную `Test` локальной в `Test.lua`, то она не будет привязана к глобальной переменной, то есть можно будет привязать её к любому имени, когда она потребуется в `main.lua`. В конце скрипта `Test.lua` возвращается локальная переменная, а поэтому в `main.lua` при объявлении `Test = require 'objects/Test'` определение класса Test присваивается глобальной переменной `Test`.

Иногда, например, при написании библиотек для других людей, так делать лучше, чтобы не загрязнять их глобальное состояние переменными своей библиотеки. Библиотека classic тоже поступает так, именно поэтому мы должны инициализировать её, присваивая переменной `Object`. Одно из хороших последствий этого заключается в том, что при присвоении библиотеки переменной, если мы захотим, то можем дать `Object` имя `Class`, и тогда наши определения классов будут выглядеть как `Test = Class:extend()`.

Последнее, что я делаю — автоматизирую процесс require для всех классов. Для добавления класса в среду нужно ввести `require 'objects/ClassName'`. Проблема здесь в том, что может существовать множество классов и ввод этой строки для каждого класса может быть утомительным. Так что для автоматизации этого процесса можно сделать нечто подобное:

```lua
function love.load()
    local object_files = {}
    recursiveEnumerate('objects', object_files)
end

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        if love.filesystem.isFile(file) then
            table.insert(file_list, file)
        elseif love.filesystem.isDirectory(file) then
            recursiveEnumerate(file, file_list)
        end
    end
end
```

Давайте разберём этот код. Функция `recursiveEnumerate` рекурсивно перечисляет все файлы внутри заданной папки и добавляет их в таблицу как строки. Она использует [модуль LÖVE filesystem](https://love2d.org/wiki/love.filesystem), содержащий множество полезных функций для выполнения подобных операций.

Первая строка внутри цикла создаёт список всех файлов и папок в заданной папке и возвращает их с помощью [`love.filesystem.getDirectoryItems`](https:/love2d.org/wiki/love.filesystem.getDirectoryItems). как таблицу строк. Далее она итеративно проходит по всем ним и получает полный путь к файлу конкатенацией (конкатенация строк в Lua выполняется с помощью `..`) строки `folder` и строки `item`. 

Допустим, что строка folder имеет значение `'objects'`, а внутри папки `objects` есть единственный файл с названием `GameObject.lua`. Тогда список `items` будет выглядеть как `items = {'GameObject.lua'}`. При итеративном проходе по списку строка `local file = folder .. '/' .. item` спарсится в `local file = 'objects/GameObject.lua'`, то есть в полный путь к соответствующему файлу.

Затем этот полный путь используется для проверки с помощью функций [`love.filesystem.isFile`](https://love2d.org/wiki/love.filesystem.isFile) и [`love.filesystem.isDirectory`](https://love2d.org/wiki/love.filesystem.isDirectory) того, является ли он файлом или каталогом. Если это файл, то мы просто добавляем его в таблицу `file_list` , переданную вызываемой функцией, в противном случае снова вызываем `recursiveEnumerate`, но на этот раз используем этот путь как переменную `folder`. Когда этот процесс завершится, таблица `file_list` будет заполнена строками, соответствующими путям ко всем файлам внутри `folder`. В нашем случае переменная `object_files` будет таблицей, заполненной строками, соответствующими всем классам в папке objects.

Остался ещё один шаг, заключающийся в добавлении всех этих путей в require:

```lua
function love.load()
    local object_files = {}
    recursiveEnumerate('objects', object_files)
    requireFiles(object_files)
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end
```

Тут всё гораздо понятнее. Код просто проходит по файлам и вызывает для них `require`. Единственное, что осталось — удалить `.lua` из конца строки, потому что функция `require` выдаёт ошибку, если его оставить. Это можно сделать строкой `local file = file:sub(1, -5)`, которая использует одну из встроенных [строковых функций](http://lua-users.org/wiki/StringLibraryTutorial). Так что после выполнения этого будут автоматически загружаться все классы, определённые внутри папки `objects`. Позже также будет использована функция `recursiveEnumerate` для автоматической загрузки других ресурсов, таких как изображения, звуки и шейдеры.

<br>

### Упражнения по ООП

**6.** Создайте класс `Circle`, получающий в своём конструкторе аргументы `x`, `y` и `radius`, имеющий атрибуты `x`, `y`, `radius` и `creation_time`, а также методы `update` и `draw`. Атрибуты `x`, `y` и `radius` должны инициализироваться со значениями, переданными из конструктора, а атрибут `creation_time` должен инициализироваться с относительным временем создания экземпляра (см. [love.timer](https://love2d.org/wiki/love.timer)). Метод `update` должен получать аргумент `dt`, а функция draw должна отрисовывать закрашенный цикл с центром в `x, y` с радиусом `radius` (см. [love.graphics](https://love2d.org/wiki/love.graphics)). Экземпляр этого класса `Circle` должен быть создан в позиции 400, 300 с радиусом 50. Он также должен обновляться и отрисовываться на экране. Вот, как должен выглядеть экран:

<p align="center">
<img src="https://github.com//gsomgsom/lua_gamedev_blog/raw/master/images/bytepath-oop-1.png"/>
</p>

**7.** Создайте класс `HyperCircle`, который наследует от класса `Circle`. `HyperCircle` похож на `Circle`, только вокруг него отрисовывается внешний круг. Он должен получать в конструкторе дополнительные аргументы `line_width` и `outer_radius`. Экземпляр этого класса `HyperCircle` нужно создать в позиции 400, 300 с радиусом 50, шириной линии 10 и внешним радиусом 120. Экран должен выглядеть вот так:

<p align="center">
<img src="https://github.com/gsomgsom/lua_gamedev_blog/raw/master/images/bytepath-oop-2.png"/>
</p>

**8.** Для чего в Lua служит оператор `:`? Чем он отличается от `.` и когда нужно использовать каждый из них?

**9.** Допустим, у нас есть следующий код:

```lua
function createCounterTable()
    return {
        value = 1,
        increment = function(self) self.value = self.value + 1 end,
    }
end

function love.load()
    counter_table = createCounterTable()
    counter_table:increment()
end
```

Каким будет значение `counter_table.value`? Почему функция `increment` получает аргумент с названием `self`? Может ли этот аргумент иметь какое-то другое название? И что это за переменная, которая в этом примере представлена `self`?

**10.** Создайте функцию, возвращающую таблицу, которая содержит атрибуты `a`, `b`, `c` и `sum`. `a`, `b` и `c` должны инициализироваться со значениями 1, 2 и 3, а `sum` должна быть функцией, складывающей `a`, `b` и `c`. Значение суммы должно храниться в атрибуте `c` таблицы (то есть после выполнения всех операций таблица должна иметь атрибут `c` со значением 6).

**11.** Если класс имеет метод с названием `someMethod`, может ли у него быть атрибут с тем же названием? Если нет, то почему?

**12.** Что такое «глобальная таблица» в Lua?

**13.** На основании того, как мы организовали автоматическую загрузку классов, если один класс наследует от другого, то код будет выглядеть следующим образом:

```lua
SomeClass = ParentClass:extend()
```

Существует ли гарантия того, что когда эта строка будет обрабатываться, переменная `ParentClass` уже будет определена? Или, иными словами, есть ли гарантия того, что required `ParentClass` будет раньше, чем `SomeClass`? Если да, то чем это гарантируется? Если нет, то как можно устранить эту проблему?

**14.** Предположим, что все файлы классов определяют класс не глобально, а локально, примерно так:

```lua
local ClassName = Object:extend()
...
return ClassName
```

Как нужно изменить функцию `requireFiles`, чтобы она всё равно могла автоматически загружать все классы?

<br>

## Ввод

Теперь перейдём к обработке ввода. По умолчанию в LÖVE для этого используется несколько обработчиков событий. Если эти функции обработки событий определены, то они могут вызываться при выполнении соответствующего события, после чего можно перехватить выполнение игры и совершить необходимые действия:

```lua
function love.load()

end

function love.update(dt)

end

function love.draw()

end

function love.keypressed(key)
    print(key)
end

function love.keyreleased(key)
    print(key)
end

function love.mousepressed(x, y, button)
    print(x, y, button)
end

function love.mousereleased(x, y, button)
    print(x, y, button)
end
```

В этом случае, когда вы нажимаете клавишу или щёлкаете мышью в любом месте экрана, в консоль будет выводиться информация. Одна из самых больших проблем с таким способом обработки в том, что она вынуждает структурировать всё необходимое вам для получения ввода в обход этих вызовов.

Допустим, у нас есть объект `game`, внутри которого есть объект `level`, внутри которого есть объект `player`. Для того, чтобы объект player получил клавиатурный ввод, у всех этих трёх объектов должно быть определено два обработчика вызова, связанных с клавиатурой, потому что на верхнем уровне мы хотим вызывать только `game:keypressed` внутри `love.keypressed`, поскольку мы не хотим, чтобы более низкие уровни знали об уровне или игроке. Поэтому я создал [библиотеку](https://github.com/adonaac/boipushy) для решения этой проблемы. Можете скачать и установить её как любую другую рассмотренную нами библиотеку. Вот несколько примеров того, как она работает:

```lua
function love.load()
    input = Input()
    input:bind('mouse1', 'test')
end

function love.update(dt)
    if input:pressed('test') then print('pressed') end
    if input:released('test') then print('released') end
    if input:down('test') then print('down') end
end
```

Вот, что делает библиотека: вместо того, чтобы полагаться на функции обработки событий ввода, она просто запрашивает, была ли в этом кадре нажата определённая клавиша и получает ответ в виде true или false. В приведённом выше примере в кадре, где нажали кнопку `mouse1`, на экране будет печататься `pressed`, а в кадре отпускания кнопки будет печататься `released`. Во всех других кадрах, когда нажатие не выполняется, вызовы `input:pressed` и `input:released` будут возвращать false и всё внутри условной конструкции выполняться не будет. То же самое относится и к функции `input:down`, только она возвращает true в каждом кадре, когда кнопка удерживается, и false в противном случае.

Часто нам требуется поведение, повторяющееся при удерживании клавиши с определённым интервалом, а не в каждом кадре. Для этой цели можно использовать функцию `down`:

```lua
function love.update(dt)
    if input:down('test', 0.5) then print('test event') end
end
```

В этом примере, если удерживается клавиша, привязанная к действию `test`, то каждые 0,5 секунд в консоли будет печататься `test event`.

<br>

### Упражнения по вводу

**15.** Допустим, у нас есть следующий код:

```lua
function love.load()
    input = Input()
    input:bind('mouse1', function() print(love.math.random()) end)
end
```

Will anything happen when `mouse1` is pressed? What about when it is released? And held down?

**16.** Привяжите клавишу алфавитно-цифрового блока `+` к действию `add`; затем при удерживании клавиши действия `add `увеличивайте значение переменной `sum` (изначально равной 0) на 1 через каждые `0,25` секунды. Выводите значение `sum` в консоль при каждом инкременте.

**17.** Можно ли к одному действию привязать несколько клавиш? Если нет, то почему? И можно ли привязать к одной клавише несколько действий? Если нет, то почему?

**18.** Если у вас есть контроллер, то привяжите его кнопки направлений DPAD (fup, fdown...) к действиям `up`, `left`, `right` и `down`, а затем выводите название действия в консоль при нажатии каждой из кнопок.

**19.** Если у вас есть контроллер, то привяжите одну из его кнопок-триггеров (l2, r2) к действию `trigger`. Кнопки-триггеры возвращают вместо булевого значение от 0 до 1, сообщающее о нажатии. Как вы будете получать это значение?

**20.** Повторите предыдущее упражнение, но для горизонтального и вертикального положения левого и правого стиков.

<br>

## Timer

Now another crucial piece of code to have are general timing functions. For this I'll use [hump](https://github.com/vrld/hump), more especifically [hump.timer](http://hump.readthedocs.io/en/latest/timer.html).

```lua
Timer = require 'libraries/hump/timer'

function love.load()
    timer = Timer()
end

function love.update(dt)
    timer:update(dt)
end
```

According to the documentation it can be used directly through the `Timer` variable or it can be instantiated to a new one instead. I decided to do the latter. I'll use this global `timer` variable for global timers and then whenever timers inside objects are needed, like inside the Player class, it will have its own timer instantiated locally.

The most important timing functions used throughout the entire game are [`after`](http://hump.readthedocs.io/en/latest/timer.html#Timer.after), [`every`](http://hump.readthedocs.io/en/latest/timer.html#Timer.every) and [`tween`](http://hump.readthedocs.io/en/latest/timer.html#Timer.tween). And while I personally don't use the [`script`](http://hump.readthedocs.io/en/latest/timer.html#Timer.script) function, some people might find it useful so it's worth a mention. So let's go through them:

```lua
function love.load()
    timer = Timer()
    timer:after(2, function() print(love.math.random()) end)
end
```

`after` is pretty straightfoward. It takes in a number and a function, and it executes the function after number seconds. In the example above, a random number would be printed to the console 2 seconds after the game is run. One of the cool things you can do with `after` is that you can chain multiple of those together, so for instance:

```lua
function love.load()
    timer = Timer()
    timer:after(2, function()
        print(love.math.random())
        timer:after(1, function()
            print(love.math.random())
            timer:after(1, function()
                print(love.math.random())
            end)
        end)
    end)
end
```

In this example, a random number would be printed 2 seconds after the start, then another one 1 second after that (3 seconds since the start), and finally another one another second after that (4 seconds since the start). This is somewhat similar to what the `script` function does, so you can choose which one you like best.

```lua
function love.load()
    timer = Timer()
    timer:every(1, function() print(love.math.random()) end)
end
```

In this example, a random number would be printed every 1 second. Like the `after` function it takes in a number and a function and executes the function after number seconds. Optionally it can also take a third argument which is the amount of times it should pulse for, so, for instance:

```lua
function love.load()
    timer = Timer()
    timer:every(1, function() print(love.math.random()) end, 5)
end
```

Would only print 5 numbers in the first 5 pulses. One way to get the `every` function to stop pulsing without specifying how many times it should be run for is by having it return false. This is useful for situations where the stop condition is not fixed or known at the time the `every` call was made.

Another way you can get the behavior of the `every` function is through the `after` function, like so:

```lua
function love.load()
    timer = Timer()
    timer:after(1, function(f)
        print(love.math.random())
        timer:after(1, f)
    end)
end
```

I never looked into how this works internally, but the creator of the library decided to do it this way and document it in the instructions so I'll just take it ^^. The usefulness of getting the funcionality of `every` in this way is that we can change the time taken between each pulse by changing the value of the second `after` call inside the first:

```lua
function love.load()
    timer = Timer()
    timer:after(1, function(f)
        print(love.math.random())
        timer:after(love.math.random(), f)
    end)
end
```

So in this example the time between each pulse is variable (between 0 and 1, since [love.math.random](https://love2d.org/wiki/love.math.random) returns values in that range by default), something that can't be achieved by default with the `every` function. Variable pulses are very useful in a number of situations so it's good to know how to do them. Now, on to the `tween` function:  

```lua
function love.load()
    timer = Timer()
    circle = {radius = 24}
    timer:tween(6, circle, {radius = 96}, 'in-out-cubic')
end

function love.update(dt)
    timer:update(dt)
end

function love.draw()
    love.graphics.circle('fill', 400, 300, circle.radius)
end
```

The `tween` function is the hardest one to get used to because there are so many arguments, but it takes in a number of seconds, the subject table, the target table and a tween mode. Then it performs the tween on the subject table towards the values in the target table. So in the example above, the table `circle` has a key `radius` in it with the initial value of 24. Over the span of 6 seconds this value will changed to 96 using the `in-out-cubic` tween mode. (here's a [useful list of all tweening modes](http://easings.net/)) It sounds complicated but it looks like this:

<p align="center">
  <img src="https://github.com/gsomgsom/lua_gamedev_blog/raw/master/images/bytepath-timer-1.gif"/>
</p>

The `tween` function can also take an additional argument after the tween mode which is a function to be called when the tween ends. This can be used for a number of purposes, but taking the previous example, we could use it to make the circle shrink back to normal after it finishes expanding:

```lua
function love.load()
    timer = Timer()
    circle = {radius = 24}
    timer:after(2, function()
        timer:tween(6, circle, {radius = 96}, 'in-out-cubic', function()
            timer:tween(6, circle, {radius = 24}, 'in-out-cubic')
        end)
    end)
end
```

And that looks like this:

<p align="center">
  <img src="https://github.com/gsomgsom/lua_gamedev_blog/raw/master/images/bytepath-timer-2.gif"/>
</p>

These 3 functions - `after`, `every` and `tween` - are by far in the group of most useful functions in my code base. They are very versatile and they can achieve a lot of stuff. So make you sure you have some intuitive understanding of what they're doing!

---

One important thing about the timer library is that each one of those calls returns a handle. This handle can be used in conjunction with the `cancel` call to abort a specific timer:

```lua
function love.load()
    timer = Timer()
    local handle_1 = timer:after(2, function() print(love.math.random()) end)
    timer:cancel(handle_1)
```

So in this example what's happening is that first we call `after` to print a random number to the console after 2 seconds, and we store the handle of this timer in the `handle_1` variable. Then we cancel that call by calling `cancel` with `handle_1` as an argument. This is an extremely important thing to be able to do because often times we will get into a situation where we'll create timed calls based on certain events. Say, when someone presses the key `r` we want to print a random number to the console after 2 seconds:

```lua
function love.keypressed(key)
    if key == 'r' then
        timer:after(2, function() print(love.math.random()) end)
    end
end
```

If you add the code above to the `main.lua` file and run the project, after you press `r` a random number should appear on the screen with a delay. If you press `r` multiple times repeatedly, multiple numbers will appear with a delay in quick succession. But sometimes we want the behavior that if the event happens repeated times it should reset the timer and start counting from 0 again. This means that whenever we press `r` we want to cancel all previous timers created from when this event happened in the past. One way of doing this is to somehow store all handles created somewhere, bind them to an event identifier of some sort, and then call some cancel function on the event identifier itself which will cancel all timer handles associated with that event. This is what that solution looks like:

```lua
function love.keypressed(key)
    if key == 'r' then
        timer:after('r_key_press', 2, function() print(love.math.random()) end)
    end
end
```

I created an enhancement of the current timer module that supports the addition of event tags. So in this case, the event `r_key_press` is attached to the timer that is created whenever the `r` key is pressed. If the key is pressed multiple times repeatedly, the module will automatically see that this event has other timers registered to it and cancel those previous timers as a default behavior, which is what we wanted. If the tag is not used then it defaults to the normal behavior of the module.

You can download this enhanced version [here](https://github.com/SSYGEN/EnhancedTimer) and swap the timer import in `main.lua` from `libraries/hump/timer` to wherever you end up placing the `EnhancedTimer.lua` file, I personally placed it in `libraries/enhanced_timer/EnhancedTimer`. This also assumes that the `hump` library was placed inside the `libraries` folder. If you named your folders something different you must change the path at the top of the `EnhancedTimer` file. Additionally, you can also use [this library](https://github.com/SSYGEN/chrono) I wrote which has the same functionality as hump.timer, but also handles event tags in the way I described.

<br>

### Timer Exercises

**21.** Using only a `for` loop and one declaration of the `after` function inside that loop, print 10 random numbers to the screen with an interval of 0.5 seconds between each print.

**22.** Suppose we have the following code:

```lua
function love.load()
    timer = Timer()
    rect_1 = {x = 400, y = 300, w = 50, h = 200}
    rect_2 = {x = 400, y = 300, w = 200, h = 50}
end

function love.update(dt)
    timer:update(dt)
end

function love.draw()
    love.graphics.rectangle('fill', rect_1.x - rect_1.w/2, rect_1.y - rect_1.h/2, rect_1.w, rect_1.h)
    love.graphics.rectangle('fill', rect_2.x - rect_2.w/2, rect_2.y - rect_2.h/2, rect_2.w, rect_2.h)
end
```

Using only the `tween` function, tween the `w` attribute of the first rectangle over 1 second using the `in-out-cubic` tween mode. After that is done, tween the `h` attribute of the second rectangle over 1 second using the `in-out-cubic` tween mode. After that is done, tween both rectangles back to their original attributes over 2 seconds using the `in-out-cubic` tween mode. It should look like this:

<p align="center">
<img src="https://github.com/gsomgsom/lua_gamedev_blog/raw/master/images/bytepath-timer-3.gif"/>
</p>

**23.** For this exercise you should create an HP bar. Whenever the user presses the `d` key the HP bar should simulate damage taken. It should look like this:

<p align="center">
<img src="https://github.com/gsomgsom/lua_gamedev_blog/raw/master/images/bytepath-timer-4.gif"/>
</p>

As you can see there are two layers to this HP bar, and whenever damage is taken the top layer moves faster while the background one lags behind for a while.

**24.** Taking the previous example of the expanding and shrinking circle, it expands once and then shrinks once. How would you change that code so that it expands and shrinks continually forever?

**25.** Accomplish the results of the previous exercise using only the `after` function.

**26.** Bind the `e` key to expand the circle when pressed and the `s` to shrink the circle when pressed. Each new key press should cancel any expansion/shrinking that is still happening.

**27.** Suppose we have the following code:

```lua
function love.load()
    timer = Timer()
    a = 10  
end

function love.update(dt)
    timer:update(dt)
end
```

Using only the `tween` function and without placing the `a` variable inside another table, how would you tween its value to 20 over 1 second using the `linear` tween mode?

<br>

## Table Functions

Now for the final library I'll go over [Yonaba/Moses](https://github.com/Yonaba/Moses/) which contains a bunch of functions to handle tables more easily in Lua. The documentation for it can be found [here](https://github.com/Yonaba/Moses/blob/master/doc/tutorial.md). By now you should be able to read through it and figure out how to install it and use it yourself.

But before going straight to exercises you should know how to print a table to the console and verify its values:

```lua
for k, v in pairs(some_table) do
    print(k, v)
end
```

<br>

### Table Exercises

For all exercises assume you have the following tables defined:

```lua
a = {1, 2, '3', 4, '5', 6, 7, true, 9, 10, 11, a = 1, b = 2, c = 3, {1, 2, 3}}
b = {1, 1, 3, 4, 5, 6, 7, false}
c = {'1', '2', '3', 4, 5, 6}
d = {1, 4, 3, 4, 5, 6}
```

You are also required to use only one function from the library per exercise unless explicitly told otherwise.

**28.** Print the contents of the `a` table to the console using the `each` function.

**29.** Count the number of 1 values inside the `b` table.

**30.** Add 1 to all the values of the `d` table using the `map` function.

**31.** Using the `map` function, apply the following transformations to the `a` table: if the value is a number, it should be doubled; if the value is a string, it should have `'xD'` concatenated to it; if the value is a boolean, it should have its value flipped; and finally, if the value is a table it should be omitted.

**32.** Sum all the values of the `d` list. The result should be 23.

**33.** Suppose you have the following code:

```lua
if _______ then
    print('table contains the value 9')
end
```

Which function from the library should be used in the underscored spot to verify if the `b` table contains or doesn't contain the value 9?

**34.** Find the first index in which the value 7 is found in the `c` table.

**35.** Filter the `d` table so that only numbers lower than 5 remain.

**36.** Filter the `c` table so that only strings remain.

**37.** Check if all values of the `c` and `d` tables are numbers or not. It should return false for the first and true for the second.

**38.** Shuffle the `d` table randomly.

**39.** Reverse the `d` table.

**40.** Remove all occurrences of the values 1 and 4 from the `d` table.

**41.** Create a combination of the `b`, `c` and `d` tables that doesn't have any duplicates.

**42.** Find the common values between `b` and `d` tables.

**43.** Append the `b` table to the `d` table.

<br>

---

Если вам понравится эта серия туториалов, то вы можете простимулировать меня к написанию чего-то подобного в будущем:

* ### [Игра BYTEPATH в Steam](http://store.steampowered.com/app/760330/BYTEPATH/)
* ### [Туториал по BYTEPATH на itch.io](https://ssygen.itch.io/bytepath-tutorial)

Купив туториал на itch.io, вы получите доступ к полному исходному коду игры, к ответам на упражения из частей 1-9, к коду, разбитому по частям туториала (код будет выглядеть так, как должен выглядеть в конце каждой части) и к ключу игры в Steam.
