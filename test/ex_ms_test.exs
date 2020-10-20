defmodule MillisecondTest do
  use ExUnit.Case
  use PropCheck
  doctest Millisecond, except: [ms: 1, ms!: 1]

  import Millisecond, only: [ms!: 1, ms: 1]

  @short_units [
    {"s", 1_000},
    {"m", 60_000},
    {"h", 3_600_000},
    {"d", 86_400_000},
    {"w", 604_800_000},
    {"mo", 2_592_000_000},
    {"y", 31_557_600_000}
  ]

  describe "Millisecond.ms!/1 short strings" do
    property "should preserve ms" do
      forall milliseconds <- pos_integer() do
        ms!("#{milliseconds}") == milliseconds
      end
    end

    property "should convert from ms to ms" do
      forall milliseconds <- pos_integer() do
        ms!("#{milliseconds}ms") == milliseconds
      end
    end

    property "should convert from m to ms" do
      forall minutes <- pos_integer() do
        ms!("#{minutes}m") == minutes * 60_000
      end
    end

    property "should convert from s to ms" do
      forall seconds <- pos_integer() do
        ms!("#{seconds}s") == seconds * 1000
      end
    end

    property "should convert from h to ms" do
      forall hours <- pos_integer() do
        ms!("#{hours}h") == hours * 3_600_000
      end
    end

    property "should convert from d to ms" do
      forall days <- pos_integer() do
        ms!("#{days}d") == days * 86_400_000
      end
    end

    property "should convert from w to ms" do
      forall weeks <- pos_integer() do
        ms!("#{weeks}w") == weeks * 604_800_000
      end
    end

    property "should convert from mo to ms" do
      forall months <- pos_integer() do
        ms!("#{months}mo") == months * 2_592_000_000
      end
    end

    property "should convert from y to ms" do
      forall years <- pos_integer() do
        ms!("#{years}y") == years * 31_557_600_000
      end
    end

    property "should work with decimals" do
      forall [quantity <- float(), {symbol, multiplier} <- elements(@short_units)] do
        ms!("#{quantity}#{symbol}") == quantity * multiplier
      end
    end

    property "should work with multiple spaces" do
      forall [
        quantity <- float(),
        space_count <- pos_integer(),
        {symbol, multiplier} <- elements(@short_units)
      ] do
        spaces = String.duplicate(" ", space_count)
        ms!("#{quantity}#{spaces}#{symbol}") == quantity * multiplier
      end
    end

    property "should be case-insensitive" do
      forall [quantity <- float(), {symbol, _multiplier} <- elements(@short_units)] do
        text = "#{quantity}#{symbol}"
        ms!(String.upcase(text)) == ms!(String.downcase(text))
      end
    end

    property "should not support numbers starting with ." do
      forall [quantity <- pos_integer(), {symbol, _multiplier} <- elements(@short_units)] do
        ms(".#{quantity}#{symbol}") == :error
      end
    end

    property "should work with negative numbers" do
      forall [quantity <- float(), {symbol, multiplier} <- elements(@short_units)] do
        ms!("#{-quantity}#{symbol}") == -quantity * multiplier
      end
    end

    property "should not support negative numbers starting with ." do
      forall [quantity <- pos_integer(), {symbol, _multiplier} <- elements(@short_units)] do
        ms("-.#{quantity}#{symbol}") == :error
      end
    end
  end

  describe "Millisecond.ms!/1 long strings" do
    property "should ms long forms work" do
      forall [
        quantity <- float(),
        long_symbol <- elements(["milliseconds", "millisecond", "msecs", "msec", "ms"])
      ] do
        ms!("#{quantity}ms") == ms!("#{quantity}#{long_symbol}")
      end
    end

    property "should s long forms work" do
      forall [
        quantity <- float(),
        long_symbol <- elements(["seconds", "second", "secs", "sec", "s"])
      ] do
        ms!("#{quantity}s") == ms!("#{quantity}#{long_symbol}")
      end
    end

    property "should m long forms work" do
      forall [
        quantity <- float(),
        long_symbol <- elements(["minutes", "minute", "mins", "min", "m"])
      ] do
        ms!("#{quantity}m") == ms!("#{quantity}#{long_symbol}")
      end
    end

    property "should h long forms work" do
      forall [
        quantity <- float(),
        long_symbol <- elements(["hours", "hour", "hrs", "hr", "h"])
      ] do
        ms!("#{quantity}h") == ms!("#{quantity}#{long_symbol}")
      end
    end

    property "should d long forms work" do
      forall [
        quantity <- float(),
        long_symbol <- elements(["days", "day", "d"])
      ] do
        ms!("#{quantity}d") == ms!("#{quantity}#{long_symbol}")
      end
    end

    property "should w long forms work" do
      forall [
        quantity <- float(),
        long_symbol <- elements(["weeks", "week", "w"])
      ] do
        ms!("#{quantity}w") == ms!("#{quantity}#{long_symbol}")
      end
    end

    property "should mo long forms work" do
      forall [
        quantity <- float(),
        long_symbol <- elements(["months", "month", "mo"])
      ] do
        ms!("#{quantity}mo") == ms!("#{quantity}#{long_symbol}")
      end
    end

    property "should y long forms work" do
      forall [
        quantity <- float(),
        long_symbol <- elements(["years", "year", "yrs", "yr", "y"])
      ] do
        ms!("#{quantity}y") == ms!("#{quantity}#{long_symbol}")
      end
    end
  end

  describe "Millisecond.ms!/1 multiple strings" do
    property "should work" do
      forall [
        hours <- pos_integer(),
        minutes <- float(),
        seconds <- pos_integer()
      ] do
        ms!("#{hours}h #{minutes} m #{-seconds}s") ==
          hours * 3_600_000 + minutes * 60_000 - seconds * 1_000
      end
    end

    test "should fail in the wrong order" do
      Enum.reduce(@short_units, [], fn {symbol, _}, acc ->
        Enum.each(acc, fn prev_symbol ->
          assert :error == ms("1#{prev_symbol} 1#{symbol}")
          assert {:ok, _} = ms("1#{symbol} 1#{prev_symbol}")
        end)

        [symbol | acc]
      end)
    end
  end
end
