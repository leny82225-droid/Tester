-- DELTA GUI AUTO JOB MAXGEN (AUTO SEAT & SMART ROUTE)
-- Owner: brukontop

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("BrukOntop_FloatingGUI") then
    CoreGui["BrukOntop_FloatingGUI"]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrukOntop_FloatingGUI"

local success = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 110)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local OwnerLabel = Instance.new("TextLabel")
OwnerLabel.Parent = MainFrame
OwnerLabel.Text = "OWNER: BRUKONTOP"
OwnerLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
OwnerLabel.Size = UDim2.new(1, 0, 0, 30)
OwnerLabel.Font = Enum.Font.SourceSansBold
OwnerLabel.TextSize = 12

local BtnAutoJob = Instance.new("TextButton")
BtnAutoJob.Parent = MainFrame
BtnAutoJob.Text = "AUTO JOB MAXGEN"
BtnAutoJob.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
BtnAutoJob.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnAutoJob.Position = UDim2.new(0.1, 0, 0.4, 0)
BtnAutoJob.Size = UDim2.new(0.8, 0, 0.45, 0)
BtnAutoJob.Font = Enum.Font.SourceSansBold
BtnAutoJob.TextSize = 11

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = BtnAutoJob

local isRunning = false

-- Fungsi Pergerakan Halus (Anti-Cheat & Anti-Jatuh)
local function moveSmoothly(part, targetCF, speed)
    if not part or not part.Parent then return end
    
    -- Matikan tabrakan sementara agar tidak tersangkut rumah/tembok
    for _, child in pairs(part.Parent:GetDescendants()) do
        if child:IsA("BasePart") then
            child.CanCollide = false
        end
    end

    local distance = (part.Position - targetCF.Position).Magnitude
    local duration = math.max(distance / (speed or 25), 0.5)

    local tween = TweenService:Create(
        part,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {CFrame = targetCF}
    )
    tween:Play()
    tween.Completed:Wait()
end

-- Cari Kursi Mobil (Seat)
local function findVehicleSeat()
    local bedilPusat = Workspace:FindFirstChild("Ekonomi") and Workspace.Ekonomi:FindFirstChild("BedilPusat")
    
    -- Cari dari folder BP / BedilPusat
    if bedilPusat then
        local seat = bedilPusat:FindFirstChild("Seat", true) or bedilPusat:FindFirstChild("DriveSeat", true)
        if seat then return seat end
    end
    
    -- Cari mobil "BP" umum di Workspace
    local bpCar = Workspace:FindFirstChild("BP")
    if bpCar then
        return bpCar:FindFirstChild("Seat", true) or bpCar:FindFirstChild("DriveSeat", true) or bpCar:FindFirstChildWhichIsA("VehicleSeat", true)
    end
    
    return nil
end

-- Cari Titik Target Pengantaran / Panah
local function getTargetCFrame()
    -- Cek target dinamis (ClientTemp / DummyTarget)
    for _, obj in pairs(Workspace:GetChildren()) do
        if string.find(obj.Name, "ClientTemp_") or string.find(obj.Name, "DummyTarget_") then
            local targetObj = obj:FindFirstChildWhichIsA("BasePart", true) or obj:FindFirstChildWhichIsA("Model", true)
            if targetObj then
                return targetObj:IsA("Model") and targetObj:GetPivot() or targetObj.CFrame
            end
        end
    end
    
    -- Cek folder DeliveryTargets / Finish
    local bedilPusat = Workspace:FindFirstChild("Ekonomi") and Workspace.Ekonomi:FindFirstChild("BedilPusat")
    if bedilPusat then
        if bedilPusat:FindFirstChild("Finish") then
            return bedilPusat.Finish.CFrame
        end
    end
    return nil
end

-- Loop Utama Auto Job
local function startAutoJobLoop()
    task.spawn(function()
        while isRunning do
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local root = char:WaitForChild("HumanoidRootPart")
            
            local bedilPusat = Workspace:FindFirstChild("Ekonomi") and Workspace.Ekonomi:FindFirstChild("BedilPusat")
            
            -- 1. BERJALAN KE TITIK JOB (MERAH)
            if bedilPusat and bedilPusat:FindFirstChild("Job") then
                moveSmoothly(root, bedilPusat.Job.CFrame + Vector3.new(0, 3, 0), 20)
                task.wait(1.5) -- Tunggu job terambil
            end
            
            -- 2. OTOMATIS MASUK / DUDUK DI KURSI MOBIL (SEAT)
            local seat = findVehicleSeat()
            if seat and not hum.SeatPart then
                root.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.5)
                seat:Sit(hum)
                task.wait(1)
            end
            
            -- 3. JIKA SUDAH DUDUK DI MOBIL, JALANKAN MOBIL KE TARGET
            if hum.SeatPart then
                local vehicleSeat = hum.SeatPart
                local vehicleModel = vehicleSeat.Parent
                local primaryPart = vehicleModel.PrimaryPart or vehicleSeat
                
                local targetCF = getTargetCFrame()
                if targetCF then
                    -- Terbang melayang perlahan menuju target
                    moveSmoothly(primaryPart, targetCF + Vector3.new(0, 4, 0), 25)
                    
                    -- Turun perlahan ke tanah agar tidak menembus map
                    moveSmoothly(primaryPart, targetCF + Vector3.new(0, 1, 0), 10)
                    
                    -- Menunggu di target sampai notifikasi pengantaran selesai
                    task.wait(4)
                end
                
                -- 4. PERGI KE TITIK FINISH
                if bedilPusat and bedilPusat:FindFirstChild("Finish") then
                    local finishCF = bedilPusat.Finish.CFrame
                    moveSmoothly(primaryPart, finishCF + Vector3.new(0, 4, 0), 25)
                    moveSmoothly(primaryPart, finishCF + Vector3.new(0, 1, 0), 10)
                    task.wait(3)
                end
            end
            
            -- 5. CEK APAKAH MOBIL SUDAH HILANG / SELESAI
            task.wait(2)
        end
    end)
end

BtnAutoJob.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        BtnAutoJob.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        BtnAutoJob.Text = "STATUS: ON"
        startAutoJobLoop()
    else
        BtnAutoJob.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        BtnAutoJob.Text = "AUTO JOB MAXGEN"
    end
end)
