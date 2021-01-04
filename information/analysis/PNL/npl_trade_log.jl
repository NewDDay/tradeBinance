using CSV, Plots, Dates, DataFrames
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")
plotly()

df = DataFrame(CSV.File("/home/rosenrot/tradeBinance/information/log/export.csv"))

df = df[df[!, 1] .!== missing,:]
df = df[df[!,:Pair].=="BTCUSDT",:]
df = df[df[!,:Filled].<0.0005,:]
df = df[df[!,:status].=="Filled",:]

s = []
sum = 0
for x in eachrow(df)
    x["Type"] == "BUY" ? sum += x["Filled"] : sum -= x["Filled"]
    push!(s, sum)
end
x = collect(length(s):-1:1)

plot(x, s, title = "SMA изменение баланса BTC",
    label = "Баланс BTC",
    xlabel = "Номер операции",
    ylabel = "Количество BTC",
    legendtitle = "30.12.2020-03.01.2021",
    legendtitlefontsize = 8,
    size = (800, 500))

savefig("SMA_BTC_Balance.png")


s = []
sum = 0
for x in eachrow(df)
    x["Type"] == "BUY" ? sum += x["Total"] : sum -= x["Total"]
    push!(s, sum)
end

s = [0.0]
pop!(s)
p = [0.0]
l = [0.0]
t = []
for x in eachrow(df)
    if x["Type"] == "BUY"
        push!(p, x["Total"])
    else
        push!(t, x["Date(UTC)"])
        push!(l, x["Total"])
    end
    try
        # push!(s, p[end] - l[end])
    catch
    end
end

for x in 1:length(p)
    push!(s, l[x]-p[x])
end

reverse!(t)
s = reverse(s)

x = collect(length(s):-1:1)
y = s
A = [ones(length(s)) x x.^2 x.^3 x.^4 x.^5]
c = A \ y
f = c[1]*ones(length(s)) + c[2]*x + c[3]*x.^2 + c[4]*x.^3 + c[5]*x.^4 + c[6]*x.^5
plot(t, s[2:end],
    title = "Работа SMA робота",
    label = "Прибыль",
    xlabel = "Время",
    ylabel = "USDT",
    legendtitle = "Оборачиваемые средства ~ 13\$",
    xrotation = 20,
    legendtitlefontsize = 8)
plot!(t, f[2:end], linewidth = 1, color = :brown, label = "Аппроксимация")
