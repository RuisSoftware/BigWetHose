--[[

Please Read : The only thing you can configure is the specific particle that comes out of the hose. You can modify this if you with for something like flames to come out.

--]]
firehose = {}
firehose.dictionary = "core"
firehose.particle = "water_cannon_jet"
firehose.particletwo = "water_cannon_spray"

--[[

Do not touch!

--]]

local x,y,z = table.unpack(GetEntityCoords(playerPed))
local xx,yy,zz = table.unpack(GetEntityForwardVector(playerPed))
xx = xx * 5
yy = yy * 5

local player = PlayerPedId()
local ped = PlayerPedId()

local enabled = false

RegisterCommand('hose', function(source, args, raw)
	if enabled == true then
		enabled = false  
		TriggerEvent('chat:addMessage', {
			color = { 255, 0, 0},
			multiline = true,
			args = {"Engineer", "Water is shutoff"}
		  })
		  print(enabled)
	else
		enabled = true
		TriggerEvent('chat:addMessage', {
			color = { 255, 0, 0},
			multiline = true,
			args = {"Me", "Water is flowing"}
		  })
		print(enabled)
	end
end, false)

Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(10000)
		RequestNamedPtfxAsset(firehose.dictionary)
		while not HasNamedPtfxAssetLoaded(firehose.dictionary) do
			Citizen.Wait(0)
		end

		print('\n[PARTICLES] Finished updating particle directory.')
	end
end)


Citizen.CreateThread(function()
	RequestNamedPtfxAsset(firehose.dictionary)
	while not HasNamedPtfxAssetLoaded(firehose.dictionary) do
		Citizen.Wait(0)
	end
	print('\n[PARTICLES] Finished updating particle directory.')

	local particleEffect = 0
	UseParticleFxAsset(firehose.dictionary)
	
	local pressed = false

	while true do
			Citizen.Wait(0)

			if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey('WEAPON_FIREEXTINGUISHER')  and (IsControlJustPressed(0, 24) or IsDisabledControlPressed(0, 24)) and not pressed then
				--print('c1')
				if enabled then
					--UseParticleFxAsset(firehose.dictionary)
					--particleEffect = StartNetworkedParticleFxLoopedOnEntity( firehose.particle, PlayerPedId(), 0.0, 0.0, 0.0, 0.1, 0.0, 0.0, 5.0, false, false, false )
					pressed = true
					TriggerServerEvent('StartParticleFxEffect:PhaseOne')
				end
			end

			if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey('WEAPON_FIREEXTINGUISHER') then
				--print('c2')
				if enabled then
					DisablePlayerFiring(PlayerId(), true)
					DisableControlAction(0, 24, true)
					if pressed then
						--SetParticleFxLoopedOffsets( particleEffect, 0.0, 0.0, 0.0, GetGameplayCamRelativePitch(), 0.0, 0.0 )
						TriggerServerEvent('StartParticleFxEffect:PhaseTwo', GetGameplayCamRelativePitch() )
					end
				end
			end

			if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) and pressed then
				--print('c3')
				if enabled then
					--StopParticleFxLooped(particleEffect, 0)
					TriggerServerEvent('StartParticleFxEffect:PhaseThree')
					pressed = false
				end
			end
	end
end)

function StartParticleFxEffect(dict, ptfx, posx, posy, posz)

    Citizen.CreateThread(function()
        UseParticleFxAssetNextCall(dict)
        local pfx = StartParticleFxLoopedAtCoord(ptfx, posx, posy, posz, 0.0, 0.0, GetEntityHeading(PlayerPedId()), 1.0, false, false, false, false)
        Citizen.Wait(100)
        StopParticleFxLooped(pfx, 0)
    end)

end

Citizen.CreateThread(function()
	
	while true do

		SetParticleFxShootoutBoat(true)

		if pressed then
			Citizen.Wait(100)
			local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 12.0 + GetGameplayCamRelativePitch()* 0.4, 0.0)
			local x = offset.x
			local y = offset.y

			local _,z = GetGroundZFor_3dCoord(x, y, off.z)

			Citizen.Wait(GetGameplayCamRelativePitch())
			--DrawLine(x, y, z - 0.2, x, y, z + 0.2, 255, 0, 0, 255)
			--DrawLine(x, y, 0.0, x, y, 800.0, 255, 0, 0, 255)
			--StartParticleFxEffect( firehose.dictionary, firehose.particle, x, y, z)
			--TriggerServerEvent('FireScript:FirePutOut', x, y, z)
            TriggerServerEvent('StartParticleFxEffect', firehose.dictionary, firehose.particle, x, y, z)

		else
			Citizen.Wait(0)
        end
    end
end)

local particleEffectSync = 0
local particleEffectSync2 = 0

RegisterNetEvent('Hose:PhaseOne')
AddEventHandler("Hose:PhaseOne", function(source)
    Citizen.CreateThread(function()
    	UseParticleFxAsset(firehose.dictionary)
		particleEffectSync = StartParticleFxNonLoopedOnEntity( firehose.particle, GetPlayerPed(GetPlayerFromServerId(source)), 10.0, 0.0, 0.0, 0.1, 0.0, 0.0, 1.0, false, false, false )
		UseParticleFxAsset(firehose.dictionary)
    	particleEffectSync2 = StartParticleFxNonLoopedOnEntity( firehose.particletwo, GetPlayerPed(GetPlayerFromServerId(source)), 10.0, 0.0, 0.0, 0.1, 0.0, 0.0, 1.0, false, false, false )
    end)
end)


RegisterNetEvent('Hose:PhaseTwo')
AddEventHandler("Hose:PhaseTwo", function(pitch, source)
	Citizen.CreateThread(function()
		SetParticleFxLoopedOffsets( particleEffectSync, 0.0, 0.0, 0.0, pitch, 0.0, 0.0 )
		SetParticleFxLoopedOffsets( particleEffectSync2, 0.0, 8.0, 0.0, 0.0, 0.0, 0.0 )
	end)
end)


RegisterNetEvent('Hose:PhaseThree')
AddEventHandler("Hose:PhaseThree", function(source)
	Citizen.CreateThread(function()
		StopParticleFxLooped(particleEffectSync, 0)
		StopParticleFxLooped(particleEffectSync2, 0)
	end)
end)

