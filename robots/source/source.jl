# В этом файле размещены вспомогательные функции.

module src
    using Dates, JSON, CSV, DataFrames

    """
        logging(namefile::String, relevance::Integer, str::String)

    Записать событие в лог-файл.
    Фиксирует время событие.
    Можно присвоить цифру от 0 до 9 для убодного поиска.
    # Examples
    ```julia-repl
    julia> logging(2, "Start")
    [2020-07-02T15:42:13.14][2]     Start
    ```
    """
    function logging(namefile::String, relevance::Integer, str::String)
        if -1 < relevance < 10
            try
                open("/home/rosenrot/tradeBinance/information/log/$namefile", "a") do io
                    write(io, "[$(now(UTC))][$relevance] \t$str \n")
                end
            catch
                @error("Не удаётся открыть лог файл") # "julia > book &". При это команде, эта строка выбьется в консоль
                println("Не удаётся открыть лог файл") # А эта в файл.
            end
        else
            @error("Не правильный приоритет! Логи не ведутся!")
            println("Не правильный приоритет! Логи не ведутся!")
        end
    end

    """
        tradelog(inf::Dict)

    Функция записывает ордер в csv-файл. Настраивается конфигом.
    # Examples
    ```julia-repl
    julia> BN.executeOrder(BN.createOrder("BNBBTC", "sell"; quantity = 0.11, orderType="MARKET"), BN.apiKey, BN.apiSecret)
    *in file or pg
    │ Row │ Date                    │ Pair   │ Side   │ Type   │ Quontity   │ Price      │ Total       │ Fee        │ Status │
    │     │ DateTime                │ String │ String │ String │ String     │ String     │ Float64     │ String     │ String │
    ├─────┼─────────────────────────┼────────┼────────┼────────┼────────────┼────────────┼─────────────┼────────────┼────────┤
    │ 1   │ 2020-07-04T11:06:32.226 │ BNBBTC │ SELL   │ MARKET │ 0.11000000 │ 0.00169310 │ 0.000186241 │ 0.00008415 │ FILLED │

    ```
    """
    function tradelog(inf::Dict)
        ff = DataFrame(Date = unix2datetime(inf["transactTime"]/1000), Pair = inf["symbol"], Side = inf["side"], Type = inf["type"], Quontity = inf["fills"][1]["qty"], Price = inf["fills"][1]["price"], Total = parse(Float64, inf["fills"][1]["qty"])*parse(Float64, inf["fills"][1]["price"]), Fee = inf["fills"][1]["commission"], Status = inf["status"])
        try
            CSV.write("/home/rosenrot/tradeBinance/information/log/orders.csv", ff; append=true)
        catch
            @error("Не удалось записать ордер в orders.csv")
            logging("common.log", 0, "Не удалось записать ордер в orders.csv")
        end
    end

    """
        symbols()

    Это все торгуемые пары Бинанса, разбитые на base и quote currency.
    # Examples
    ```julia-repl
    julia> symbols()["LTCBTC"]
    Dict{String, Any} with 2 entries
    "quote" => "BTC"
    "base" => "LTC"
    ```
    """
    function symbols()
        try
            open("/home/rosenrot/tradeBinance/robots/source/symbols.json", "r+") do io
                global symbols
                json = String(read(io))
                symbol = JSON.parse(json)
            end
        catch
            @error("Не удаётся открыть файл symbols.json")
            logging("common.log", 1, "Не удаётся открыть файл symbols.json")
        end
    end

    """
        config()

    Это конфиг проекта, сюда выводятся переменные управления проектом.
    # Examples
    ```julia-repl
    julia> config()["logging"]["orders in csv"]
    1
    ```
    """
    function config()
        try
            open("/home/rosenrot/tradeBinance/information/config/config.json", "r+") do io
                json = String(read(io))
                JSON.parse(json)
            end
        catch
            @error("Не удаётся открыть файл config.json")
            logging("common.log", 2, "Не удаётся открыть файл config.json")
        end
    end

    """
        data()

    Файл с доступами и паролями. Загружается вручную.

    """
    function data()
        try
            open("/home/rosenrot/tradeBinance/secret/data.json", "r+") do io
                json = String(read(io))
                JSON.parse(json)
            end
        catch
            @error("Не удаётся открыть файл data.json")
            logging("common.log", 3, "Не удаётся открыть файл data.json")
        end
    end

    function price(symbol::String, ask::Bool)
        df = DataFrame(CSV.File("/home/rosenrot/tradeBinance/quotation/now/$symbol.csv"))
        if df.time[1] + Second(2) > now(UTC)
            if ask
                return df.askprice[1]
            else
                return df.bidprice[1]
            end
        else
            "timeout" |> println
            return "timeout"
        end
    end

    function arbPosCalc(ADA::Number)
        bnbPrice = src.price("ADABNB", true)
        BNB = round(ADA * bnbPrice, digits = 6)

        bnbRound = BNB - BNB % 0.01
        btcPrice = src.price("BNBBTC", true)
        BTC = round(bnbRound*btcPrice, digits = 7)

        adaPrice = src.price("ADABTC", false)
        ADAnew = (BTC/adaPrice) ÷ 1
        btcRound = round(ADAnew*adaPrice, digits = 8)
        # println(bnbPrice)
        # println(btcPrice)
        # println(adaPrice)
        dict = Dict([("ADAin", ADA), ("BNBbuy", BNB), ("BNBsell", bnbRound),
            ("BTCbuy", BTC), ("BTCsell", btcRound), ("ADAout", ADAnew)])
        return dict
    end
end
