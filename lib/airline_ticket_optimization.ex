defmodule AirlineTicketOptimization do
  @moduledoc """
  Documentation for AirlineTicketOptimization.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AirlineTicketOptimization.hello
      :world

  """
  def test do
    starting_city = %City{
      name: "New York City",
      airport_code: "JFK",
      days_spent: 0
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
    ]

    build_optimal_trip(starting_city, cities)
  end

  @doc """
    Given a list of Cities, returns the shortest path visiting all cities.
  """
  def build_optimal_trip(starting_city, cities) when is_list(cities) do
    %City{
      name: city_name, 
      airport_code: city_airport 
    } = starting_city

    set_of_cities = Enum.into(cities, MapSet.new)

    ordered_destinations = %TripNode{
      city: city_name, 
      airport_code: city_airport, 
      ticket_cost: 0,
      leaving_date: DateTime.utc_now(), 
      destinations: []
    }
    |> TripNode.add_destinations(set_of_cities)

    IO.puts ordered_destinations

    ordered_destinations
    |> TripNode.find_shortest_path
  end
end
