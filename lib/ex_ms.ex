defmodule Millisecond do
  @moduledoc """
  A tiny library to parse human readable formats into milliseconds.
  """

  @doc """
  A tiny library to parse human readable formats into milliseconds to
  make configurations easier.

  ## Examples

      iex> Millisecond.ms("100")
      {:ok, 100}

      iex> Millisecond.ms("1s")
      {:ok, 1_000}

      iex> Millisecond.ms!("1s")
      1_000

      iex> Millisecond.ms("1m")
      {:ok, 60_000}

      iex> Millisecond.ms("1.5m")
      {:ok, 9.0e4}

      iex> Millisecond.ms("-0.5m")
      {:ok, -3.0e4}

      iex> Millisecond.ms("1h")
      {:ok, 3_600_000}

      iex> Millisecond.ms("1h 1m 1s")
      {:ok, 3_661_000}

      iex> Millisecond.ms("1y 1mo 1d")
      {:ok, 34_236_000_000}

      iex> Millisecond.ms("RANDOM STRING")
      :error

      iex> Millisecond.ms!("1nvalid")
      ** (ArgumentError) Format is invalid: \"1nvalid\"

      iex> Millisecond.ms("1d 1mo 1y")
      :error

      iex> Millisecond.ms("1hour 1minute 1second")
      {:ok, 3_661_000}

      iex> Millisecond.ms("1   minutes     1 milliseconds")
      {:ok, 60001}

      iex> Millisecond.ms("1year 1month 1day")
      {:ok, 34_236_000_000}
  """

  @second_ms 1000
  @minute_ms 60 * @second_ms
  @hour_ms 60 * @minute_ms
  @day_ms 24 * @hour_ms
  @week_ms 7 * @day_ms
  @month_ms 30 * @day_ms
  @year_ms round(365.25 * @day_ms)

  @steps [
    :year,
    :month,
    :week,
    :day,
    :hour,
    :minute,
    :second,
    :millisecond
  ]

  @type t :: %__MODULE__{
          year: number(),
          month: number(),
          week: number(),
          day: number(),
          hour: number(),
          minute: number(),
          second: number(),
          millisecond: number()
        }
  @type millisecond :: pos_integer()

  defstruct @steps

  @doc """
  Converts a string format into milliseconds.

  The main function of this library.

  ## Example

      iex> import Millisecond, only: [ms: 1, ms!: 1]
      iex> ms!('2 days')
      172800000
      iex> ms!('1d')
      86400000
      iex> ms!('10h')
      36000000
      iex> ms!('2.5 hrs')
      9000000
      iex> ms!('2h')
      7200000
      iex> ms!('1m')
      60000
      iex> ms!('5s')
      5000
      iex> ms!('1y')
      31557600000
      iex> ms!('100')
      100
      iex> ms!('-3 days')
      -259200000
      iex> ms!('-1h')
      -3600000
      iex> ms!('-200')
      -200

  """
  @spec ms(charlist) :: {:ok, millisecond} | :error
  def ms(text) do
    case parse(text) do
      {:ok, data} ->
        {:ok, to_milliseconds(data)}

      :error ->
        :error
    end
  end

  @doc """
  This is `ms/1` but returns milliseconds directly on success and raises
  an error otherwise.
  """
  @spec ms!(charlist) :: millisecond
  def ms!(text) do
    text
    |> parse!()
    |> to_milliseconds()
  end

  @doc """
  Converts a string to a `Millisecond` struct.

  This is intended to be an low-level function to mainly separate
  parsing and conversion.

  ## Examples

      iex> Millisecond.parse("1h 1m 1s")
      {:ok, %Millisecond{hour: 1, minute: 1, second: 1}}
      iex> Millisecond.parse("invalid format")
      :error

  """
  @spec parse(charlist()) :: {:ok, t()} | :error
  def parse(text) when is_binary(text) do
    text
    |> String.trim()
    |> String.downcase()
    |> String.split(" ", trim: true, parts: 3 * length(@steps))
    |> Enum.map(&parse_number/1)
    |> (fn units ->
          case units do
            [{:error, _}] ->
              :error

            [{_, _}] ->
              do_process(units)

            units ->
              units
              |> Enum.reduce_while({nil, []}, fn res, {quantity, grouped_units} ->
                case res do
                  {:error, _} when is_nil(quantity) ->
                    {:halt, :error}

                  {:error, unit} ->
                    {:cont, {nil, [{quantity, unit} | grouped_units]}}

                  {new_quantity, ""} when is_nil(quantity) ->
                    {:cont, {new_quantity, grouped_units}}

                  {_, ""} ->
                    {:halt, :error}

                  unit ->
                    {:cont, {nil, [unit | grouped_units]}}
                end
              end)
              |> case do
                :error ->
                  :error

                {nil, grouped_units} ->
                  grouped_units
                  |> Enum.reverse()
                  |> do_process()

                {_, _} ->
                  :error
              end
          end
        end).()
  end

  def parse(_), do: :error

  @doc """
  This is `parse/1` but returns the data directly on success and raises
  an error otherwise.
  """
  @spec parse!(charlist) :: t()
  def parse!(text) do
    case parse(text) do
      {:ok, mil1iseconds} -> mil1iseconds
      :error -> raise ArgumentError, "Format is invalid: #{inspect(text)}"
    end
  end

  defp parse_number(text) do
    if String.contains?(text, ".") do
      Float.parse(text)
    else
      Integer.parse(text)
    end
    |> case do
      :error -> {:error, text}
      res -> res
    end
  end

  defp do_process([]), do: :error

  defp do_process(values) do
    @steps
    |> Enum.reduce_while({%Millisecond{}, values}, fn step, acc ->
      with {state, [value | remaining_values]} <- acc,
           {quantity, unit} <- value,
           true <- do_parse_unit(step, unit) do
        {:cont, {Map.put(state, step, quantity), remaining_values}}
      else
        false -> {:cont, acc}
        _ -> {:halt, acc}
      end
    end)
    |> case do
      {state, []} ->
        {:ok, state}

      _ ->
        :error
    end
  end

  @year_units ["years", "year", "yrs", "yr", "y"]
  defp do_parse_unit(:year, unit) when unit in @year_units, do: true

  @month_units ["months", "month", "mo"]
  defp do_parse_unit(:month, unit) when unit in @month_units, do: true

  @week_units ["weeks", "week", "w"]
  defp do_parse_unit(:week, unit) when unit in @week_units, do: true

  @day_units ["days", "day", "d"]
  defp do_parse_unit(:day, unit) when unit in @day_units, do: true

  @hour_units ["hours", "hour", "hrs", "hr", "h"]
  defp do_parse_unit(:hour, unit) when unit in @hour_units, do: true

  @minute_units ["minutes", "minute", "mins", "min", "m"]
  defp do_parse_unit(:minute, unit) when unit in @minute_units,
    do: true

  @second_units ["seconds", "second", "secs", "sec", "s"]
  defp do_parse_unit(:second, unit) when unit in @second_units, do: true

  @millisecond_units ["milliseconds", "millisecond", "msecs", "msec", "ms"]
  defp do_parse_unit(:millisecond, unit) when unit in @millisecond_units, do: true
  defp do_parse_unit(:millisecond, ""), do: true

  defp do_parse_unit(_, _), do: false

  @doc """
  Converts a `Millisecond` struct to the intended milliseconds format.

  This is intended to be an low-level function to mainly separate
  parsing and conversion.

  ## Examples

      iex> data = Millisecond.parse!("1h 1m 1s")
      iex> Millisecond.to_milliseconds(data)
      3_661_000

      iex> data = Millisecond.parse!("1y 1mo 1d")
      iex> Millisecond.to_milliseconds(data)
      34_236_000_000

  """
  @spec to_milliseconds(t()) :: millisecond()
  def to_milliseconds(%Millisecond{} = data) do
    @steps
    |> Enum.reduce(0, fn step, acc ->
      if multiplier = Map.get(data, step, nil) do
        value =
          case step do
            :year -> @year_ms
            :month -> @month_ms
            :week -> @week_ms
            :day -> @day_ms
            :hour -> @hour_ms
            :minute -> @minute_ms
            :second -> @second_ms
            :millisecond -> 1
          end

        acc + multiplier * value
      else
        acc
      end
    end)
  end

  @doc """
  Adds the `Millisecond` to a `DateTime` to produce a future datetime.

  THis is an example of its intended use for configuration.

  ## Examples

      iex> ms = Millisecond.parse!("100ms")
      iex> now = DateTime.utc_now()
      iex> now |> Millisecond.add(ms) |> DateTime.diff(now, :millisecond)
      100

  """
  @spec add(DateTime.t(), t()) :: DateTime.t()
  def add(%DateTime{} = datetime, %Millisecond{} = data) do
    data
    |> to_milliseconds()
    |> (&DateTime.add(datetime, &1, :millisecond)).()
  end

  @doc """
  Subtracts the `Millisecond` from a `DateTime` to produce a past datetime.

  THis is an example of its intended use for configuration.

  ## Examples

      iex> ms = Millisecond.parse!("100ms")
      iex> now = DateTime.utc_now()
      iex> now |> Millisecond.subtract(ms) |> DateTime.diff(now, :millisecond)
      -100

  """
  @spec subtract(DateTime.t(), t()) :: DateTime.t()
  def subtract(%DateTime{} = datetime, %Millisecond{} = data) do
    data
    |> to_milliseconds()
    |> (&DateTime.add(datetime, -&1, :millisecond)).()
  end

  if Code.ensure_compiled(Timex) == {:module, Timex} do
    @doc """
    Converts an `Millisecond` struct into a `Timex.Duration` struct.

    This is inteded to show that `Millisecond` can be converted into a
    more appropriate date/time struct such `Timex.Duration`. If you have
    `Timex` already, perhaps use `Timex.Duration.parse/1` as it uses the
    ISO 8601 Duration format.

    ## Examples

        iex> {:ok, data} = Millisecond.parse("1h 1s")
        iex> duration = Millisecond.to_duration(data)
        iex> Timex.Duration.to_string(duration)
        "PT1H1S"

        iex> {:ok, data} = Millisecond.parse("1d 1h")
        iex> {:ok, duration} = Timex.Duration.parse("P1DT1H")
        iex> Millisecond.to_duration(data) == duration
        true

    """
    @spec to_duration(t()) :: Timex.Duration.t()
    def to_duration(data) do
      alias Timex.Duration

      Enum.reduce(@steps, Duration.zero(), fn step, acc ->
        if multiplier = Map.get(data, step, nil) do
          duration =
            case step do
              :year -> Duration.from_days(365 * multiplier)
              :month -> Duration.from_days(30 * multiplier)
              :week -> Duration.from_days(7 * multiplier)
              :day -> Duration.from_days(multiplier)
              :hour -> Duration.from_hours(multiplier)
              :minute -> Duration.from_minutes(multiplier)
              :second -> Duration.from_seconds(multiplier)
              :millisecond -> Duration.from_milliseconds(multiplier)
            end

          Duration.add(acc, duration)
        else
          acc
        end
      end)
    end
  end
end
