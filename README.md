# AT-ZigZagColorBars
Бот для MetaTrader 5 торгует по комбинации индикаторов ZigZig и WPR и свечным паттернам

* Created by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me/personal/algo)
* Version: 1.04

## Что нового?
```
1.04: [*] Изменены значения по-умолчанию
1.03: [*] Фильтр по направлению WPR теперь рассчитывается без учета текущей свечи
1.02: [+] Фильтр повторного входа на одном ребре ZigZag-a
      [+] Режимы выхода из позиции по развороту после: 'Новой вершины ZigZag-a' или 'Нового сигнала'
      [+] Отрисовка уровня TSL
1.01: [+] 'ENT_SL_SHF_PNT' вместо 'ENT_SL_SHF_PER'
      [+] Подключен индикатор ColorBars
1.00: Первая версия
```

!!! warning ПРЕДУПРЕЖДЕНИЕ
    1. Торговая стратегия определена клиентом. Автор не несет за нее ответственности.
    2. Бот не гарантирует прибыль.
    3. Бот не гарантирует 100% защиты депозита.
    4. Используйте бота на свой страх и риск.

## Стратегия

1. Бот ждет рождения новой свечи.
2. На каждой новой свече бот ищет самые свежие вершины ZigZag-а за `SIG_DPT` свечей назад.
3. Т.е. ZigZag может переносить последнюю вершину после образования нового экстремума, то бот может игнорировать последнюю вершину за `SIG_ZZ_STR` баров.
4. По направлению последнего сегмента ZigZag-а бот определяет ожидаемое направление входа: сверху вниз - BUY; снизу-вверх SELL.
5. Бот ждет появление одного из свечных паттернов. В настройках `SIG_MOD_*_ENB` доступны 3 варианта, которые можно включать независимо друг от друга.
6. При появлении паттерна бот выполняет вход в позицию.
7. SL за последней вершиной ZigZag-а с доп. отступом.
8. Фиксированный TP может быть установлен в пунктах. 
9. При образовании новой противоположенной вершины ZigZag-а бот выходит из открытой позиции.
10. Одновременно возможна только одна открытая позиция.
11. От одной вершины ZigZag-а возможен только один вход. Если на той же вершине после закрытия позиции появится еще один сигнал паттерн, то вход будет проигнорирован, т.к. от этой вершины уже была сделка.
12. В фиксированное время бот может закрывать позиции, чтобы избежать свопов. После этого времени входы также игнорируются.
13. В боте реализован трейлинг `EXT_TSL_ENB` при выходе позиции в прибыль. Бот переносит стоп за дальнюю вершину за `EXT_TSL_BAR` баров.

![Layout](img/UM001.%20Layout.png)

## Установка

1. **Обновите терминал MetaTrader 5 до последней версии:** `Help->Check For Updates->Latest Release Version`. 
    - Если советник или индикатор не запускается, то проверьте сообщения на вкладке `Journal`. Возможно вы не обновили терминал до нужной версии.
    - Иногда для тестирования советников рекомендуется обновить терминал до самой последней бета-версии: `Help->Check For Updates->Latest Beta Version`. На прошлых версиях советник может не запускаться, потому что скомпилирован на последней версии терминала. В этом случае вы увидите сообщения на вкладке `Journal` об этом.
2. **Скопируйте файл бота `*.ex5` в каталог данных** терминала `MQL5\Experts\`. Открыть каталог данных терминала `File->Open Data Folder`.
3. **Скопируйте файл индикаторов `*.ex5` в каталог данных** терминала `MQL5\Indicators\`. Открыть каталог данных терминала `File->Open Data Folder`.
4. **Откройте график нужной пары**.
5. **Переместите советника из окна `Навигатор` на график**.
6. **Установите в настройках бота галочку `Allow Auto Trading`**.
7. **Включите режим автоторговли** в терминале, нажав кнопку `Algo Trading` на главной панели инструментов.

## Inputs

##### 1. СИГНАЛ (SIG)
- [x] `SIG_DPT`: Глубина поиска сигнала, баров
- [x] `SIG_MOD_BAR_ENB`: Режим "Просто по свече" включен
- [x] `SIG_MOD_DUA_ENB`: Режим "Однонаправленная" включен
- [x] `SIG_MOD_REV_ENB`: Режим "Разворотная" включен
- [x] `SIG_ZZ_DPT`: ZigZag Depth
- [x] `SIG_ZZ_DPT`: ZigZag Deviation
- [x] `SIG_ZZ_DPT`: ZigZag Back Step
- [x] `SIG_ZZ_STR`: ZigZag Игнорировать вершины до бара
- [x] `SIG_WPR_PER`: WPR Period

##### 2. ФИЛЬТР (FIL)
- [x] `FIL_WPR_ENB`: Фильтр по направлению WPR включен

##### 3. ВХОД (ENT)
- [x] `ENT_LTP`: Тип лота
- [x] `ENT_LTV`: Значение для расчета лота
- [x] `ENT_SL_SHT_PER`: Сдвиг SL (0-откл), % от цены (DEPRECATED in 1.01)
- [x] `ENT_SL_SHT_PNT`: Сдвиг SL (0-откл), пункт
- [x] `ENT_TP_PNT`: Fixed TP, pnt (0-откл)

##### 4. ВЫХОД (EXT)
- [x] `EXT_REV_MOD`: ==Режим выхода по развороту:==
    - [x] `Отключен`: Выход из позиции при развороте не происходит, только по TP/SL или TSL
    - [x] `После новой вершины ZigZag-a`: Выход из позиции сразу после появления новой вершины ZigZag
    - [x] `После нового сигнала`: Выход из позиции сразу после нового сигнала

    !!! warning ВНИМАНИЕ
        Если выбран режим `После нового сигнала` и включен фильтр `FIL_WPR_ENB`, то позиции могут не закрываться до тех пор, пока WPR не подтвердит сигнал, хотя ZigZag уже давно ушел против позиции.
- [x] `EXT_TSL_ENB`: Trailing Stop включен
- [x] `EXT_TSL_BAR`: Trailing Stop на хай/лоу за N баров
- [x] `EXT_TIM`: Выход после наступления времени (""-откл)

##### 5. ГРАФИКА (GUI)
- [x] `GUI_ENB`: Графика сигналов и входов включена
- [x] `GUI_TSL_ENB`: ==Рисовать уровень TSL==
- [x] `GUI_TSL_CLR`: ==Цвет линии уровня TSL==
- [x] `GUI_TSL_WDT`: ==Толщина линии уровня TSL==

##### 6. РАЗНОЕ (MS)
- [x] `MS_MGC`: Expert Adviser ID - Magic
- [x] `MS_EGP`: Expert Adviser Global Prefix
- [x] `MS_LOG_LL`: Log Level
- [x] `MS_LOG_FI`: Log Filter IN String (use `;` as sep)
- [x] `MS_LOG_FO`: Log Filter OUT String (use `;` as sep)
- [x] `MS_COM_EN`: Comment Enable (turn off for fast testing)
- [x] `MS_COM_IS`: Comment Interval, Sec
- [x] `MS_COM_EW`: Comment Custom Win
