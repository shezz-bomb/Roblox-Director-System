
## 📁 Estructura de Carpetas del Repositorio

```
MEAT-Director-System/
│
├── .gitignore
├── LICENSE
├── README.md
│
├── docs/
│   ├── API.md
│   ├── EVENTS.md
│   └── CONFIGURATION.md
│
├── src/
│   └── ServerScriptService/
│       ├── DirectorSystem/
│       │   ├── DirectorMemory.lua
│       │   ├── DirectorMonitor.lua
│       │   ├── DirectorDecider.lua
│       │   ├── DirectorExecutor.lua
│       │   └── DirectorController.lua
│       │
│       └── Dependencies/
│           ├── RelicsManager.lua      (stub para pruebas)
│           ├── CypherManager.lua      (stub para pruebas)
│           └── CalendarService.lua    (stub para pruebas)
│
├── example/
│   ├── ExamplePlace.rbxl
│   └── README.md
│
└── images/
    ├── banner.png
    └── diagram.png
```

---

## 📄 README.md

```markdown
# 🥩 MEAT Director System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Roblox](https://img.shields.io/badge/Roblox-Studio-red)](https://www.roblox.com/create)
[![Luau](https://img.shields.io/badge/Language-Luau-blue)](https://luau-lang.org/)

> *"El Director observa. La carne tiembla. El caos obedece."*

**MEAT Director** es un sistema de **AI Director** inspirado en *Left 4 Dead*, *Risk of Rain* y el horror cósmico lovecraftiano.  
Controla el ritmo de la partida, lanza eventos dinámicos y reacciona al estado del juego para mantener la experiencia siempre intensa e impredecible.

Diseñado originalmente para un Battle Royale con toques de horror corporal, el sistema es **modular y altamente configurable**.

---

## ✨ Características Principales

| Característica | Descripción |
|----------------|-------------|
| 🎲 **Selección Ponderada** | Elige el próximo evento usando un algoritmo de ruleta basado en scores dinámicos. |
| 📊 **Métrica de "Ira"** | Calculada a partir de **8 factores**: salud media, tiempo sin eventos, dominancia de especie, kill rate, uso de poderes, rachas, duelos activos y más. |
| 🧠 **Memoria Persistente** | Evita repetir eventos recientemente, detecta rachas y recuerda días temáticos (Martes de Carne, Sábado del Cifrado...). |
| 🌍 **Días Especiales** | Cada día de la semana real tiene un modificador de caos único. |
| ⚡ **Ejecución Robusta** | Cada evento se ejecuta en un entorno protegido (`pcall`) para evitar que un error detenga el sistema. |
| 🔌 **Arquitectura Modular** | `Memory`, `Monitor`, `Decider`, `Executor` y `Controller` completamente desacoplados. |

---

## 🚀 Instalación Rápida

1. **Descarga** este repositorio o clónalo:
   ```bash
   git clone https://github.com/shezz-bomb/MEAT-Framework
   ```

2. **Copia** la carpeta `src/ServerScriptService/DirectorSystem` dentro de `ServerScriptService` en tu juego de Roblox.

3. **Copia** la carpeta `src/ServerScriptService/Dependencies` en el mismo lugar (contiene stubs para que funcione sin modificaciones).

4. **Crea** un `Script` en `ServerScriptService` con el siguiente contenido:
   ```lua
   local DirectorController = require(game.ServerScriptService.DirectorSystem.DirectorController)
   DirectorController:start(30) -- Decide cada 30 segundos
   ```

5. **¡Listo!** El Director comenzará a observar tu partida.

---

## 📚 Documentación

| Archivo | Contenido |
|---------|-----------|
| [API.md](docs/API.md) | Referencia completa de métodos de cada módulo. |
| [EVENTS.md](docs/EVENTS.md) | Lista de eventos incluidos y guía para crear nuevos. |
| [CONFIGURATION.md](docs/CONFIGURATION.md) | Cómo ajustar cooldowns, factores de ira y días temáticos. |

---

## 🧩 Dependencias Externas

El sistema está diseñado para integrarse con tus propios managers. Si no existen, los **stubs** en `Dependencies/` se encargarán de que el sistema funcione sin errores (solo imprimirán logs en la consola).

| Módulo | Propósito | ¿Obligatorio? |
|--------|-----------|:-------------:|
| `RelicsManager` | Otorgar recompensas a los jugadores | ❌ No |
| `CypherManager` | Rotar poderes/habilidades | ❌ No |
| `CalendarService` | Penalizar/recompensar por desempeño | ❌ No |

Puedes reemplazar los stubs por tus propios módulos en cualquier momento.

---

## 🎮 Eventos Incluidos

| Evento | Efecto |
|--------|--------|
| `MeatMeteor` | Un meteorito de carne cae causando daño en área. |
| `CypherStorm` | Todos los jugadores reciben nuevos poderes. |
| `BountyOnTopPlayer` | Se pone precio a la cabeza del jugador con más kills. |
| `GravitalPatrol` | La gravedad aumenta drásticamente. |
| `ReverseGravity` | La gravedad se invierte por unos segundos. |
| `SilenceZone` | Los poderes quedan bloqueados temporalmente. |
| `MeatRain` | Caen reliquias del cielo para todos. |
| `CarnageRitual` | Todo el daño se duplica durante 30 segundos. |
| `HunterParty` | Todos los jugadores son marcados para cazar al top player. |

*Consulta [EVENTS.md](docs/EVENTS.md) para más detalles y cómo crear los tuyos.*

---

## 🧠 ¿Cómo Funciona el Cálculo de Ira?

La **Ira del Director** es un valor entre `0` y `100` que determina la agresividad del sistema. Se calcula a partir de:

| Factor | Peso Máximo | Descripción |
|--------|:-----------:|-------------|
| Salud Media Baja | 50 | A menos salud, más ira. |
| Tiempo sin Eventos | 50 | El aburrimiento enfurece al Director. |
| Dominancia de Especie | 60 | Si una especie supera el 60% del lobby. |
| Aburrimiento (pocos jugadores) | 30 | Menos de 3 jugadores = más ira. |
| Kill Rate Alto | 40 | Muchas muertes por minuto. |
| Uso de Poderes | 30 | Uso excesivo de habilidades. |
| Rachas Altas | 35 | Jugadores con streaks de kills elevadas. |
| Duelos Activos | 25 | Caos controlado. |

Además, el **día de la semana real** aplica un multiplicador global (ej: Martes de Carne = x3.0).

---

## 🖼️ Arquitectura del Sistema

```
┌─────────────────┐     ┌─────────────────┐
│  DirectorMonitor │ ──▶ │  DirectorDecider │
│  (Métricas/Ira)  │     │   (Selección)     │
└─────────────────┘     └────────┬────────┘
                                 │
                                 ▼
