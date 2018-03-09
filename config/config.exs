# (c) TenderPro inc., 2017
# http://tender.pro, cf@tender.pro, +7(495)215-14-38

use Mix.Config

# список ботов и их параметры
config :bots, :bots_list,
  # # описание бота
  testbot: %{
    # имя зарегистрированного Telegram бота
    bot_name: {:system, :string, "BOT_NAME", "@Opushkino1bot"},
    # токен бота
    token: {:system, :string, "BOT_TOKEN", "425450659:AAGclPta8A7_JU407SLhgYWO6olnPODCtwo"},
    # тип соединения с серверами Telegram - :longpolling or :webhook
    type: :longpolling,
    # командер для обработки сообщений
    commander: TSJBot.Commander,
    # атом алиас, для отправки сообщений в бот по алиасу, а не по токену
    bot_alias: :testbot
  }

# константы для ограничения скорости отправки в Telegram
config :bots, :telegram_constraint,
  max_total_count: 12,  # telegm 30
  max_chat_count: 4,   # telegm 20
  timeout_total: 500, # in miliseconds telegm 1_000
  timeout_chat: 15_000 # in miliseconds  telegm 60_000

# встроенный веб сервер, для проверки статуса работы host:port/bot/status
config :bots, :unsec_webserver,
  port: 8888

# Используется для тестов command_test.exs
config :bots, :telegram_account_for_test,
  user_id:      :YOUR_TELEGRAM_USER_ID, # должен быть integer
  first_name:   "YOUR_TELEGRAM_FIRST_NAME",
  last_name:    "YOUR_TELEGRAM_LAST_NAME",
  username:     "YOUR_TELEGRAM_USERNAME",
  phone_number: "YOUR_TELEGRAM_PHONE_NUMBER"
