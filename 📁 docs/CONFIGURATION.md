# ⚙️ Guía de Configuración - AI Director System

Este documento explica todas las constantes y parámetros que puedes ajustar para personalizar el comportamiento del Director.

---

## 📁 Archivos de Configuración

La configuración se encuentra distribuida en los siguientes archivos:

| Archivo | Contenido Configurable |
|---------|------------------------|
| `DirectorMemory.lua` | Duración de memoria, tamaño máximo de historial, días especiales. |
| `DirectorMonitor.lua` | Pesos de los factores de ira, límites de métricas. |
| `DirectorDecider.lua` | Cooldowns de eventos, tabla de eventos disponibles. |
| `DirectorController.lua` | Intervalo de decisión por defecto. |

---

## 🧠 DirectorMemory.lua

### Duración de la Memoria

```lua
local MEMORY_DURATION = 3600  -- 1 hora en segundos
```
Define cuánto tiempo permanece un evento en la memoria antes de ser eliminado automáticamente.  
**Valor recomendado:** Entre 1800 (30 min) y 7200 (2 horas).

### Tamaño Máximo del Historial

```lua
local MAX_HISTORY = 200
```
Número máximo de entradas que se almacenan en memoria. Cuando se supera, se eliminan las más antiguas.  
**Valor recomendado:** 100-500 según la frecuencia de eventos.

### Días Especiales (Opcional)

Si decides implementar días temáticos, puedes configurarlos en la tabla `DAY_EFFECTS`:

```lua
local DAY_EFFECTS = {
    [0] = { name = "Domingo", chaosMultiplier = 1.0 },
    [1] = { name = "Lunes",   chaosMultiplier = 1.0 },
    -- ... añade multiplicadores diferentes para cada día
}
```
- `chaosMultiplier`: Multiplica el nivel de ira final. Útil para días "intensos" (ej: fin de semana x1.5).

---

## 📊 DirectorMonitor.lua

### Pesos de los Factores de Ira

Cada factor contribuye al cálculo de la ira. Puedes ajustar su peso máximo en la tabla `ANGER_CONFIG`:

```lua
local ANGER_CONFIG = {
    HEALTH_FACTOR_MAX      = 50,   -- Salud media baja
    TIME_FACTOR_MAX        = 50,   -- Tiempo sin eventos
    DOMINANCE_FACTOR_MAX   = 60,   -- Dominancia de un equipo/especie
    BOREDOM_FACTOR_MAX     = 30,   -- Pocos jugadores activos
    KILL_RATE_FACTOR_MAX   = 40,   -- Tasa de muertes alta
    CYPHER_USAGE_FACTOR_MAX = 30,  -- Uso excesivo de habilidades
    STREAK_FACTOR_MAX      = 35,   -- Rachas altas de jugadores
    DUEL_FACTOR_MAX        = 25,   -- Duelos activos
}
```

**Cómo ajustar:**
- Aumenta el valor si quieres que ese factor tenga más impacto en la decisión del Director.
- Ponlo a `0` si quieres desactivar completamente ese factor.

### Límites para Cálculo de Factores

Dentro de `calculateAnger()` encontrarás umbrales que puedes modificar:

```lua
-- Factor de tiempo sin eventos (máximo a los 5 minutos)
local timeFactor = (timeSinceLast / 300) * ANGER_CONFIG.TIME_FACTOR_MAX

-- Factor de kill rate (máximo a 10 kills/minuto)
killRateFactor = math.min(metrics.globalKillRate / 10, 1) * ANGER_CONFIG.KILL_RATE_FACTOR_MAX

-- Factor de rachas
if metrics.highestStreak >= 10 then
    streakFactor = ANGER_CONFIG.STREAK_FACTOR_MAX
elseif metrics.highestStreak >= 5 then
    streakFactor = ANGER_CONFIG.STREAK_FACTOR_MAX * 0.6
end
```

**Ejemplo de ajuste:**
- Si quieres que el Director reaccione antes a las rachas, cambia `>= 10` por `>= 7`.
- Si quieres que el kill rate máximo se alcance con 20 kills/min, cambia `/ 10` por `/ 20`.

---

## 🎲 DirectorDecider.lua

### Cooldowns de Eventos

Cada evento puede tener un tiempo de enfriamiento personalizado:

```lua
local EVENT_COOLDOWNS = {
    DefaultEvent       = 120,   -- 2 minutos
    MiEventoPersonalizado = 180, -- 3 minutos
}
```
- El valor está en **segundos**.
- Si un evento no está en la tabla, usa el valor por defecto (`60` segundos).

