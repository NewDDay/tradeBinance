# Данная программа обновляет цены в БД для арбитражной торговли

using LibPQ, DataFrames, HTTP, Dates, JSON
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

src.logging("common.log", 0, "Старт арбитражного вебсокета")
sym = src.symbols() # Запросили валюты к каждому символу. Например для BTCUSDT это будет BTC и USDT

global symbols = ["ETHBTC", "BNBBTC", "TRXBNB", "LTCBTC", "SOLBTC", "YFIBTC", "TRXBTC", "LTCETH",
    "TRXETH", "BNBETH", "SOLBNB", "YFIBNB", "AAVEBNB", "CAKEBNB", "CTKBNB", "AAVEETH",
         "AAVEBTC", "CTKBTC", "BURGERBNB", "LTCBNB"] # 20 символов, котировки которых должны быть занесены в БД
global ids = [2108175166, 1171342242, 143895937, 937139506, 177158433, 461223069, 518604519, 328258901,
    377247841, 439691041, 113240496, 133437993, 27706687, 15259191, 26223294, 33519857,
        71940038, 51455887, 2399561, 171871707] # По этим id будут опознаваться валютные пары. id соответсвенны sym

function whois(id) # Узнаём валютную пару по id
    try
        for i in 1:20
            if (id > ids[i]) && (id < ids[i]*1.05)
                return symbols[i]
            end
        end
    catch err
        src.logging("common.log", 9, "Опознаватель: $err\n\t\t\t\t$id\n")
        @error("Опознаватель сломался!!")
    end
end

function wsparse(json::Vector{UInt8}) # Вебсокет выдаёт информацию в JSON. Но парсить регулярными выражениями быстрее.
    try
        txt = String(json)
        rx = r"\d*\.\d*|\d+"
        m = eachmatch(rx, txt)
        collect(m)
    catch err
        src.logging("common.log", 8, "Парсер: $err\n\t\t\t\t$json\n")
    end
end

while true
    try
        LibPQ.Connection(src.data()["connPG"]) do conn
            function infile(book::Vector{RegexMatch}, symbol::String) # Запись в БД
                try
                    execute(conn, """update prices set
                                    "$(sym[symbol]["base"])" = $(1/parse(Float64, book[12].match))
                                    where name = '$(sym[symbol]["quote"])';""")
                    execute(conn, """update prices set
                                    "$(sym[symbol]["quote"])" = $(book[2].match)
                                    where name = '$(sym[symbol]["base"])';""")
                catch err
                    src.logging("common.log", 7, "Запись в БД: $err\n\t\t\t\t$book\n\t\t\t\t$symbol\n")
                end
            end

            function websocket(raw::String) # Вебсокет
                try
                    HTTP.WebSockets.open(raw; verbose=false) do io
                        while !eof(io)
                            book = wsparse(readavailable(io))
                            infile(book, whois(parse(Int, book[1].match)))
                        end
                    end
                catch err
                    src.logging("common.log", 6, "Арбитражный вебсокет: $err\n\t\t\t\t$raw\n")
                    websocket(raw)
                end
            end



            for x in 0:3 # Из списка инструментов готовим 4 строки по 5 символов. Из-за того что по каждому вебсокету приходит по 5 символов и символы не подписаны, нам и нужно опознавание по id
                raw = BN.BINANCE_API_WS[1:end-1]
                for i in 1:5
                    raw *= string("/", lowercase(symbols[x*5+i]), string("@depth", 5, "@100ms"))
                end
                @async websocket(raw)
            end

            while true
                sleep(1)
            end
        end
    catch err
        src.logging("common.log", 5, "Вся программа: $err\n")
    end
end

src.logging("common.log", 0, "Стоп арбитражного вебсокета")
