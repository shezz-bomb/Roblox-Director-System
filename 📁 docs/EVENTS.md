# 🎮 Guía de Eventos - AI Director System

Esta guía explica cómo crear, configurar y personalizar eventos para el Director.

---

## 📌 Estructura de un Evento

Un evento se compone de dos partes:

| Parte | Ubicación | Responsabilidad |
|-------|-----------|-----------------|
| **Condición** | `DirectorDecider.lua` | Determina cuándo está disponible y con qué peso se elige. |
| **Ejecución** | `DirectorExecutor.lua` | Contiene la lógica que se ejecuta al activarse. |

---

## ➕ Añadir un Nuevo Evento

### Paso 1: Definir la Condición

Abre `DirectorDecider.lua` y localiza la tabla `EVENT_OPTIONS`. Añade una nueva entrada:

```lua
{
    name = "MiEventoPersonalizado",
    condition = function(metrics, anger)
        -- 1. Verificar cooldown y repeticiones
        if onCooldown("MiEventoPersonalizado") or shouldAvoid("MiEventoPersonalizado") then
            return 0
        end
        
        -- 2. Condiciones específicas (opcional)
        if metrics.totalPlayers < 2 then
            return 0  -- No disponible con menos de 2 jugadores
        end
        
        -- 3. Calcular score base
        local score = 10
        
        -- 4. Añadir bonificadores según métricas
        score = score + anger * 0.5
        score = score + metrics.globalKillRate * 2
        score = score + (metrics.topPlayerKills or 0) * 3
        
        return score
    end
}
```

### Paso 2: Definir el Cooldown (Opcional)

En el mismo archivo, añade el cooldown en la tabla `EVENT_COOLDOWNS`:

```lua
local EVENT_COOLDOWNS = {
    -- ... otros eventos ...
    MiEventoPersonalizado = 120,  -- 2 minutos
}
```

### Paso 3: Crear la Función de Ejecución

Abre `DirectorExecutor.lua` y añade un nuevo método:

```lua
function DirectorExecutor:miEventoPersonalizado()
    broadcast("🔥 ¡Mi evento personalizado se ha activado!", 6)
    
    -- Ejemplo: Duplicar el daño de todos durante 15 segundos
    for _, player in ipairs(Players:GetPlayers()) do
        player:SetAttribute("DamageMultiplier", 2.0)
        
        task.delay(15, function()
            if player and player.Parent then
                player:SetAttribute("DamageMultiplier", nil)
            end
        end)
    end
    
    -- Ejemplo: Efecto visual temporal
    local effect = Instance.new("Part")
    effect.Size = Vector3.new(10, 10, 10)
    effect.Position = Vector3.new(0, 50, 0)
    effect.Anchored = true
    effect.CanCollide = false
    effect.Material = Enum.Material.Neon
    effect.BrickColor = BrickColor.new("Bright red")
    effect.Parent = workspace
    
    task.delay(15, function() effect:Destroy() end)
end
```

### Paso 4: Registrar en el Dispatch

En el método `execute()` de `DirectorExecutor.lua`, añade la nueva rama:

```lua
function DirectorExecutor:execute(eventName)
    -- ...
    local ok, err = pcall(function()
        if eventName == "DefaultEvent" then self:defaultEvent()
        -- ... otros eventos ...
        elseif eventName == "MiEventoPersonalizado" then self:miEventoPersonalizado()
        else
            warn("Evento desconocido:", eventName)
        end
    end)
    -- ...
end
```

---

## 📊 Variables Disponibles en `condition()`

