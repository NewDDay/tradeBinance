using LibPQ, DataFrames, HTTP, Dates
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

sym = src.symbols()

function wsparse(json::Vector{UInt8})
    txt = String(json)
    rx = r"\d*\.\d*|\d+"
    m = eachmatch(rx, txt)
    collect(m)
end





LibPQ.Connection(src.data()["connPG"]) do conn

    function infile(book::Vector{RegexMatch}, symbol::String)
        execute(conn, """update prices set
                        "$(sym[symbol]["base"])" = $(1/parse(Float64, book[12].match))
                        where name = '$(sym[symbol]["quote"])';""")
        execute(conn, """update prices set
                        "$(sym[symbol]["quote"])" = $(book[2].match)
                        where name = '$(sym[symbol]["base"])';""")
        # println("$(book[2].match),$(book[12].match), $(now(UTC))")
    end

    function websocket(symbol::String)
        # symbol |> println
        HTTP.WebSockets.open(string(BN.BINANCE_API_WS, lowercase(symbol), string("@depth", 5, "@100ms")); verbose=false) do io
            while !eof(io)
                book = wsparse(readavailable(io))
                global test = book
                infile(book, symbol)
            end
        end
    end

    @async websocket("LTCBTC")
    @async websocket("ETHBTC")
    @async websocket("CTKBTC")
    @async websocket("SOLBTC")
    @async websocket("YFIBTC")
    @async websocket("AAVEBTC")
    @async websocket("TRXBTC")
    @async websocket("BNBETH")
    @async websocket("LTCBNB")
    @async websocket("SOLBNB")
    @async websocket("YFIBNB")
    @async websocket("TRXBNB")
    @async websocket("AAVEBNB")
    @async websocket("BNBBTC")
    @async websocket("BURGERBNB")
    @async websocket("CAKEBNB")
    @async websocket("CTKBNB")
    @async websocket("LTCETH")
    @async websocket("AAVEETH")
    @async websocket("TRXETH")

    while true
        sleep(1)
    end
end
