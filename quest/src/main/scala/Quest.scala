package ar.edu.tadp.quest

import scala.util.{Try, Success, Failure}

object Quest {

  case class Heroe(
    inventario: Inventario,
    trabajo: Trabajo,
    hp_base: Int,
    fuerza_base: Int,
    velocidad_base: Int,
    inteligencia_base: Int
	) {
    // getters
    def hp(): Int = hp_base + trabajo.hp + inventario.hp
    def fuerza(): Int = fuerza_base + trabajo.fuerza
    def velocidad(): Int = velocidad_base + trabajo.velocidad
    def inteligencia(): Int = inteligencia_base + trabajo.inteligencia
    // TODO: agregar setters
    
    def equipar(item: Item): Heroe = copy(inventario = inventario.equipar(item))
  }
  
  abstract class Trabajo(
    val statPpal: (Heroe => Int),
    val hp: Int,
    val fuerza: Int,
    val velocidad: Int,
    val inteligencia: Int
  )
  
  case object Guerrero extends Trabajo((h: Heroe) => h.fuerza, 10, 15, 0, -10)
  case object Mago extends Trabajo((h: Heroe) => h.inteligencia, 0, -20, 0, 20)
  case object Ladron extends Trabajo((h: Heroe) => h.velocidad, -5, 0, 10, 0)

  case class Inventario(
    talismanes: List[Item],
    manoIzq: Item,
    manoDer: Item,
    cabeza: Item,
    torso: Item
	) {
    def equipar(item: Item): Inventario = {
      item.parte match {
        // TODO: falta logica asignacion        
        case "talisman" => this.copy(talismanes = item :: talismanes)
        case "manoIzq" => this.copy(manoIzq = item)
        case "manoDer" => this.copy(manoDer = item)
        case "cabeza" => this.copy(cabeza = item)
        case "torso" => this.copy(torso = item)
        case "dosManos" => this.copy(manoIzq = item, manoDer = item)
      }
    }
    
    def hp(): Int = talismanes.map(_.hp).sum + manoIzq.hp // TODO sigue
  }

  case class Item(
    condiciones: List[Heroe => Boolean],
    // TODO: los tipos de partes podrian ser WKO    
    parte: String,
		hp: Int,
		fuerza: Int,
		velocidad: Int,
		inteligencia: Int
	) {}
  
  case class Equipo(
    heroes: List[Heroe],
    nombre: String,
    pozo: Int
  ) {
    def agregarHeroe(heroe: Heroe): Equipo = copy(heroes = heroe :: heroes )
//    def realizarMision(Mision): Try(Equipo) = 
//    def mejorHeroeSegun(f: Heroe => Int): Optional(Heroe) = heroes.
  }
  
  case class Mision(
    tareas: List[Tarea],
    nombre: String,
    recompensa: Equipo => Equipo
  ) {
//    def serRealizadaPor(equipo: Equipo): Try[Equipo] = {
//      var equipoBaqueta = tareas.fold(Success(equipo): Try[Equipo])(tareaNueva) {tareaNueva.hacer)}
//      equipoBaqueta match {
//        case Success(equipo) => recompensa(equipo)
//        case Failure(err) => equipo
//      }
  }
  
  case class Tarea(
    nombre: String,
    efecto: Heroe => Heroe,
    facilidad: Heroe => Int
  ) {
//    private def facilidad(): Int
//    def hacer(equipo: Equipo): Try[Equipo] = 
  }

}