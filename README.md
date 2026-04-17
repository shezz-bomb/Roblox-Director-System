# 🎮 Roblox AI Director System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Roblox](https://img.shields.io/badge/Roblox-Studio-red)](https://www.roblox.com/create)
[![Luau](https://img.shields.io/badge/Language-Luau-blue)](https://luau-lang.org/)

> *Un sistema de Director controlado por IA para gestionar el ritmo de partida y lanzar eventos dinámicos en tiempo real.*

**Roblox AI Director System** es un framework modular diseñado para juegos multijugador que requieren un control dinámico de la dificultad y la narrativa.  
Inspirado en sistemas como el *AI Director* de Left 4 Dead, este módulo analiza constantemente el estado de la partida y decide qué eventos lanzar para mantener la experiencia siempre desafiante y variada.

---

## ✨ Características Principales

| Característica | Descripción |
|----------------|-------------|
| 🎲 **Selección Ponderada de Eventos** | Utiliza un algoritmo de ruleta basado en scores calculados a partir de métricas en tiempo real. |
| 📊 **Cálculo de "Ira" Multifactorial** | Evalúa la salud media, tasa de muertes, rachas de jugadores, uso de habilidades y más para determinar la intensidad. |
| 🧠 **Memoria de Eventos** | Evita la repetición de eventos recientes, detecta rachas y permite definir cooldowns personalizados. |
| 🔌 **Arquitectura Desacoplada** | Módulos independientes (`Memory`, `Monitor`, `Decider`, `Executor`, `Controller`) fáciles de extender o reemplazar. |
| ⚡ **Ejecución Segura** | Cada evento se ejecuta dentro de un entorno protegido (`pcall`) para evitar fallos en cascada. |
| 🛠️ **Altamente Configurable** | Cooldowns, pesos de factores de ira y eventos completamente personalizables mediante tablas. |

---

## 🚀 Instalación Rápida

1. **Clona** este repositorio o descarga el ZIP.
2. **Copia** la carpeta `src/ServerScriptService/DirectorSystem` dentro de `ServerScriptService` en tu lugar de Roblox.
3. **Copia** también la carpeta `src/ServerScriptService/Dependencies` (contiene stubs para que el sistema funcione sin dependencias externas).
4. **Crea** un `Script` en `ServerScriptService` con el siguiente contenido:

```lua
local DirectorController = require(game.ServerScriptService.DirectorSystem.DirectorController)
DirectorController:start(30) -- Evalúa eventos cada 30 segundos

Ejecuta el juego. El Director comenzará a observar y lanzar eventos automáticamente.

📚 Documentación
Archivo	Contenido
API.md	Referencia completa de métodos públicos de cada módulo.
EVENTS.md	Guía para crear y personalizar eventos.
CONFIGURATION.md	Explicación de todas las constantes configurables (cooldowns, factores de ira, etc.).
🧩 Dependencias Externas (Opcionales)
El sistema está preparado para integrarse con tus propios managers de juego. Si no existen, los stubs en la carpeta Dependencies/ simularán su funcionamiento (solo imprimirán mensajes en la consola).

Módulo Stub	Propósito	¿Obligatorio?
RelicsManager	Otorgar recompensas o recursos a jugadores	No
CypherManager	Gestionar habilidades o poderes de jugadores	No
CalendarService	Aplicar penalizaciones o recompensas basadas en desempeño	No
Puedes reemplazar cualquiera de estos stubs por tu propia implementación en cualquier momento.

🎮 Eventos de Ejemplo Incluidos
El sistema incluye varios eventos de demostración que puedes usar como base para crear los tuyos:

Evento	Descripción
DefaultEvent	Evento básico que cura ligeramente a todos los jugadores.
(Personalizados)	El código está preparado para añadir eventos como meteoros, cambios de gravedad, bloqueo de habilidades, recompensas sobre jugadores destacados, etc. Consulta EVENTS.md para ejemplos completos.
🧠 ¿Cómo Funciona?
1. Monitor
Recopila métricas de todos los jugadores: salud media, kills, rachas, tasa de muertes por minuto, etc.

2. Cálculo de Ira
Combina múltiples factores ponderados para obtener un valor entre 0 y 100 que representa la "presión" que debe aplicar el Director.

Factor	Peso Máximo
Salud media baja	50
Tiempo sin eventos	50
Tasa de muertes alta	40
Rachas altas de jugadores	35
Uso excesivo de habilidades	30
Pocos jugadores activos	30
Duelos activos	25
Dominancia de un equipo/especie	60
(Todos los pesos son configurables en DirectorMonitor.lua)

3. Decider
Evalúa todos los eventos disponibles. Cada evento tiene una función condition(metrics, anger) que devuelve un score.
El Director selecciona uno mediante un algoritmo de ruleta ponderada.

4. Executor
Ejecuta la lógica del evento elegido y registra la ocurrencia en la memoria.

5. Memory
Almacena el historial de eventos, evita repeticiones cercanas y puede aplicar lógica adicional (como días especiales con multiplicadores).

🛠️ Personalización
Añadir un Nuevo Evento
En DirectorDecider.lua, añade una entrada a la tabla EVENT_OPTIONS:

lua
{
    name = "MiEvento",
    condition = function(metrics, anger)
        -- Solo disponible si la ira > 40 y hay al menos 3 jugadores
        if anger < 40 or metrics.totalPlayers < 3 then return 0 end
        return anger * 1.2 + metrics.globalKillRate * 5
    end
}
En DirectorExecutor.lua, crea la función que ejecutará el evento:

lua
function DirectorExecutor:miEvento()
    -- Tu lógica aquí (efectos visuales, cambios en jugadores, etc.)
end
En el método execute() de DirectorExecutor.lua, añade la nueva rama:

lua
elseif eventName == "MiEvento" then self:miEvento()
Ajustar Cooldowns
Modifica la tabla EVENT_COOLDOWNS en DirectorDecider.lua:

lua
local EVENT_COOLDOWNS = {
    MiEvento = 180, -- 3 minutos de enfriamiento
}
📦 Lugar de Ejemplo
En la carpeta example/ encontrarás un archivo ExamplePlace.rbxl con el sistema ya integrado y funcionando.
Ábrelo en Roblox Studio para verlo en acción y usarlo como referencia.

🤝 Contribuciones
¿Encontraste un bug o tienes una mejora?
Abre un Issue o envía un Pull Request. Toda ayuda es bienvenida.

📜 Licencia
Este proyecto está bajo la licencia MIT.
Eres libre de usarlo, modificarlo y distribuirlo en proyectos personales o comerciales.

Creado con ⚙️ por [ @shezz-bomb]
