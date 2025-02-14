-- PocketOS Startup Script
-- Test
-- Clear screen and set cursor position
term.clear()
term.setCursorPos(1, 1)

print("PocketOS is booting...")
sleep(1) -- Small delay for boot effect

-- GitHub Repository for updates
local repoURL = "https://raw.githubusercontent.com/YourUsername/PocketOS/main/"

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

-- Function to check and apply updates
local function updateFiles()
    term.clear()
    term.setCursorPos(1, 1)
    print("Checking for updates...")

    local filesToCheck = { "startup.lua", "settings.lua", "message_handler.lua" }
    local updatesAvailable = false

    for _, file in ipairs(filesToCheck) do
        local remoteFile = http.get(repoURL .. file)
        if remoteFile then
            local remoteContent = remoteFile.readAll()
            remoteFile.close()
            
            -- Read local file if it exists
            local localContent = ""
            if fs.exists(file) then
                local localFile = fs.open(file, "r")
                localContent = localFile.readAll()
                localFile.close()
            end

            -- If the file is different or missing, update it
            if localContent ~= remoteContent then
                updatesAvailable = true
                print("Updating: " .. file .. "...")
                
                local updateFile = fs.open(file, "w")
                updateFile.write(remoteContent)
                updateFile.close()

                print(file .. " updated successfully.")
            else
                print(file .. " is already up to date.")
            end
        else
            print("Failed to fetch " .. file)
        end
        sleep(0.5)
    end

    if updatesAvailable then
        print("\nUpdates applied! Restarting...")
        sleep(2)
        os.reboot()
    else
        print("\nNo updates found. Press Enter to return...")
        read()
    end
end

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
    print("[6] Check for Updates") -- Now auto-updates
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
    elseif choice == "6" then
        updateFiles() -- Now auto-updates files
    else
        print("Invalid option. Try again.")
        sleep(1)
    end
end

print("Exiting to shell...")
sleep(1)
term.clear()
term.setCursorPos(1, 1)

