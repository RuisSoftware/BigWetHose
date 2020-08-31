RegisterNetEvent('StartParticleFxEffect')
AddEventHandler("StartParticleFxEffect", function(dictionary, particle, x, y, z)
    TriggerClientEvent('Hose:StartParticle', -1, dictionary, particle, x, y, z, source)
end)

RegisterNetEvent('StartParticleFxEffect:PhaseOne')
AddEventHandler("StartParticleFxEffect:PhaseOne", function()
    TriggerClientEvent('Hose:PhaseOne', -1, source)
end)

RegisterNetEvent('StartParticleFxEffect:PhaseTwo')
AddEventHandler("StartParticleFxEffect:PhaseTwo", function(pitch)
    TriggerClientEvent('Hose:PhaseTwo', -1, pitch, source)
end)

RegisterNetEvent('StartParticleFxEffect:PhaseThree')
AddEventHandler("StartParticleFxEffect:PhaseThree", function()
    TriggerClientEvent('Hose:PhaseThree', -1, source)
end)
