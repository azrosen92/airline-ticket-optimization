defmodule TripNodeTest do
  use ExUnit.Case

  import Mock

  test "add destinations" do
    original_node = %TripNode{
      city: "New York City", 
      airport_code: "JFK", 
      ticket_cost: 0,
      leaving_date: DateTime.utc_now(), 
      destinations: []
    }

    new_nodes = [
      %City{
        name: "London",
        airport_code: "LHR",
        days_spent: 5
      }, %City{
          name: "Paris",
          airport_code: "CDG",
          days_spent: 3
      }
    ] |> Enum.into(MapSet.new)

    updated_node = create_tree(original_node, new_nodes)

    assert updated_node.destinations 
      |> Enum.map(&(&1.airport_code)) 
      |> Enum.sort == ["CDG", "LHR"]

    assert updated_node.destinations 
      |> Enum.flat_map(&(&1.destinations)) 
      |> Enum.map(&(&1.airport_code)) 
      |> Enum.sort == ["CDG", "LHR"]
  end

  test "find shortest path" do
    original_node = %TripNode{
      city: "New York City", 
      airport_code: "JFK", 
      ticket_cost: 0,
      leaving_date: DateTime.utc_now(), 
      destinations: []
    }

    cities = [
      %City{
        name: "London",
        airport_code: "LHR",
        days_spent: 5
      }, %City{
        name: "Paris",
        airport_code: "CDG",
        days_spent: 3
      }, 
      %City{
        name: "Madrid",
        airport_code: "MAD",
        days_spent: 4
      }, 
      %City{
        name: "Berlin",
        airport_code: "BER",
        days_spent: 4
      }, %City{
        name: "Budapest",
        airport_code: "BUD",
        days_spent: 4
      }
    ] |> Enum.into(MapSet.new)

    updated_node = create_tree(original_node, cities)

    optimal_path = TripNode.find_shortest_path(updated_node) |> TripNode.make_list

    # assert optimal_path |> Enum.map(&(&1.airport_code)) == ["JFK", "LHR", "CDG", "MAD", "BER", "BUD"]
    # assert optimal_path |> Enum.map(&(&1.ticket_cost)) |> Enum.sum == 0
  end

  defp create_tree(original_node, cities) do
    with_mock(
      FlightCostFetcher,
      [get_best_price: fn(origin, destination, _) ->
        case {origin, destination} do
          {"JFK", "LHR"} -> 0
          {"JFK", "CDG"} -> 10
          {"JFK", "MAD"} -> 10
          {"JFK", "BER"} -> 10
          {"JFK", "BUD"} -> 10
          {"LHR", "JFK"} -> 10
          {"LHR", "CDG"} -> 0
          {"LHR", "MAD"} -> 10
          {"LHR", "BER"} -> 10
          {"LHR", "BUD"} -> 10
          {"CDG", "LHR"} -> 10
          {"CDG", "JFK"} -> 10
          {"CDG", "MAD"} -> 0
          {"CDG", "BER"} -> 10
          {"CDG", "BUD"} -> 10
          {"MAD", "LHR"} -> 10
          {"MAD", "CDG"} -> 10
          {"MAD", "JFK"} -> 10
          {"MAD", "BER"} -> 0
          {"MAD", "BUD"} -> 10
          {"BER", "LHR"} -> 10
          {"BER", "CDG"} -> 10
          {"BER", "MAD"} -> 10
          {"BER", "JFK"} -> 10
          {"BER", "BUD"} -> 0
          {"BUD", "LHR"} -> 10
          {"BUD", "CDG"} -> 10
          {"BUD", "MAD"} -> 10
          {"BUD", "BER"} -> 10
          {"BUD", "JFK"} -> 10
        end
      end]) do
        TripNode.add_destinations(original_node, cities)
    end
  end
end