La función `condition(metrics, anger)` recibe dos parámetros:

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `metrics` | `table` | Métricas actuales de la partida (ver [API.md](API.md#-directormonitor)). |
| `anger` | `number` | Nivel de ira actual (0-100). |

**Funciones auxiliares disponibles dentro de `condition()`:**

| Función | Descripción |
|---------|-------------|
| `onCooldown(eventName)` | Retorna `true` si el evento está en enfriamiento. |
| `shouldAvoid(eventName)` | Retorna `true` si ocurrió hace menos de 45 segundos o está en racha (≥2 repeticiones). |
| `getMetric(metrics, key, default)` | Obtiene un valor de `metrics` de forma segura, con fallback si no existe. |

---

## 🧪 Ejemplos de Condiciones Comunes

### Evento basado en salud baja

```lua
condition = function(metrics, anger)
    if onCooldown("LowHealthEvent") then return 0 end
    if metrics.averageHealth > 40 then return 0 end  -- Solo si salud < 40%
    return (100 - metrics.averageHealth) * 1.5 + anger * 0.3
end
```

### Evento basado en rachas altas

```lua
condition = function(metrics, anger)
    if onCooldown("StreakPunishment") then return 0 end
    if metrics.highestStreak < 5 then return 0 end  -- Solo si alguien tiene racha ≥5
    return metrics.highestStreak * 10 + anger * 0.5
end
```

### Evento basado en inactividad

```lua
condition = function(metrics, anger)
    if onCooldown("BoredomEvent") then return 0 end
    if metrics.timeSinceLastEvent < 120 then return 0 end  -- Solo si han pasado ≥2 minutos
    return (metrics.timeSinceLastEvent / 10) + anger * 0.4
end
```

### Evento basado en kill rate alto

```lua
condition = function(metrics, anger)
    if onCooldown("HighKillRateEvent") then return 0 end
    if metrics.globalKillRate < 5 then return 0 end  -- Solo si >5 kills/min
    return metrics.globalKillRate * 8 + anger * 0.6
end
```

---

## 🎯 Buenas Prácticas

| Recomendación | Descripción |
|---------------|-------------|
| **Siempre verificar cooldown** | Usa `onCooldown()` al inicio de cada condición. |
| **Usar `shouldAvoid()`** | Evita que el mismo evento se repita demasiado seguido. |
| **Retornar `0` cuando no esté disponible** | No retornes `nil` o `false`. Usa `0` para que no sea elegido. |
| **Mantener scores balanceados** | Los scores típicos van de 10 a 200. Evita valores extremos que dominen la ruleta. |
| **Usar `pcall` en efectos complejos** | Si tu evento usa servicios externos, envuélvelos en `pcall` para evitar errores fatales. |
| **Limpiar efectos temporales** | Usa `task.delay()` para restaurar atributos o eliminar partes visuales. |

---

## 🔄 Eventos Compuestos (Fases)

Para eventos que requieren varias fases, puedes usar el siguiente patrón:

```lua
-- En DirectorExecutor.lua
local activePhasedEvent = nil

function DirectorExecutor:miEventoPorFases()
    broadcast("🌑 Fase 1: El evento comienza...", 5)
    
    -- Fase 1
    activePhasedEvent = {
        phase = 1,
        startTime = tick(),
        duration = 30
    }
    
    -- Programar Fase 2
    task.delay(30, function()
        if activePhasedEvent then
            activePhasedEvent.phase = 2
            broadcast("🌓 Fase 2: La intensidad aumenta!", 5)
            -- Lógica de la fase 2...
        end
    end)
    
    -- Programar fin
    task.delay(60, function()
        if activePhasedEvent then
            broadcast("🌕 El evento ha terminado.", 4)
            activePhasedEvent = nil
        end
    end)
end
```

---

## 📦 Eventos de Ejemplo Incluidos

El sistema incluye un evento de demostración `DefaultEvent` que cura ligeramente a todos los jugadores. Puedes usarlo como plantilla para crear los tuyos.

```lua
function DirectorExecutor:defaultEvent()
    broadcast("✨ Evento por defecto activado.", 5)
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = math.min(hum.MaxHealth, hum.Health + 20)
            end
        end
    end
end
```

---
