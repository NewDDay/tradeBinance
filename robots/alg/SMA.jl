using LibPQ, DataFrames, Dates
cd("/home/rosenrot/tradeBinance")
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")
src.logging("common.log", 0, "Start SMA.jl")


LibPQ.Connection(src.data()["connPG"]) do conn
    df = execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" ORDER BY start DESC LIMIT 1260;""") |> DataFrame
    buf_short = sum(df[1:540, 4])/540
    buf_long = sum(df[1:end, 4])/1260

    global flag = 1
    while true
        sleep(1)
        df = execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" ORDER BY start DESC LIMIT 1260;""") |> DataFrame
        short = sum(df[1:540, 4])/540
        long = sum(df[1:end, 4])/1260

        if (short > long) && (buf_short < buf_long) && (flag == 0)
            global flag = 1
            try
            # println(" - - - - - - -- - - - - - - - - ")
            BN.executeOrder(BN.createOrder("BTCUSDT", "buy";
                quantity = 0.001000, orderType="MARKET"), BN.apiKey, BN.apiSecret)
                sleep(30)
            catch
            end
        elseif (short < long) && (buf_short > buf_long) && (flag == 1)
            try
            flag = 0
            BN.executeOrder(BN.createOrder("BTCUSDT", "sell";
                quantity = 0.001000, orderType="MARKET"), BN.apiKey, BN.apiSecret)
                sleep(30)
            catch
            end
        end
        buf_short = short
        buf_long = long
    end
end
