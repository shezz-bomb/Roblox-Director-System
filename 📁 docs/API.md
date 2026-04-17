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
