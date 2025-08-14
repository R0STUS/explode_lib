## Features:
- Uses **rays**, allowing protection of objects from explosions (e.g., you can build a bunker).  
- Supports block durability.  
- Can push entities.  
- Recursive explosions.  
- Includes particles.  
- Includes sound.  

## How to use:

The `explode_lib` provides 2 methods:  
```lua
explode(cx, cy, cz, strength, checkBaseDurability, pushEntities, recursiveBlocks)
-- Standard method. Executes in a single tick.
explodeProcedural(cx, cy, cz, strength, checkBaseDurability, pushEntities, recursiveBlocks, spawnParticles, playSound)
-- Method that splits one large explosion into many smaller ones.
```

- `cx, cy, cz` – coordinates (numbers).  
- `strength` – explosion power (number).  
- `checkBaseDurability` – boolean. Whether to use the `"base:durability"` value as resistance to explosions.  
- `pushEntities` – boolean. Whether to push entities.  
- `recursiveBlocks` – hash table. List of blocks that trigger a recursive explosion when destroyed.  
- `spawnParticles` – boolean. Whether to spawn particles.  
- `playSound` – boolean. Whether to play sound.  

### Additional API info:

To define a custom block durability table, create a configuration file in the root directory of any content pack named `resistance_list.properties`. Example:  
```properties
base:glass=1
rsttm:black_metal=10
```

To pass a list of blocks that trigger recursive explosions, provide a hash table as the 7th argument. Each element in this table must be a sub-table with parameters. Format:  
```lua
t = {}
t["yourmod:block_name"] = {strength, checkBaseDurability, pushEntities, recursiveBlocksList, explodeType, spawnParticles, playSound}
```

- `recursiveBlocksList` – hash table.  
  You can also pass the string `"cpy"` to reuse a previously provided recursive block table.  
- `explodeType` – string, corresponding to the explosion method (`"explode"` or `"explodeProcedural"`).