┌─────────────────┐     ┌─────────────────┐
│  DirectorMemory  │ ◀── │  DirectorExecutor │
│   (Historial)    │     │   (Ejecución)     │
└─────────────────┘     └─────────────────┘
```

- **Monitor**: Lee el estado del mundo.
- **Decider**: Elige el mejor evento.
- **Executor**: Lo ejecuta de forma segura.
- **Memory**: Registra para evitar repeticiones.

El **Controller** orquesta el ciclo cada `N` segundos.

---

## 🛠️ Personalización Rápida

### Añadir un Nuevo Evento

1. En `DirectorDecider.lua`, añade una entrada en `EVENT_OPTIONS`:
   ```lua
   {
       name = "MiEventoBrutal",
       condition = function(metrics, anger)
           if onCooldown("MiEventoBrutal") then return 0 end
           return anger * 0.8 + metrics.totalPlayers * 3
       end
   }
   ```

2. En `DirectorExecutor.lua`, añade la función de ejecución:
   ```lua
   function DirectorExecutor:miEventoBrutal()
       broadcast("💀 ¡MI EVENTO BRUTAL SE DESATA!", 6)
       -- Tu lógica aquí
   end
   ```

3. En el dispatch de `execute`, añade la rama:
   ```lua
   elseif eventName == "MiEventoBrutal" then self:miEventoBrutal()
   ```

---

## 📦 Ejemplo de Lugar

En la carpeta `example/` encontrarás un archivo `ExamplePlace.rbxl` con el sistema ya configurado y funcionando.  
Ábrelo en Roblox Studio y ejecuta para ver al Director en acción.

---

## 🤝 Contribuciones

¿Tienes ideas para nuevos eventos, mejoras en la lógica o quieres reportar un bug?  
Abre un **Issue** o envía un **Pull Request**.  
Toda contribución es bienvenida.

---

## 📜 Licencia

Este proyecto está bajo la licencia **MIT**.  
Eres libre de usarlo, modificarlo y distribuirlo, incluso en proyectos comerciales.

---

**Creado con 🥩 y ⚡ por [@shezz-bomb]**
```
