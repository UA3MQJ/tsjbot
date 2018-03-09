defmodule TSJBot.Storage do
  use GenServer
  require Logger

  def start_link() do
    Logger.debug "Storage start_link"
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def init(:ok) do
    state = %{
      orders: %{},
      expectations: %{}
    }
    {:ok, state}
  end

  def add_order(chat_id, text),
    do: GenServer.call(__MODULE__, {:add_order, chat_id, text})

  def get_order(chat_id),
    do: GenServer.call(__MODULE__, {:get_order, chat_id})

  def delete_order(chat_id),
    do: GenServer.call(__MODULE__, {:delete_order, chat_id})

  def start_expectation(chat_id),
    do: GenServer.call(__MODULE__, {:start_expectation, chat_id})

  def stop_expectation(chat_id),
    do: GenServer.call(__MODULE__, {:stop_expectation, chat_id})

  def is_in_expectation(chat_id),
    do: GenServer.call(__MODULE__, {:is_in_expectation, chat_id})

  def handle_call({:add_order, chat_id, text}, _from, state) do
    case state.orders[chat_id] do
      nil ->
        new_orders = Map.merge(state.orders, %{chat_id => (text <> "\n")})
        {:reply, :ok, %{state | orders: new_orders}}
      old_text ->
        new_orders = Map.merge(state.orders, %{chat_id => (old_text <> text <> "\n")})
        {:reply, :ok, %{state | orders: new_orders}}
    end
  end

  def handle_call({:get_order, chat_id}, _from, state) do
    {:reply, state.orders[chat_id], state}
  end

  def handle_call({:delete_order, chat_id}, _from, state) do
    new_orders = Map.drop(state.orders, [chat_id])
    {:reply, :ok, %{state | orders: new_orders}}
  end

  def handle_call({:start_expectation, chat_id}, _from, state) do
    new_expectations = Map.merge(state.expectations, %{chat_id => true})
    {:reply, :ok, %{state | expectations: new_expectations}}
  end

  def handle_call({:stop_expectation, chat_id}, _from, state) do
    new_expectations = Map.drop(state.expectations, [chat_id])
    {:reply, :ok, %{state | expectations: new_expectations}}
  end

  def handle_call({:is_in_expectation, chat_id}, _from, state) do
    case state.expectations[chat_id] do
      nil ->
        {:reply, false, state}
      _else ->
        {:reply, true, state}
    end
  end

end
