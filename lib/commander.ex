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

  def get_view(:message, "/start") do
    # text = "#{Localization.t("welcome_to_bot_short")} #{options[:company_name]}!\n" <>
    # Localization.t("admin_start") <> "\xE2\xAC\x87 \n"
    # {:ok, buttons} = Poison.encode(%{keyboard: main_menu(), resize_keyboard: true})
    # %{text: text, reply_markup: buttons}
    text = "ТСЖ О'Пушкино - 1"
    {:ok, buttons} = Poison.encode(%{keyboard: main_menu(), resize_keyboard: true})

    {:send_message, %{text: text, reply_markup: buttons}}
  end
  def get_view(:message, "show inline buttons") do
    controls = [
      [%{text: "Button1", callback_data: "/callback1"}],
      [%{text: "Test button 2", callback_data: "/callback2"}]
    ]

    {:ok, buttons} = Poison.encode(%{inline_keyboard: controls})

    {:send_message, %{text: "Inline buttons test", reply_markup: buttons}}
  end
  def get_view(:message, "show updatable form") do

    controls = [
      [%{text: "Update (1)", callback_data: "/update"}]
    ]

    {:ok, buttons} = Poison.encode(%{inline_keyboard: controls})

    {:send_message, %{text: "Inline buttons test", reply_markup: buttons}}
  end
  def get_view(:callback, "/callback1") do
    {:send_message, %{text: "callback1 clicked"}}
  end
  def get_view(:callback, "/callback2") do
    {:send_message, %{text: "callback2 clicked"}}
  end
  def get_view(:callback, "/update") do
    ref=make_ref()
    controls = [
      [%{text: "Update (#{inspect ref})", callback_data: "/update"}]
    ]

    {:ok, buttons} = Poison.encode(%{inline_keyboard: controls})

    {:edit_text, %{text: "updated", reply_markup: buttons}}
  end
  def get_view(_, _) do
    {:send_message, %{text: "unknown message"}}
  end
# {:edit_buttons, Map.merge(view, %{chat_id: chat_id, message_id: message_id})}


end
