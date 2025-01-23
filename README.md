# AT-ZigZagColorBars
The bot for MetaTrader 5 using ZigZig, ColorBars and WPR indicators for trend trading

* Created by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me/personal/algo)
* Version: 1.00

## What's new?
```
1.00: First version
```

!!! warning Предупреждение
    1. Стратегию разрабатывал на фьюче CNY на Финаме - CRH5. 
    2. График торгов очень рваный даже на высоких ТФ. ==Сделки будут сильно скользить особенно на больших лотах из низкой ликвидности.==
    3. Расчет лота стратегии описан как простая формула Депозит/Цена*Сайз_%. По ней без плеч не хватит депозита для Сайза > 100%. ==Это очень странная формула.==

## Strategy


## Installation
1. Make sure that your MetaTrader 5 terminal is updated to the latest version. To test Expert Advisors, it is recommended to update the terminal to the latest beta version. To do this, run the update from the main menu `Help->Check For Updates->Latest Beta Version`. The Expert Advisor may not run on previous versions because it is compiled for the latest version of the terminal. In this case you will see messages on the `Journal` tab about it.
2. Copy the bot executable file `*.ex5` to the terminal data directory `MQL5\Experts`.
3. Open the pair chart.
4. Move the Expert Advisor from the Navigator window to the chart.
5. Check `Allow Auto Trading` in the bot settings.
6. Enable the auto trading mode in the terminal by clicking the `Algo Trading` button on the main toolbar.
7. Load the set of settings by clicking the `Load` button and selecting the set-file.

## Inputs

##### 1. ENTRY (ENT)
- [x] `ENT_LTP`: Lot Type
    -  Fixed Lot
    - % of Deposit
- [x] `ENT_LTV`: Lot Type Value
