## Приступаем к работе

Для начала нам нужно установить в системе LÖVE и научиться запускать проекты LÖVE. Мы будем использовать версию LÖVE 0.10.2, которую можно скачать [здесь](https://love2d.org/). Если вы читаете эту статью из будущего и уже вышла новая версия LÖVE, то 0.10.2 можно скачать [отсюда](https://bitbucket.org/rude/love/downloads/). Подробные инструкции описаны на [этой странице](https://love2d.org/wiki/Getting_Started_(%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)). Сделав всё необходимое, создайте в своём проекте файл `main.lua` со следующим содержимым:

```lua
function love.load()

end

function love.update(dt)

end

function love.draw()

end
```

Если вы запустите проект, то увидите всплывающее окно с чёрным экраном. В представленном выше коде проект LÖVE выполняет функцию `love.load` один раз при запуске программы, а `love.update` и `love.draw` выполняются в каждом кадре. То есть, например, если вы хотите загрузить изображение и отрисовывать его, то напишете что-то подобное:

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

[`love.graphics.newImage`](https://love2d.org/wiki/love.graphics.newImage) загружает текстуру-изображение в переменную `image` , а затем в каждом кадре она отрисовывается в позиции 0, 0. Чтобы увидеть, что `love.draw` на самом деле отрисовывает изображение в каждом кадре, попробуйте сделать так:

```lua
love.graphics.draw(image, love.math.random(0, 800), love.math.random(0, 600))
```

По умолчанию окно имеет размер `800x600`, то есть эта функция будет очень быстро случайным образом отрисовывать изображение на экране:

<p align="center">

<img src="https://github.com/gsomgsom/lua_gamedev_blog/raw/master/images/bytepath-image.gif">

</p>

Заметьте, что перед каждым кадром экран очищается, в противном случае отрисовываемое изображение постепенно заполнило бы весь экран, отрисовываясь в случайных позициях. Так происходит потому, что LÖVE предоставляет своим проектам стандартный игровой цикл, выполняющий после каждого кадра очистку экрана. Сейчас я расскажу об игровом цикле и о там, как его можно изменять.

<br>

## Игровой цикл

Стандартный игровой цикл, используемый LÖVE, находится на странице [`love.run`](https://love2d.org/wiki/love.run). Он выглядит следующим образом:

```lua
function love.run()
    if love.math then
	love.math.setRandomSeed(os.time())
    end

    if love.load then love.load(arg) end

    -- Мы не хотим, чтобы в dt первого кадра включалось время, потраченное на love.load.
    if love.timer then love.timer.step() end

    local dt = 0

    -- Время основного цикла.
    while true do
        -- Обработка событий.
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

	-- Обновление dt, потому что мы будем передавать его в update
	if love.timer then
	    love.timer.step()
	    dt = love.timer.getDelta()
	end

	-- Вызов update и draw
	if love.update then love.update(dt) end -- передаёт 0, если love.timer отключен

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

При запуске программы выполняется `love.run`, а затем отсюда начинает происходит всё остальное. Функция достаточно хорошо закомментирована, а назначение каждой функции можно узнать в LÖVE wiki. Но мы пройдёмся по основам:

```lua
if love.math then
    love.math.setRandomSeed(os.time())
end
```

В первой строке мы проверяем `love.math` на неравенство nil. Все значения в Lua являются true, за исключением false и nil, поэтому условие `if love.math` будет истинным, если `love.math` определёна. В случае LÖVE эти переменные задаются в файле [`conf.lua`](https://love2d.org/wiki/Config_Files). Вам пока не стоит беспокоиться об этом файле, но я упомянул его, потому что именно в нём можно включать и отключать отдельные системы, такие как `love.math`, поэтому прежде чем работать с её функциями, в этом файле нужно убедиться, что она включена.

В общем случае, если переменная не определена в Lua и вы каким-то образом ссылаетесь на неё, то она вернёт значение nil. То есть если вы создадите условие `if random_variable`, то оно будет ложным, если переменная не была определена ранее, например `random_variable = 1`.

Как бы то ни было, если модуль `love.math` включен (а по умолчанию это так), то его начальное число (seed) задаётся на основании текущего времени. См. [`love.math.setRandomSeed`](https://love2d.org/wiki/love.math.setRandomSeed) и [`os.time`](https://www.lua.org/pil/22.1.html). После этого вызывается функция `love.load`:

```lua
if love.load then love.load(arg) end
```

`arg` — это аргументы командной строки, передаваемые исполняемому файлу LÖVE, когда он выполняет проект. Как видите, [`love.load`](https://love2d.org/wiki/love.load) выполняется только один раз потому, что вызывается только один раз, а функции update и draw вызываются в цикле (и каждая итерация этого цикла соответствует кадру).

```lua
-- Мы не хотим, чтобы в dt первого кадра включалось время, потраченное на love.load.
if love.timer then love.timer.step() end

local dt = 0
```

После вызова `love.load` и выполнения функцией всей своей работы мы проверяем, что `love.timer` задан и вызываем [`love.timer.step`](https://love2d.org/wiki/love.timer.step), измеряющую время, потраченное между двумя последними кадрами. Как написано в комментарии, обработка `love.load` может занять длительное время (потому что в ней могут содержаться всевозможные вещи, например, изображения и звуки), а это время не должно быть первым значением, возвращаемым `love.timer.getDelta` в первом кадре игры.

Также здесь инициализируется `dt` , равное 0. Переменные в Lua по умолчанию являются глобальными, так что записью `local dt` мы назначаем текущему блоку только локальную область видимости, то есть ограничиваем его функцией `love.run`. Подробнее о блоках можно прочитать [здесь](https://www.lua.org/pil/4.2.html).

```lua
-- Время основного цикла.
while true do
    -- Обработка событий.
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

Здесь начинается основной цикл. Первое, что выполняется в каждом кадре — это обработка событий. [`love.event.pump`](https://love2d.org/wiki/love.event.pump) передаёт события в очередь событий и согласно его описанию, эти события каким-то образом генерируются пользователем. Это могут быть нажатия клавиш, щелчки мышью, изменение размеров окна, изменение фокуса окна и тому подобное. Цикл с помощью [`love.event.poll`](https://love2d.org/wiki/love.event.poll) проходит по очереди событий и обрабатывает каждое событие. `love.handlers` — это таблица функций, вызывающая соответствующие механизмы обработки событий. Например, `love.handlers.quit` будет вызывать функцию `love.quit`, если она существует.

Одна из особенностей LÖVE заключается в том, что можно определять механизмы обработки событий в файле `main.lua`, которые будут вызываться при выполнении события. Полный список обработчиков событий доступен [здесь](https://love2d.org/wiki/love). Больше я не буду подробно рассматривать обработчики событий, но вкратце объясню, как всё происходит. Аргументы `a, b, c, d, e, f` , передаваемые в `love.handlers[name]` являются всеми возможными аргументами, которые могут использовать соответствующие функции. Например, [`love.keypressed`](https://love2d.org/wiki/love.keypressed) получает в качестве аргумента нажатую клавишу, её сканкод и информацию о том, повторяется ли событие нажатия клавиши. То есть в случае `love.keypressed` значения `a, b, c` будут определены, а `d, e, f` будут иметь значения nil.

```lua
-- Обновление dt, потому что мы будем передавать его в update
if love.timer then
    love.timer.step()
    dt = love.timer.getDelta()
end

-- Вызов update и draw
if love.update then love.update(dt) end -- передаёт 0, если love.timer отключен
```

[`love.timer.step`](https://love2d.org/wiki/love.timer.step) измеряет время между двумя последними кадрами и изменяет значение, возвращаемое [`love.timer.getDelta`](https://love2d.org/wiki/love.timer.getDelta). То есть в этом случае `dt` будет содержать время, которое потребовалось на выполнение последнего кадра. Это полезно, потому что затем это значение передаётся в функцию `love.update`, и с этого момента оно может использоваться игрой для обеспечения постоянных скоростей вне зависимости от изменения частоты кадров.

```lua
if love.graphics and love.graphics.isActive() then
    love.graphics.clear(love.graphics.getBackgroundColor())
    love.graphics.origin()
    if love.draw then love.draw() end
    love.graphics.present()
end
```

После вызова `love.update` вызывается `love.draw`. Но прежде мы убеждаемся, что модуль `love.graphics` существует, и проверяем с помощью [`love.graphics.isActive`](https://love2d.org/wiki/love.graphics.isActive), что мы можем выполнять отрисовку на экране. Экран очищается, заливаясь заданным фоновым цветом (изначально чёрным) с помощью [`love.graphics.clear`](https://love2d.org/wiki/love.graphics.clear), с помощью [`love.graphics.origin`](https://love2d.org/wiki/love.graphics.origin) сбрасываются преобразования, вызывается `love.draw`, а затем используется [`love.graphics.present`](https://love2d.org/wiki/love.graphics.present) для передачи всего отрисованного в `love.draw` на экране. И наконец:

```lua
if love.timer then love.timer.sleep(0.001) end
```

Я никогда не понимал, почему [`love.timer.sleep`](https://love2d.org/wiki/love.timer.sleep) должен находиться здесь, в конце файла, но [объяснение разработчика LÖVE](https://love2d.org/forums/viewtopic.php?f=4&t=76998&p=198629&hilit=love.timer.sleep#p160881) кажется достаточно логичным.

И на этом функция `love.run` завершается. Всё, что происходит внутри цикла `while true` , относится к кадру, то есть `love.update` и `love.draw` вызываются один раз в кадр. Вся игра в сущности заключается в очень быстром повторении содержимого цикла (например, при 60 кадрах в секунду), так что привыкайте к этой мысли. Помню, что сначала мне потребовалось какое-то время для инстинктивного осознания того, почему всё так устроено.

Если вы хотите прочитать об этом подробнее, то на [форумах LÖVE](https://love2d.org/forums/viewtopic.php?t=83578) есть полезное обсуждение этой функции.

Если не хотите, то не обязательно разбираться в этом с самого начала, но это пригодится, чтобы правильным образом изменять работу игрового цикла. Есть отличная статья, в которой рассматриваются различные техники игровых циклов с качественным объяснением. Она находится [здесь](http://gafferongames.com/game-physics/fix-your-timestep/).

<br>

### Упражнения по игровому циклу

**1.** Какую роль играет Vsync в игровом цикле? По умолчанию она включена и вы можете отключить её, вызвав [`love.window.setMode`](https://love2d.org/wiki/love.window.setMode) с атрибутом `vsync`, имеющим значение false.

**2.** Реализуйте цикл `Fixed Delta Time` из статьи Fix Your Timestep, изменив `love.run`.

**3.** Реализуйте цикл `Variable Delta Time` из статьи Fix Your Timestep, изменив `love.run`.

**4.** Реализуйте цикл `Semi-Fixed Timestep` из статьи Fix Your Timestep, изменив `love.run`.

**5.** Реализуйте цикл `Free the Physics` из статьи Fix Your Timestep, изменив `love.run`.

<br>

---

Если вам понравится эта серия туториалов, то вы можете простимулировать меня к написанию чего-то подобного в будущем:

* ### [Игра BYTEPATH в Steam](http://store.steampowered.com/app/760330/BYTEPATH/)
* ### [Туториал по BYTEPATH на itch.io](https://ssygen.itch.io/bytepath-tutorial)

Купив туториал на itch.io, вы получите доступ к полному исходному коду игры, к ответам на упражения из частей 1-9, к коду, разбитому по частям туториала (код будет выглядеть так, как должен выглядеть в конце каждой части) и к ключу игры в Steam.
