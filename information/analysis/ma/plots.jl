using Plots, CSV, DataFrames, BenchmarkTools
# plotly()
gr()

include("/home/rosenrot/tradeBinance/robots/source/analysis.jl")

prices = DataFrame(CSV.File("/home/rosenrot/tradeBinance/information/analysis/ma/history/1h.txt")).CLOSE

sma_short = an.sma(prices, 6) # Средние скользящие
sma_medium = an.sma(prices, 19)

inpos = false # В позиции. Если есть что продать
balance = [prices[1]] # Для рассчёта баланса. В начале имеем 1 биток
balance_num = [1] # Начальный момент
taxes = []
profit = []
btc = 0

println("\n--------------------------------------------START------------------------------------------------------------------\n")
for i in 2:length(prices)
    if (sma_short[i-1] < sma_medium[i-1]) && (sma_short[i] > sma_medium[i])
        btc = balance[end]/prices[i]
        push!(taxes, balance[end]*0.00075)
        push!(balance_num, i)
        push!(balance, (balance[end] - taxes[end]))
        inpos = true
        # println("$i  \tbuy \t$(balance[end]) -> $btc \t $(taxes[end])")
        # push!(buy, sum([ma_short[i-1], sma_long[i-1], sma_short[i], sma_long[i]])/4)
        # println("buy - $i")
    end
    if (sma_short[i-1] > sma_medium[i-1]) && (sma_short[i] < sma_medium[i]) && (inpos == true)
        push!(taxes, balance[end]*0.00075)
        push!(balance, (btc*prices[i]) - taxes[end])
        push!(profit, (balance[end] - balance[end-1]))
        push!(balance_num, i)
        inpos = false
        # println("$i  \tsell \t$(btc) -> $(balance[end]) \t $(taxes[end]) \t $(profit[end])")
        # push!(sell, sum([ma_short[i-1], sma_long[i-1], sma_short[i], sma_long[i]])/4)
        # println("sell - $i")
    end
end

plot(prices,
    size = (12000, 4500),
    width = 2,
    color = :black,
    smarker = (:dots,1),
    label = "Цена")
plot!(sma_short,
    width = 1.5,
    color = :red,
    label = "Короткая",
    smarker = (:dots,1))
plot!(sma_medium,
    width = 1.5,
    color = :blue,
    label = "Средняя",
    smarker = (:dots,1))
plot!(balance_num, balance,
    color = :green,
    smarker = (:dots,1),
    label = "Баланс")
savefig("results.png")
pwd()
-------------------------------

files = ["10min.txt", "10min.txt","10min.txt","15min.txt", "30min.txt", "1h.txt", "1d.txt", "1w.txt", "1min.txt", "5min.txt",]

a = 0
results = [[], []]
for j in files
    a += 1
    prices = DataFrame(CSV.File("/home/rosenrot/tradeBinance/information/analysis/ma/history/$j")).CLOSE
    push!(results[1], "")
    push!(results[2], 0.0)

    for short in 2:8
        # push!(results, short)
        for long in (short*2):(short*5)
            # push!(results[(short-1)], long)
            sma_short = an.sma(prices, short) # Средние скользящие
            sma_medium = an.sma(prices, long)

            inpos = false # В позиции. Если есть что продать
            # balance = [prices[1]] # Для рассчёта баланса. В начале имеем 1 биток
            balance = [1000.0]
            balance_num = [1] # Начальный момент
            taxes = []
            profit = []
            btc = 0

            # println("\n--------------------------------------------START------------------------------------------------------------------\n")
            for i in 2:length(prices)
                if (sma_short[i-1] < sma_medium[i-1]) && (sma_short[i] > sma_medium[i])
                    btc = balance[end]/prices[i]
                    push!(taxes, balance[end]*0.00075)
                    push!(balance_num, i)
                    push!(balance, (balance[end] - taxes[end]))
                    inpos = true
                    # println("$i  \tbuy \t$(balance[end]) -> $btc \t $(taxes[end])")
                    # push!(buy, sum([ma_short[i-1], sma_long[i-1], sma_short[i], sma_long[i]])/4)
                    # println("buy - $i")
                end
                if (sma_short[i-1] > sma_medium[i-1]) && (sma_short[i] < sma_medium[i]) && (inpos == true)
                    push!(taxes, balance[end]*0.00075)
                    push!(balance, (btc*prices[i]) - taxes[end])
                    push!(profit, (balance[end] - balance[end-1]))
                    push!(balance_num, i)
                    inpos = false
                    # println("$i  \tsell \t$(btc) -> $(balance[end]) \t $(taxes[end]) \t $(profit[end])")
                    # push!(sell, sum([ma_short[i-1], sma_long[i-1], sma_short[i], sma_long[i]])/4)
                    # println("sell - $i")
                end
            end
            if balance[end] > results[2][a]
                results[2][a] = balance[end]
                results[1][a] = "$short - $long"

                # println("$short - $long - \t", balance[end])
                # old = balance[end]
                # # push!(m, balance[end])
            end
        end
    end
    println("$j \t ($(results[1][a])) \t $(results[2][a])")
end
