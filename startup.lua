-- PocketOS Startup Script

-- Clear screen and set cursor position
term.clear()
term.setCursorPos(1, 1)

print("PocketOS is booting...")
sleep(1) -- Small delay for boot effect

-- Check if settings exist; create default settings if not
if not fs.exists("settings.lua") then
    local file = fs.open("settings.lua", "w")
    file.write([[return {
        alerts = true,
        messages = true
    }]])
    file.close()
end

-- Load settings
local settings = dofile("settings.lua")

-- Function to display the main menu
local function showMenu()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== PocketOS Main Menu ===")
    print("[1] Settings")
    print("[2] Messages")
    print("[3] Shutdown")
    print("[4] Reboot")
    print("[5] Exit to Shell")
    term.write("Select an option: ")
end

-- Menu loop
while true do
    showMenu()
    local choice = read()
    
    if choice == "1" then
        shell.run("settings.lua") -- Opens the settings script
    elseif choice == "2" then
        shell.run("message_handler.lua") -- Opens message UI
    elseif choice == "3" then
        os.shutdown()
    elseif choice == "4" then
        os.reboot()
    elseif choice == "5" then
        shell.run("shell.lua")
    else
        print("Invalid option. Try again.")
        sleep(1)
    end
end

print("Exiting to shell...")
sleep(1)
term.clear()
term.setCursorPos(1, 1)
