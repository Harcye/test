script_name("test")
script_description("Автообновление скрипта")

require "lib.moonloader"
local inicfg = require "inicfg"
local keys = require "vkeys"
local imgui = require "imgui"
local encoding = require "encoding"
local distatus = require "moonloader".download_status

encoding.default = "CP1251"
u8 = encoding.UTF8

local update_state = false
local script_vers = 2
local script_vers_text = "1.00"
local update_url = "https://raw.githubusercontent.com/Harcye/test/refs/heads/main/uptade.ini"
local update_path = getWorkingDirectory() .. "/update.ini"
local script_url = "https://github.com/Harcye/test/blob/main/test.lua"
local script_path = thisScript().path

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("update", cmd_update)
    check_for_update()
end

function check_for_update()
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == distatus.STATUS_ENDDOWNLOADDATA then
            sampAddChatMessage("Файл обновления загружен.", -1)
            
            -- Чтение конфигурационного файла обновлений
            local update_ini = inicfg.load(nil, update_path)
            if not update_ini then
                sampAddChatMessage("Ошибка при чтении файла обновлений.", -1)
                return
            end

            -- Проверка версии скрипта
            local update_version = tonumber(update_ini.info.vers)
            if update_version then
                sampAddChatMessage("Загружена версия обновления: " .. update_version, -1)
                if update_version > script_vers then
                    sampAddChatMessage("Доступно обновление: " .. update_version, -1)
                    update_state = true
                else
                    sampAddChatMessage("Версия актуальна, обновление не требуется.", -1)
                end
            else
                sampAddChatMessage("Не удалось получить версию обновления.", -1)
            end
            
            -- Удаляем временный файл обновлений
            os.remove(update_path)

            -- Если обновление доступно, скачиваем новый скрипт
            if update_state then
                download_script()
            end
        else
            sampAddChatMessage("Ошибка загрузки файла обновлений, статус: " .. status, -1)
        end
    end)
end

function download_script()
    sampAddChatMessage("Скачивание нового скрипта...", -1)
    
    -- Изменяем путь для скачивания скрипта
    local new_script_path = getWorkingDirectory() .. "/new_test.lua"
    
    downloadUrlToFile(script_url, new_script_path, function(id, status)
        if status == distatus.STATUS_ENDDOWNLOADDATA then
            sampAddChatMessage("Скрипт успешно обновлен!", -1)
            
            -- Задержка перед перезагрузкой скрипта
            wait(500)
            
            -- Перезагрузка скрипта
            thisScript():reload()
        else
            sampAddChatMessage("Ошибка загрузки скрипта, статус: " .. status, -1)
        end
    end)
end

function cmd_update()
    sampShowDialog(1000, "Автообновление 2.0", 
    "{FFFFFF} Это урок по обновлению\n{FFFF00} Новая версия доступна\n\n{FFFFFF} Автор: Алекс Чай", 
    "Закрыть", "", 0)
end
