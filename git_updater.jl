using Dates

time = Day(now(UTC))

while true
	try
	global time
    if time != Day(now(UTC))
        time = Day(now(UTC))
        run(`git add ./information/log/\*`)
        run(`git commit -m "log upd $(Date(now(UTC)))"`)
        run(`git push`)
    end
	catch
	end
end
