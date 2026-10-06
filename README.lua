-- Macro Ranura 2 - Ultra Rápida con Bloqueo de Lobby (Fix F1 y P)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

-- Configuración de velocidad ultra rápida
local TIEMPO_DISPARO = 0.01  
local TIEMPO_ESPERA  = 0.01  

local ejecutando = false
local macroActivada = true -- Interruptor general (Puedes apagarlo con P o F1)
local nombreArmaSlot2 = nil

-- Función para escanear el inventario
local function actualizarArmaSlot2()
    local herramientas = localPlayer.Backpack:GetChildren()
    local contador = 0
    for _, obj in ipairs(herramientas) do
        if obj:IsA("Tool") then
            contador = contador + 1
            if contador == 2 then
                nombreArmaSlot2 = obj.Name
                break
            end
        end
    end
end

actualizarArmaSlot2()

-- Interruptor de emergencia: Presiona 'F1' o 'P' para encender/apagar la macro manualmente
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F1 or input.KeyCode == Enum.KeyCode.P then
        macroActivada = not macroActivada
        print("Macro Estado: " .. (macroActivada and "ENCENDIDA" or "APAGADA"))
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Si la macro está apagada, estás chateando, o ya se está ejecutando un tiro, CANCELAR
    if not macroActivada or gameProcessed or ejecutando then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local character = localPlayer.Character
        if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
            return 
        end
        
        ---------------------------------------------------------
        -- FILTRO estricto anti-lobby:
        local spawnPart = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("LobbySpawn")
        if spawnPart and character:FindFirstChild("HumanoidRootPart") then
            local distanciaAlLobby = (character.HumanoidRootPart.Position - spawnPart.Position).Magnitude
            if distanciaAlLobby < 45 then 
                return -- Si estás cerca del lobby, no se activa
            end
        end
        ---------------------------------------------------------

        local herramientaEquipada = character:FindFirstChildOfClass("Tool")
        if herramientaEquipada and herramientaEquipada.Name ~= nombreArmaSlot2 then 
            return -- Si tienes el cuchillo afuera, te deja usarlo sin bugearse
        end
        
        if not nombreArmaSlot2 then
            actualizarArmaSlot2()
        end
        
        local armaSlot2 = localPlayer.Backpack:FindFirstChild(nombreArmaSlot2) or character:FindFirstChild(nombreArmaSlot2)
        
        if armaSlot2 then
            ejecutando = true
            
            task.spawn(function()
                character.Humanoid:UnequipTools()
                
                armaSlot2.Parent = character
                
                -- Ejecuta el disparo
                armaSlot2:Activate()
                task.wait(TIEMPO_DISPARO)
                
                armaSlot2:Deactivate()
                task.wait(TIEMPO_ESPERA)
                armaSlot2.Parent = localPlayer.Backpack
                
                ejecutando = false
            end)
        end
    end
end)

localPlayer.CharacterAdded:Connect(function()
    nombreArmaSlot2 = nil
    ejecutando = false
    task.wait(0.5)
    actualizarArmaSlot2()
end)

print("¡Macro Ranura 2 con Fix F1 cargada con éxito!")
