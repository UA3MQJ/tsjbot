defmodule TSJBot.Commander do
  require Logger

  def available_method?(:message),        do: true
  def available_method?(:callback),       do: true
  def available_method?(:edited_message), do: false
  def available_method?(_),               do: false

  def get_response(msg, _options) do
    type = msg["type"]
    data = case type do
      :message -> msg["message"]["text"]
      :callback -> msg["callback_query"]["data"]
    end

    message_id = msg["callback_query"]["message"]["message_id"]

    {msg_type, view} = get_view(type, data)

    {msg_type, Map.merge(%{chat_id: msg["chat_id"], message_id: message_id}, view)}
  end

  defp main_menu do
    [[%{text: "Последние новости"}, %{text: "Контакты ТСЖ"}],
      [%{text: "Паспортист"}, %{text: "Оставить заявку"}]]
  end
  defp error_msg, do: {:send_message, %{text: "Ошибка в системе"}}

  def get_view(:message, "/start") do
    text = "ТСЖ О'Пушкино - 1"
    {:ok, buttons} = Poison.encode(%{keyboard: main_menu(), resize_keyboard: true})

    {:send_message, %{text: text, reply_markup: buttons}}
  end
  def get_view(:message, "Контакты ТСЖ") do
    case HTTPoison.get("https://raw.githubusercontent.com/UA3MQJ/tsjbot/master/priv/contact.txt") do
      {:ok, result}->
        text = result.body
        {:ok, buttons} = Poison.encode(%{keyboard: main_menu(), resize_keyboard: true})
        {:send_message, %{text: text, reply_markup: buttons}}
      _else ->
        error_msg()
    end
  end
  def get_view(:message, "Последние новости") do
    case HTTPoison.get("https://raw.githubusercontent.com/UA3MQJ/tsjbot/master/priv/news.txt") do
      {:ok, result}->
        text = result.body
        {:ok, buttons} = Poison.encode(%{keyboard: main_menu(), resize_keyboard: true})
        {:send_message, %{text: text, reply_markup: buttons}}
      _else ->
        error_msg()
    end
  end
  def get_view(:message, "Паспортист") do
    case HTTPoison.get("https://raw.githubusercontent.com/UA3MQJ/tsjbot/master/priv/pass_contact.txt") do
      {:ok, result}->
        text = result.body
        {:ok, buttons} = Poison.encode(%{keyboard: main_menu(), resize_keyboard: true})
        {:send_message, %{text: text, reply_markup: buttons}}
      _else ->
        error_msg()
    end
  end
  def get_view(:message, "Оставить заявку") do
    case HTTPoison.get("https://raw.githubusercontent.com/UA3MQJ/tsjbot/master/priv/order.txt") do
      {:ok, result}->
        text = result.body
        {:ok, buttons} = Poison.encode(%{keyboard: main_menu(), resize_keyboard: true})
        {:send_message, %{text: text, reply_markup: buttons}}
      _else ->
        error_msg()
    end
  end

  def get_view(_, _) do
    {:send_message, %{text: "Сообщение не поддерживается"}}
  end

end
