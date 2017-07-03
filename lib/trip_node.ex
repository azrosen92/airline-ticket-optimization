defmodule TripNode do
  defstruct city: "", airport_code: "", ticket_cost: 0, leaving_date: DateTime.utc_now, destinations: []

  # Given a TripNode t, returns the cheapest destination of t measured 
  # by the ticket_cost of t plus the cost of the destination. 
  def find_shortest_path(trip_node) do
    cheapest_node = case trip_node.destinations do
        [head | []] -> head
        destinations -> destinations 
          |> Enum.map(&(TripNode.find_shortest_path(&1)))
          |> Enum.min_by(&(&1.ticket_cost + trip_node.ticket_cost))
      end

    trip_node
    |> Map.put(:destinations, [cheapest_node])
  end

  def make_list(trip_node) do
    next_destinations = trip_node.destinations
    |> List.first
    |> case do
      nil -> nil
      destination -> make_list(destination)
    end

    [trip_node | next_destinations]
  end

  def add_destinations(trip_node, destinations) do
    %TripNode{
      airport_code: origin_airport,
      leaving_date: origin_leaving_date
    } = trip_node

    trip_destinations = destinations
    |> Enum.map(fn (destination) ->
      remaining_cities = MapSet.delete(destinations, destination)

      %City{
        airport_code: destination_airport,
        name: destination_city,
        days_spent: days_spent
      } = destination

      destination_cost = FlightCostFetcher.get_best_price(
        origin_airport, 
        destination_airport, 
        DateTime.from_unix(DateTime.to_unix(origin_leaving_date) + (days_spent*24*60*60))
      )

      %TripNode{
        city: destination_city,
        airport_code: destination_airport,
        ticket_cost: destination_cost,
        destinations: []
      }
      |> TripNode.add_destinations(remaining_cities)
    end)

    trip_node
    |> Map.put(:destinations, trip_destinations)
  end
end

defimpl String.Chars, for: TripNode do
  def to_string(term) do 
    to_string(term, "")
  end

  def to_string(term, tabs) do
    destinations = term.destinations |> Enum.map(&(to_string(&1, "#{tabs}\s"))) |> Enum.join(",")
    "#{term.airport_code} ($#{term.ticket_cost}) -> [#{destinations}]"
  end
end