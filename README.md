# Integrantes del grupo 11
- Nombre: David Pérez. 
  Legajo: 125.012-7
  Mail: davidperez@est.frba.utn.edu.ar 
  Github: davidosvaldoperez

- Nombre: Norman Perrin. 
  Legajo: 147.215-0
  Mail: norman.perrin.94@gmail.com
  Github: normanperrin

- Nombre: Nicolás Taboada
  Legajo: 143.938-8
  Mail: ntaboada93@gmail.com
  Github: ntaboada

- Nombre: Pablo Scalora
  Legajo: 102.425-5
  Mail: pscalora@est.frba.utn.edu.ar
  Github: KpdsK

## TODOS
* Hacer que `search_by_id` devuelva `obj` o `nil`
* Sobreescribir eq de objetos para q compare por todos los campos (?)
* Implementar `forget` (es como un `delete`)
* Implementar `delete` en `IntelligentDB` restricciones para mantener consistencia si un objeto haga referencia a otro.
* has_one tiene que verificar si hay un cambio de tipos de datos de atributo verificar en la BD si ya hay documentos persistidos con atributo de ese tipo, si ya hay tira excepción.
* Cuando se agrega un campo nuevo tiene que actualizar todos los documentos agregando ese campo por default en la BD
* Los `Booleans` se guardan como `Strings`, campo default es `‘maybe’`
* Implementar mapeo hashes a objeto igual que bucle `save!`

## Pendientes a responder
* Parece que no anda muy bien la herencia entre clasese, se debería verificar cómo tratar la inclusión de módulos a subclases. Jode para la 3er entrega.
