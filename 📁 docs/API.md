
# 📚 API Reference - AI Director System

Referencia completa de los métodos públicos de cada módulo del sistema.

---

## 🔹 DirectorController

Módulo principal que orquesta el ciclo de decisión.

| Método | Descripción |
|--------|-------------|
| `DirectorController:start(interval: number?)` | Inicia el loop del Director. Evalúa eventos cada `interval` segundos (por defecto 30). |
| `DirectorController:stop()` | Detiene el loop. |

**Ejemplo:**
```lua
local DirectorController = require(path.to.DirectorController)
DirectorController:start(25) -- Decide cada 25 segundos
```

---

## 🔹 DirectorMonitor

Recolecta métricas de la partida y calcula el nivel de ira.

| Método | Retorno | Descripción |
|--------|---------|-------------|
| `DirectorMonitor:getMetrics()` | `table` | Recalcula y devuelve las métricas actuales de la partida. |
| `DirectorMonitor:calculateAnger()` | `number` | Calcula y devuelve el nivel de ira (0-100) basado en las métricas. |
| `DirectorMonitor:getCurrentMetrics()` | `table` | Devuelve la última tabla de métricas **sin recalcular**. |
| `DirectorMonitor:getCurrentAnger()` | `number` | Devuelve el último valor de ira **sin recalcular**. |
| `DirectorMonitor:reportEvent(eventName: string)` | `void` | Informa que un evento ha ocurrido (resetea el contador de tiempo sin eventos). |
| `DirectorMonitor:onKill(killer: Player?, victim: Player)` | `void` | Debe llamarse cuando ocurre una muerte. Actualiza métricas y recalcula ira. |
| `DirectorMonitor:onCypherUsed(player: Player)` | `void` | Debe llamarse cuando un jugador usa una habilidad/poder. |
| `DirectorMonitor:onDuelStart(player: Player)` | `void` | Debe llamarse al iniciar un duelo. |
| `DirectorMonitor:onDuelEnd(player: Player)` | `void` | Debe llamarse al finalizar un duelo. |
| `DirectorMonitor:forceRecalculation()` | `void` | Fuerza una recalibración completa (útil para depuración). |

**Estructura de la tabla `metrics`:**
```lua
{
    totalPlayers = number,        -- Jugadores vivos
    averageHealth = number,       -- Salud media (0-100)
    timeSinceLastEvent = number,  -- Segundos desde el último evento
    topPlayer = Player?,          -- Jugador con más kills
    topPlayerKills = number,      -- Kills del top player
    topPlayerStreak = number,     -- Racha del top player
    globalKillRate = number,      -- Kills por minuto
    highestStreak = number,       -- Racha más alta de la partida
    totalActiveDuels = number,    -- Duelos en curso
    speciesCount = table,         -- Conteo por especie/equipo (opcional)
    dominantSpecies = string?,    -- Especie/equipo dominante
    dominanceRatio = number,      -- Proporción de la especie dominante (0-1)
    noobPlayers = {Player...},    -- Jugadores con pocas kills
}
```

---

## 🔹 DirectorDecider

Selecciona el próximo evento usando un algoritmo de ruleta ponderada.

| Método | Retorno | Descripción |
|--------|---------|-------------|
| `DirectorDecider:decide(metrics: table, anger: number)` | `string?` | Devuelve el nombre del evento seleccionado, o `nil` si no hay ninguno disponible. |

---

## 🔹 DirectorExecutor

Ejecuta la lógica de los eventos y los registra en la memoria.

| Método | Descripción |
|--------|-------------|
| `DirectorExecutor:execute(eventName: string)` | Ejecuta el evento especificado. Internamente usa `pcall` para evitar errores fatales. |

**Añadir un nuevo evento:**  
Consulta [`EVENTS.md`](EVENTS.md) para la guía completa.

---

## 🔹 DirectorMemory

Almacena el historial de eventos y proporciona utilidades para evitar repeticiones.

| Método | Retorno | Descripción |
|--------|---------|-------------|
| `DirectorMemory:remember(eventType: string, data: table?)` | `void` | Registra un evento en la memoria. |
| `DirectorMemory:hasHappenedRecentlySeconds(eventType: string, seconds: number)` | `boolean` | Verifica si el evento ocurrió en los últimos `seconds` segundos. |
| `DirectorMemory:isOnStreak(eventType: string, minCount: number)` | `boolean` | Devuelve `true` si el mismo evento se ha repetido al menos `minCount` veces seguidas. |
| `DirectorMemory:getEventCount(eventType: string)` | `number` | Número total de veces que ha ocurrido el evento. |
| `DirectorMemory:timeSinceLastEvent(eventType: string)` | `number` | Segundos desde la última ocurrencia del evento. |
| `DirectorMemory:shouldAvoidEvent(eventType: string, avoidSeconds: number)` | `boolean, string?` | Recomienda evitar el evento si ocurrió recientemente o está en racha. |
| `DirectorMemory:getStats()` | `table` | Devuelve estadísticas completas de la memoria. |
| `DirectorMemory:reset()` | `void` | Borra todo el historial (útil para reinicios de servidor). |

---

## 🔹 Dependencies (Stubs)

Estos módulos son opcionales. Los stubs incluidos simulan su funcionamiento.

| Módulo | Métodos principales |
|--------|---------------------|
| `RelicsManager` | `giveRelic(player, relicName, amount)`<br>`dropRandom(player, amount)` |
| `CypherManager` | `rotateAllPlayers()` |
| `CalendarService` | `punishDominant(player, kills)`<br>`rewardNoob(player, kills)` |
