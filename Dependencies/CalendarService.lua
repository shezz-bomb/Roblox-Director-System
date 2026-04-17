-- Stub de CalendarService para el AI Director System
-- Simula penalizaciones al jugador dominante y recompensas a los novatos.
local CalendarService = {}

function CalendarService:punishDominant(player, kills)
    print(`[CalendarService STUB] {player.Name} es dominante con {kills} kills. Penalización aplicada (simulada).`)
end

function CalendarService:rewardNoob(player, kills)
    print(`[CalendarService STUB] {player.Name} es novato ({kills} kills). Recompensa aplicada (simulada).`)
end

return CalendarService
