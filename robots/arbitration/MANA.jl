using DataFrames, CSV, Dates
include("/home/rosenrot/tradeBinance/robots/source/binanceAPI.jl")
include("/home/rosenrot/tradeBinance/robots/source/source.jl")

arb = src.arbPosCalc(30)
src.logging("arbPosCalc.log", 4, "$arb")
# @async BN.executeOrder(BN.createOrder("ADABNB", "sell";
#         quantity = arb["ADAin"], orderType="MARKET"), BN.apiKey, BN.apiSecret)
# @async BN.executeOrder(BN.createOrder("BNBBTC", "sell";
#         quantity = arb["BNBsell"], orderType="MARKET"), BN.apiKey, BN.apiSecret)
# @async BN.executeOrder(BN.createOrder("ADABTC", "buy";
#         quantity = arb["ADAout"], orderType="MARKET"), BN.apiKey, BN.apiSecret)



while true
    try
        #sleep(0.05)
        a = round((price("MANAETH", false)*price("ETHBTC", false)/price("MANABTC", true) - 1)*100, digits=3)
        b = round((price("MANABTC", false)/price("ETHBTC", true)/price("MANAETH", true) - 1)*100, digits=3)
        src.logging("ETHtoBTC.log", 0, "$a")
        src.logging("BTCtoETH.log", 0, "$b")
    catch
    end
end
