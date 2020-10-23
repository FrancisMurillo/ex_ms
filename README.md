# ExMs

[![BuildStatus](https://github.com/FrancisMurillo/ex_ms/workflows/.github/workflows/elixir.yml/badge.svg)](https://github.com/FrancisMurillo/ex_ms/actions)
[![Coverage Status](https://coveralls.io/repos/github/FrancisMurillo/ex_ms/badge.svg?branch=main)](https://coveralls.io/github/FrancisMurillo/ex_ms?branch=main)
[![Hex.pm](http://img.shields.io/hexpm/v/ex_ms.svg?style=flat)](https://hex.pm/packages/ex_ms)
[![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_ms/)
[![Hex.pm](http://img.shields.io/hexpm/dt/ex_ms.svg?style=flat)](https://hex.pm/packages/ex_ms)
[![Hex.pm](http://img.shields.io/hexpm/l/ex_ms.svg?style=flat)](https://hex.pm/packages/ex_ms)
[![Github.com](https://img.shields.io/github/last-commit/FrancisMurillo/ex_ms.svg)](https://github.com/FrancisMurillo/ex_ms/commits/master)

**A tiny library to parse human readable formats into milliseconds.**

Inspired by [ms.js](https://github.com/vercel/ms) and meant for making
date/time duration configuration easier, this tiny library will parse
simple duration/time based

## Installation

Add `:ex_ms` to your project's `mix.exs`:

```elixir
def deps do
  [
    {:ex_ms, "~> 0.1.0"}
  ]
end
```

## Usage

Since this takes inspiration from [ms.js](https://github.com/vercel/ms),
the basic usage also applies:

```elixir
import Millisecond, only: [ms!: 1, ms: 1]

ms!("2 days")
172800000

ms!("1d")
86400000

ms!("10h")
36000000

ms!("2.5 hrs")
9.0e6

ms!("2h")
7200000

ms!("1m")
60000

ms!("5s")
5000

ms!("1y")
31557600000

ms!("100")
100

ms!("-3 days")
-259200000

ms!("-1h")
-3600000

ms!("-200")
-200
```

Unlike the inspiration, it does not support millisecond to string. It
does support multiple units delimited by spaces but must be ordered:

```elixir
ms!("1h 1m 1s")
86400000

ms!("1days 12 hours")
129600000

ms("12 hours 1days")
:error
```
