using LibPQ, DataFrames, Dates
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

LibPQ.Connection(src.data()["connPG"]) do conn
    df = execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" ORDER BY start DESC LIMIT 6;""") |> DataFrame
    buf_short = sum(df[1:2, 4])/2
    buf_long = sum(df[1:end, 4])/6

    global flag = 0
    while true
        df = execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" ORDER BY start DESC LIMIT 6;""") |> DataFrame
        short = sum(df[1:2, 4])/2
        long = sum(df[1:end, 4])/6

        # println("\n$buf_short\t\t$buf_long\n$short\t\t$long")
        # sleep(1)

        if (short > long) && (buf_short < buf_long)
            global flag = 1
            try
            # println(" - - - - - - -- - - - - - - - - ")
            BN.executeOrder(BN.createOrder("BTCUSDT", "buy";
                quantity = 0.000400, orderType="MARKET"), BN.apiKey, BN.apiSecret)
            catch
            end
        elseif (short < long) && (buf_short > buf_long) && (flag == 1)
            try
            flag = 0
            BN.executeOrder(BN.createOrder("BTCUSDT", "sell";
                quantity = 0.000400, orderType="MARKET"), BN.apiKey, BN.apiSecret)
            catch
            end
        end
        buf_short = short
        buf_long = long
    end
end
