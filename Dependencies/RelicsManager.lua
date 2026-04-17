-- Stub de RelicsManager para el AI Director System
-- Simula la entrega de recompensas / recursos a los jugadores.
local RelicsManager = {}

function RelicsManager:giveRelic(player, relicName, amount)
    print(`[RelicsManager STUB] {player.Name} recibió {amount} {relicName}`)
end

function RelicsManager:dropRandom(player, amount)
    print(`[RelicsManager STUB] Drop aleatorio de {amount} objeto(s) para {player.Name}`)
end

return RelicsManager
