defmodule GetKey do
  def get_key(map, key) when is_map(map) do
    Enum.reduce_while(map, :not_found, fn {k, v}, _acc ->
      case k == key do
        true ->
          {:halt, v}

        false ->
          get_key(v, key)
          |> case do
            :not_found -> {:cont, :not_found}
            value -> {:halt, value}
          end
      end
    end)
  end

  def get_key(list, key) when is_list(list) do
    Enum.reduce_while(list, :not_found, fn item, _acc ->
      get_key(item, key)
      |> case do
        :not_found -> {:cont, :not_found}
        value -> {:halt, value}
      end
    end)
  end

  def get_key(_map, _key), do: :not_found

  def test_map() do
    %{
      "key10" => [
        %{
          "key10.1" => [
            123,
            nil,
            "key10.2",
            %{
              "keys" => %{
                "key1" => "value1",
                "key2" => %{"key3" => 2, "key4" => 4},
                "key5" => [
                  %{"key5.1" => "value2"},
                  %{"key5.2" => 123},
                  %{"key5.3" => :ok, "key5.4" => 1.7},
                  "key5.4"
                ],
                "key6" => [1, 2, 3, 4],
                "key7" => nil
              }
            }
          ]
        },
        %{"key11" => ""}
      ],
      "key12" => :not_found
    }
  end

  def ten_maps() do
    [
      test_map(),
      test_map(),
      test_map(),
      test_map(),
      test_map(),
      test_map(),
      test_map(),
      test_map(),
      test_map(),
      test_map()
    ]
  end

  def get_key_in_all(list_of_maps, key) do
    list_of_maps
    |> Task.async_stream(fn map -> get_key(map, key) end)
    |> Enum.map(fn {:ok, val} -> val end)
  end

  def answers() do
    %{
      "key1" => "value1",
      "key15" => :not_found,
      "key2" => %{"key3" => 2, "key4" => 4},
      "key4" => 4,
      "key5.3" => :ok,
      "key5.4" => 1.7,
      "key6" => "x",
      "key7" => nil,
      "key11" => "",
      "key12" => :not_found,
      "key5.1" => "value2"
    }
  end

  def do_test() do
    Enum.reduce(answers(), %{pass: 0, fail: []}, fn {k, v}, acc ->
      case get_key(test_map(), k) do
        ^v ->
          acc |> Map.put(:pass, acc.pass + 1)

        failure ->
          msg = "Expected #{v} for #{k}, got #{failure}"
          acc |> Map.put(:fail, [msg | acc.fail])
      end
    end)
    |> case do
      %{pass: pass, fail: []} -> "Passed all tests: #{pass}"
      %{pass: pass, fail: failures} -> "Passed #{pass} tests. \n
      #{Enum.join(failures, "\n")}"
    end
  end
end
