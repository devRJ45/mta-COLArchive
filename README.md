# COLArchive
Implementacja plików .col do MTA.
Standardowa funkcja `engineLoadCOL` ładuje tylko pierwszy plik z archiwum i ignoruje resztę.

```lua
COLArchive(path) -- konstruktor przyjmuje ścieżkę do pliku jako pierwszy argument
COLArchive:getNames() -- zwraca nazwy plików col z archiwum
COLArchive:getFile(name) -- zwraca plik col o podanej nazwie
COLArchive:destroy() -- zamyka plik archiwum
```
Przykład użycia:
```lua
local colarchive = COLArchive('airportN.col');
local col = engineLoadCOL(colarchive:getFile('mc_assaultcourse1'))
engineReplaceCOL(col, 3664);
colarchive:destroy();
```
