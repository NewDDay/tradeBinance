using LibPQ, DataFrames, HTTP, Dates, JSON
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

sym = src.symbols()

global symbols = ["ETHBTC", "BNBBTC", "TRXBNB", "LTCBTC", "SOLBTC", "YFIBTC", "TRXBTC", "LTCETH",
    "TRXETH", "BNBETH", "SOLBNB", "YFIBNB", "AAVEBNB", "CAKEBNB", "CTKBNB", "AAVEETH",
         "AAVEBTC", "CTKBTC", "BURGERBNB", "LTCBNB"]
global ids = [2108175166, 1171342242, 143895937, 937139506, 177158433, 461223069, 518604519, 328258901,
    377247841, 439691041, 113240496, 133437993, 27706687, 15259191, 26223294, 33519857,
        71940038, 51455887, 2399561, 171871707]

function whois(id) # Узнаём по id инструмент
    try
        for i in 1:20
            if (id > ids[i]) && (id < ids[i]*1.05)
                return symbols[i]
            end
        end
    catch
        src.logging("errors.log", 9, "Опознаватель сломался!!")
        println("Опознаватель сломался!!")
    end
end

function wsparse(json::Vector{UInt8}) # Парсить JSON регулярными выражениями быстрее
    try
        txt = String(json)
        rx = r"\d*\.\d*|\d+"
        m = eachmatch(rx, txt)
        collect(m)
    catch
        src.logging("errors.log", 0, "wsparse сломался")
    end
end

while true
    try
        LibPQ.Connection(src.data()["connPG"]) do conn
            function infile(book::Vector{RegexMatch}, symbol::String) # Запись в БД
                # println(" - ", symbol)
                try
                    execute(conn, """update prices set
                                    "$(sym[symbol]["base"])" = $(1/parse(Float64, book[12].match))
                                    where name = '$(sym[symbol]["quote"])';""")
                    execute(conn, """update prices set
                                    "$(sym[symbol]["quote"])" = $(book[2].match)
                                    where name = '$(sym[symbol]["base"])';""")
                catch
                    src.logging("errors.log", 0, "Запись в БД")
                end
            end

            function websocket(raw::String) # Вебсокет
                # symbol |> println
                try
                    HTTP.WebSockets.open(raw; verbose=false) do io
                        while !eof(io)
                            # global test = book
                            book = wsparse(readavailable(io))
                            infile(book, whois(parse(Int, book[1].match)))
                        end
                    end
                catch
                    src.logging("errors.log", 0, "Вебсокет отвалился")
                    websocket(raw)
                end
            end



            for x in 0:3 # Из списка инструментов готовим 4 строки по 5 символов
                raw = BN.BINANCE_API_WS[1:end-1]
                for i in 1:5
                    raw *= string("/", lowercase(symbols[x*5+i]), string("@depth", 5, "@100ms"))
                end
                @async websocket(raw)
                # println(raw)
            end

            while true
                sleep(1)
            end
        end
    catch
    end
end


#
# a
# tt = "wss://stream.binance.com:9443/ws/ltcbnb@depth5@100ms/burgerbnb@depth5@100ms/solbtc@depth5@100ms/ltceth@depth5@100ms/ethbtc@depth5@100ms"
# HTTP.WebSockets.open(tt; verbose = false) do io
#     while !eof(io)
#         global book = readavailable(io)
#         println(whois(book["lastUpdateId"]), "\t", book["asks"][1][1])
#     end
# end
#
#
# tt = string(BN.BINANCE_API_WS, lowercase("BTCUSDT"), string("@depth", 5, "@100ms"),
#     "/", lowercase("LTCUSDT"), string("@depth", 5, "@100ms"))
#



# ETHBTC      2108175166
    # BNBBTC      1171342242
    # TRXBNB      143895937
    # LTCBTC      937139506
    # SOLBTC      177158433
    # YFIBTC      461223069
    # TRXBTC      518604519
    # AAVEBTC     71940038
    # CTKBTC      51455887
    # SOLBNB      113240496
    # BURGERBNB   2399561
    # YFIBNB      133437993
    # AAVEBNB     27706687
    # CAKEBNB     15259191
    # CTKBNB      26223294
    # LTCBNB      171871707
    # LTCETH      328258901
    # TRXETH      377247841
    # BNBETH      439691041
    # AAVEETH     33519857
