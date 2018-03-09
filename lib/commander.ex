defmodule TSJBot.Commander do
  require Logger

  def available_method?(:message),        do: true
  def available_method?(:callback),       do: true
  def available_method?(:edited_message), do: false
  def available_method?(_),               do: false

  def get_response(msg, options) do
    type = msg["type"]
    data = case type do
      :message -> msg["message"]["text"]
      :callback -> msg["callback_query"]["data"]
    end

    message_id = msg["callback_query"]["message"]["message_id"]
    exp = TSJBot.Storage.is_in_expectation(msg["chat_id"])

    case exp do
      true ->
        case data do
          "Отправить" ->
            TSJBot.Storage.stop_expectation(msg["chat_id"])
            order = TSJBot.Storage.get_order(msg["chat_id"])
            TSJBot.Storage.delete_order(msg["chat_id"])
            {msg_type, view} = get_view(type, data, order)
            {msg_type, Map.merge(%{chat_id: msg["chat_id"], message_id: message_id}, view)}
          "Отмена" ->
            TSJBot.Storage.stop_expectation(msg["chat_id"])
            TSJBot.Storage.delete_order(msg["chat_id"])
            {msg_type, view} = get_view(:message, "/start")
            {msg_type, Map.merge(%{chat_id: msg["chat_id"], message_id: message_id}, view)}
          "/start" ->
            TSJBot.Storage.stop_expectation(msg["chat_id"])
            TSJBot.Storage.delete_order(msg["chat_id"])
            {msg_type, view} = get_view(:message, "/start")
            {msg_type, Map.merge(%{chat_id: msg["chat_id"], message_id: message_id}, view)}
          _else ->
            message = msg["message"]["text"]
            TSJBot.Storage.add_order(msg["chat_id"], message)
        end
      false ->
        if data=="Оставить заявку" do
          TSJBot.Storage.start_expectation(msg["chat_id"])
        end

        {msg_type, view} = get_view(type, data)

        {msg_type, Map.merge(%{chat_id: msg["chat_id"], message_id: message_id}, view)}
    end
  end

  defp main_menu do
    [[%{text: "Последние новости"}, %{text: "Контакты ТСЖ"}],
      [%{text: "Паспортист"}, %{text: "Оставить заявку"}]]
  end
  defp order_menu do
    [[%{text: "Отправить"}, %{text: "Отмена"}]]
  end
  defp error_msg, do: {:send_message, %{text: "Ошибка в системе"}}
  defp order_error_msg do
    text = "Ошибка при отправке"
    {:ok, buttons} = Poison.encode(%{keyboard: main_menu(), resize_keyboard: true})
    {:send_message, %{text: text, reply_markup: buttons}}
  end

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
        {:ok, buttons} = Poison.encode(%{keyboard: order_menu(), resize_keyboard: true})
        {:send_message, %{text: text, reply_markup: buttons}}
      _else ->
        error_msg()
    end
  end
  def get_view(:message, "Отмена") do
    # сбросить ожидание и накопление ввода
    get_view(:message, "/start")
  end
  def get_view(_, _) do
    {:send_message, %{text: "Сообщение не поддерживается"}}
  end

  def get_view(:message, "Отправить", text) do
    token = Bots.Config.bot_token(:testbot)

    url = HTTPotion.process_url("https://api.telegram.org/bot#{token}/sendMessage")

    body = %{
      text: text,
      chat_id: "-1001178161945"
    }
    encoded = URI.encode_query(body)
    headers = ['Content-Type': "application/x-www-form-urlencoded"]
    response = HTTPotion.post url, [body: encoded, headers: headers]

    # case HTTPoison.get("https://api.telegram.org/bot#{token}/sendMessage?chat_id=@Opushkino1Adm&text=" <> text) do
    case response do
      %{status_code: 200} ->
        text = "Ваша заявка принята: \n\n" <> text
        {:ok, buttons} = Poison.encode(%{keyboard: main_menu(), resize_keyboard: true})
        {:send_message, %{text: text, reply_markup: buttons}}
      _else ->
        order_error_msg()
    end
  end

end
