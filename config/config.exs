use Mix.Config

# список ботов и их параметры
config :bots, bots_list:
  [
    # описание бота
    %{
      # имя зарегистрированного Telegram бота
      bot_name: "@some_bot",
      # токен бота
      token: "3000XXXXXX:AAHxxxxxxxxxxxxxxxxxxxxxxxxx",
      # тип соединения с серверами Telegram - :longpolling or :webhook
      type: :longpolling,
      # командер для обработки сообщений
      commander: Bots.TestCommander,
      # атом алиас, для отправки сообщений в бот по алиасу, а не по токену
      bot_alias: :testbot
    },
    # и другие боты, если нужно
  ]

# константы для ограничения скорости отправки в Telegram
config :bots, telegram_constraint:
  %{
    max_total_count: 12,  # telegm 30
    max_chat_count: 4,   # telegm 20
    timeout_total: 500, # in miliseconds telegm 1_000
    timeout_chat: 15_000 # in miliseconds  telegm 60_000
  }

# встроенный веб сервер, для проверки статуса работы host:port/bot/status
config :bots, unsec_webserver:
  %{port: 8080}
  
