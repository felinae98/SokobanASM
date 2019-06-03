<div align="center">
  
<img src="https://i.loli.net/2019/06/03/5cf518fcd23cb88530.png" alt="icon" width="60" />

<h1>Core Sokoban ASM</h1>

![](https://flat.badgen.net/badge/汇编语言/课程设计/yellow)
![](https://flat.badgen.net/badge/platform/Windows/blue?icon=windows)
![](https://flat.badgen.net/badge/license/MIT/red)

</div>

Core logics of Sokoban Game implemented by pure and neat x86 Assembly. Main project at repo: [spencerwooo/SokobanGame](https://github.com/spencerwooo/SokobanGame)

> 俗称，推箱子。

## Building

1. 下载并安装：[MASM32](http://www.masm32.com/)
2. 使用 Visual Studio 2019 打开项目，将 Build Dependencies → Build Customization 中加入 masm 的选项
3. 编译 `sokoban.asm` 时选择 `x86`

## Usage

### 地图

地图为 7 行 9 列，用长度为 63 的 bytes 数组表示，对于每个点：

- 'P' 代表人物位置
- 'Q' 代表人站在标记位置上
- 'B' 代表箱子位置
- 'T' 代表箱子目标
- 'F' 代表箱子处于完成位置
- 'W' 代表墙
- 'G' 代表地面
- 'E' 不渲染

### 外部使用：

#### API 设计

函数：`int result = control(char map[], int params)`

`map[]` 代表当前地图，`params` 代表操作：

- `0x00` - `0x0A` 载入1-11关
- `0x10` 往上、`0x11` 往下、`0x12` 往左、`0x13` 往右
- `0x20` 上一步

返回值：

- `status`: `result >> 24`
  - 0：完成
  - 1：未完成
  - 2：一步都没走呢就点上一步？
  - 3：health 用光了还想上一步？重来吧救不了
- `health`: `(result >> 16) & 0xff`
  - 初始 5
- `step`: `result & 0xffff`
    - 步数

注：步数和 health 每次 load 都会重置。

#### 样例使用方法

> 以 C# 为例子

```C#
// Game core logics, in Assembly
[DllImport("SokobanASM.dll")]
public static extern int control(StringBuilder a, int b);

...

// Map string
StringBuilder mapString = new StringBuilder(70);

// Render map at level 1
control(mapString, 0x00);

...

// Go up
int gameResult = control(mapString, 0x10);

// Render statistics
// emmmm... See documentation for more
currentSteps = gameResult & 0xffff;
currentHealth = (gameResult & 0xff0000) >> 16;
currentStatus = gameResult >> 24;
```

---

🎮 **Sokoban Game** ©2019 Team Offline Flower. Released under the MIT License.

Authored and maintained by [@Felinae Tang](https://github.com/felinae98) with help from [@Spencer Woo](https://github.com/spencerwooo), [@Garvey Lau](https://github.com/garvey98) and [@Liz Li](https://github.com/LiZ-Samsara). Team Offline Flower, all rights reserved.

[@Blog](https://code.felinae98.cn/) · [@GitHub](https://github.com/felinae98)
