## Введение

В этой серии туториалов мы рассмотрим создание завершённой игры с помощью [Lua](https://www.lua.org/) и [LÖVE](https://love2d.org/). Туториал предназначен для программистов, имеющих некоторый опыт, но только начинающих осваивать разработку игр, или для разработчиков игр, уже имевших опыт работы с другими языками или фреймворками, но желающими лучше узнать Lua или LÖVE.

Создаваемая нами игра будет сочетанием [Bit Blaster XL](http://store.steampowered.com/app/433950/) и [дерева пассивных навыков Path of Exile](https://www.pathofexile.com/passive-skill-tree). Она достаточно проста, чтобы можно было рассмотреть её в нескольких статьях, не очень больших по объёму, но содержащих слишком большой объём знаний для новичка.

<p align="center">

<img src="https://github.com/gsomgsom/lua_gamedev_blog/raw/master/images/bytepath-shielder.gif">

</p>

Кроме того, туториал имеет уровень сложности, не раскрываемый в большинстве туториалов по созданию игр. Большинство проблем, возникающих у новичков в разработке игр, связано с масштабом проекта. Обычно советуют начинать с малого и постепенно расширять объём. Хотя это и неплохая идея, но если вас интересуют такие проекты, которые никак нельзя сделать меньше, то в Интернете довольно мало ресурсов, способных вам помочь в решении встречаемых задач.

Что касается меня, то я всегда интересовался созданием игр со множеством предметов/пассивных возможностей/навыков, поэтому когда я приступал к работе, мне было сложно найти хороший способ структурирования кода, чтобы не запутаться в нём. Надеюсь, моя серия туториалов поможет кому-нибудь в этом.

<p align="center">

<img src="https://github.com/gsomgsom/lua_gamedev_blog/raw/master/images/bytepath-skill-tree.gif">

</p>

<br>

## Требования

Прежде чем приступить, я перечислю некоторые из знаний, необходимых для освоения этого туториала:

* Основы программирования: переменные, циклы, условные операторы, основные структуры данных и т.д.;

* Основы ООП, например, понимание классов, экземпляров, атрибутов и методов;

* И самые основы Lua; [этого краткого туториала](https://learnxinyminutes.com/docs/lua/) должно быть достаточно.

По сути, этот туториал не предназначен для людей, делающих первые шаги в программировании. Кроме того, здесь я буду давать упражнения. Если у вас когда-нибудь были ситуации, когда вы заканчивали туториал и не знали, куда двигаться дальше, то, возможно, так происходило потому, что у вас не было упражнений. Если вы не хотите, чтобы такое повторялось, то рекомендую хотя бы попробовать их сделать.

<p align="center">

<img src="https://github.com/gsomgsom/lua_gamedev_blog/raw/master/images/bytepath-lightning.gif">

</p>

<br>

## Оглавление

### [1. Игровой цикл](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-1-game-loop.md)

### [2. Библиотеки](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-2-libraries.md)

### [3. Комнаты и области](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-3-rooms-and-areas.md)

### [4. Упражнения](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-4-exercises.md)

### [5. Основы игры](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-5-game-basics.md)

### [6. Основы класса Player](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-6-player-basics.md)

### [7. Параметры и атаки игрока](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-7-player-stats-and-attacks.md)

### [8. Враги](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-8-enemies.md)

### [9. Режиссёр и игровой цикл](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-9-director-and-gameplay-loop.md)

### [10. Практики написания кода](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-10-coding-practices.md)

### [11. Пассивные навыки](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-11-passives.md)

### [12. Другие пассивные навыки](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-12-more-passives.md)

### [13. Skill Tree](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-13-skill-tree.md)

### [14. Console](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-14-console.md)

### [15. Final](https://github.com/gsomgsom/lua_gamedev_blog/blob/master/posts/bytepath-15-final.md)

<br>

---

Если вам понравится эта серия туториалов, то вы можете простимулировать меня к написанию чего-то подобного в будущем:

* ### [Игра BYTEPATH в Steam](http://store.steampowered.com/app/760330/BYTEPATH/)
* ### [Туториал по BYTEPATH на itch.io](https://ssygen.itch.io/bytepath-tutorial)

Купив туториал на itch.io, вы получите доступ к полному исходному коду игры, к ответам на упражения из частей 1-9, к коду, разбитому по частям туториала (код будет выглядеть так, как должен выглядеть в конце каждой части) и к ключу игры в Steam.