### Umbral de Repetición (shouldAvoid)

La función `shouldAvoid()` evita que un evento se repita si:

```lua
-- Ha ocurrido en los últimos 45 segundos
if DirectorMemory:hasHappenedRecentlySeconds(eventName, 45) then return true end

-- Se ha repetido 2 o más veces seguidas
if DirectorMemory:isOnStreak(eventName, 2) then return true end
```

Puedes ajustar estos valores directamente en el código:
- Cambia `45` por otro número de segundos.
- Cambia `2` por el número de repeticiones permitidas en racha.

### Tabla de Eventos (EVENT_OPTIONS)

Aquí defines qué eventos existen y sus condiciones. Cada entrada tiene:

```lua
{
    name = "NombreDelEvento",
    condition = function(metrics, anger)
        -- Retorna un score numérico (0 = no disponible)
    end
}
```

**Consejos para balancear scores:**
- Los scores típicos van de `10` a `200`.
- Usa `anger` como multiplicador para que eventos más agresivos aparezcan con ira alta.
- Usa métricas específicas (`globalKillRate`, `averageHealth`) para condicionar la disponibilidad.

---

## 🎮 DirectorController.lua

### Intervalo de Decisión

```lua
local DEFAULT_INTERVAL = 25  -- Segundos entre decisiones
```

Puedes cambiarlo al iniciar el controlador:

```lua
DirectorController:start(20)  -- Decide cada 20 segundos
```

**Recomendaciones:**
- Partidas rápidas (Battle Royale): `15-25` segundos.
- Partidas lentas (Supervivencia): `30-45` segundos.
- No bajes de `10` segundos para evitar saturar el sistema.

---

## 🔌 Dependencies (Stubs)

Los stubs incluidos en `Dependencies/` son módulos falsos que simulan la funcionalidad de sistemas externos. Puedes:

1. **Usarlos tal cual**: El Director funcionará pero no aplicará efectos reales de recompensas o habilidades.
2. **Reemplazarlos**: Sustituye el archivo por tu propia implementación con los mismos métodos públicos.
3. **Modificarlos**: Añade lógica real dentro de los stubs existentes.

### RelicsManager.lua

```lua
function RelicsManager:giveRelic(player, relicName, amount)
    -- Aquí tu lógica para dar objetos al jugador
end
```

### CypherManager.lua

```lua
function CypherManager:rotateAllPlayers()
    -- Aquí tu lógica para cambiar habilidades de todos
end
```

### CalendarService.lua

```lua
function CalendarService:punishDominant(player, kills)
    -- Penalización al jugador dominante
end

function CalendarService:rewardNoob(player, kills)
    -- Recompensa al jugador novato
end
```

---

## 📈 Ejemplo de Configuración Completa

### Escenario: "Director Agresivo"

```lua
-- DirectorMonitor.lua
local ANGER_CONFIG = {
    HEALTH_FACTOR_MAX      = 70,   -- Más sensible a salud baja
    TIME_FACTOR_MAX        = 60,   -- Se impacienta más rápido
    KILL_RATE_FACTOR_MAX   = 50,   -- Reacciona fuerte a masacres
    STREAK_FACTOR_MAX      = 50,   -- Castiga rachas altas
    -- ... resto igual
}

-- DirectorDecider.lua
local EVENT_COOLDOWNS = {
    DefaultEvent = 90,  -- Enfriamientos más cortos
}

-- DirectorController.lua
DirectorController:start(15)  -- Decide muy frecuentemente
```

### Escenario: "Director Relajado"

```lua
-- DirectorMonitor.lua
local ANGER_CONFIG = {
    HEALTH_FACTOR_MAX      = 30,
    TIME_FACTOR_MAX        = 30,
    KILL_RATE_FACTOR_MAX   = 20,
    STREAK_FACTOR_MAX      = 20,
    -- ... resto igual
}

-- DirectorDecider.lua
local EVENT_COOLDOWNS = {
    DefaultEvent = 180,  -- Enfriamientos largos
}

-- DirectorController.lua
DirectorController:start(40)  -- Decide con pausa
```

---

## 🧪 Depuración

Para ver el impacto de tus cambios, activa los `print()` de depuración en:

- `DirectorDecider:decide()`: Muestra el evento elegido y su score.
- `DirectorMonitor:calculateAnger()`: Descomenta el print al final para ver el desglose de factores.

```lua
print(string.format("📊 Anger: %.1f | health=%.1f time=%.1f kills=%.1f streak=%.1f", 
    state.angerLevel, healthFactor, timeFactor, killRateFactor, streakFactor))
```

---
