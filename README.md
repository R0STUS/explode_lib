## Features:
- Uses **rays**, allowing protection of objects from explosions (e.g., you can build a bunker).  
- Supports block blast resistance.
- Can push entities.  
- Recursive explosions.  
- Includes particles.  
- Includes sound.  

## How to use:

The `explode_lib` provides 2 methods:  
```lua
explode(pos, options)
-- Standard method. Executes in a single tick.
explodeProcedural(pos, options)
-- Method that splits one large explosion into many smaller ones.
```

- `pos` – coordinates (table with 3 numbers).
- `options` – explosion options. (hash table).
- `options.strength` – explosion power (number).
- `options.pushEntities` – boolean. Whether to push entities.  
- `options.recursiveBlocks` – hash table. List of blocks that trigger a recursive explosion when destroyed.  
- `options.spawnParticles` – boolean. Whether to spawn particles.  
- `options.playSound` – boolean. Whether to play sound.  

### Additional API info:

To define a custom block durability table, create a configuration file in the root directory of any content pack named `resistance_list.properties`. Example:  
```properties
base:glass=1
rsttm:black_metal=10
```
You can also override it in block properties, like this:
```json
{
    ...
    "explode_lib:blast_resistance": 10.0,
    ...
}
```

To pass a list of blocks that trigger recursive explosions, provide a hash table as the 7th argument. Each element in this table must be a sub-table with parameters. Format:  
```lua
t = {}
t["yourmod:block_name"] = {
    strength = 10,
    pushEntities = true,
    recursiveBlocks = "cpy",
    func = explode,
    spawnParticles = true,
    playSound = true
}
```

- `recursiveBlocks` – hash table.  
  You can also pass the string `"cpy"` to reuse a previously provided recursive block table.  
- `func` – function pointer that will be called when the block is hit by a ray.
