local username = "user"
local deviceName = "pocket"
term.clear()
term.setCursorPos(1,1)
print("Welcome to PocketOS!")

while true do
    term.write(username .. "@" .. deviceName .. ":~$ ")
    local input = read()
    shell.run(input)
end
