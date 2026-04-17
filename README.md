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
