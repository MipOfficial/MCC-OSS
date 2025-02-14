-- PocketOS Message Handler
-- Allows sending and receiving Base64-encoded messages

local modemSide = peripheral.find("modem")


-- Base64 Encoding & Decoding
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function toBase64(data)
    return ((data:gsub('.', function(x)
        local r,b64='',x:byte()
        for i=8,1,-1 do r=r..(b64%2^i-b64%2^(i-1)>0 and '1' or '0') end
        return r
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local n=0
        for i=1,6 do n=n+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b64chars:sub(n+1,n+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

local function fromBase64(data)
    data = data:gsub('[^'..b64chars..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f='',(b64chars:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        local n=0
        for i=1,8 do n=n+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(n)
    end))
end

-- Initialize Modem & Rednet
if not peripheral.isPresent(modemSide) then
    print("No modem found on " .. modemSide)
    return
end
rednet.open(modemSide)

-- Get user ID
local id = os.getComputerID()

-- UI Function
local function showMenu()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== PocketOS Messaging ===")
    print("[1] Send Message")
    print("[2] Read Messages")
    print("[3] Back")
    term.write("Select an option: ")
end

-- Message History Storage
local messages = {}

-- Main Loop
while true do
    showMenu()
    local choice = read()
    
    if choice == "1" then
        term.clear()
        term.setCursorPos(1, 1)
        print("Enter receiver ID: ")
        local targetID = tonumber(read())
        if not targetID then
            print("Invalid ID")
            sleep(1)
        else
            print("Enter message: ")
            local message = read()
            local encodedMsg = toBase64(message)
            rednet.send(targetID, encodedMsg, "pocket_message")
            print("Message sent!")
            sleep(1)
        end

    elseif choice == "2" then
        term.clear()
        term.setCursorPos(1, 1)
        print("=== Messages ===")
        while true do
            local sender, msg, protocol = rednet.receive("pocket_message", 1)
            if sender then
                local decodedMsg = fromBase64(msg)
                table.insert(messages, "[" .. sender .. "] " .. decodedMsg)
            else
                break
            end
        end
        if #messages == 0 then
            print("No new messages.")
        else
            for _, msg in ipairs(messages) do
                print(msg)
            end
        end
        print("\nPress Enter to return...")
        read()

    elseif choice == "3" then
        break

    else
        print("Invalid option. Try again.")
        sleep(1)
    end
end

-- Cleanup
rednet.close(modemSide)
