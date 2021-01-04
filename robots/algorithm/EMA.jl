using LibPQ, DataFrames, Dates
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

flag = 0
LibPQ.Connection(src.data()["connPG"]) do conn
    df = execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" ORDER BY start DESC LIMIT 6;""") |> DataFrame
    buf_short = df[2, 4] # для рассчёта по формуле
    buf_long = df[2, 4]
    pre_short = df[2, 4] # Предыдущее значение. Для пересечения.
    pre_long = df[2, 4]
    time = df[2, 1]
    α = 2/7
    β = 2/3

    while true
        df = execute(conn, """SELECT * FROM "kline_BTCUSDT_1m" ORDER BY start DESC LIMIT 2;""") |> DataFrame
        short = df[1, 4]*β + buf_short * (1-β)
        long = df[1, 4]*α + buf_long * (1-α)

        if (short > long) && (pre_short < pre_long)
            global flag = 1
            try
            BN.executeOrder(BN.createOrder("BTCUSDT", "buy";
                quantity = 0.000400, orderType="MARKET"), BN.apiKey, BN.apiSecret)
            catch
            end
        elseif (short < long) && (pre_short > pre_long) && (flag == 1)
            try
            flag = 0
            BN.executeOrder(BN.createOrder("BTCUSDT", "sell";
                quantity = 0.000400, orderType="MARKET"), BN.apiKey, BN.apiSecret)
            catch
            end
        end
        if df[2, 1] > time
            time = df[2, 1]
            buf_short = short
            buf_long = long
        end
        pre_short = short
        pre_long = long
    end
end
