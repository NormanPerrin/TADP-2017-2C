package ar.edu.tadp.quest

import scala.util.{Try, Success, Failure}

object Quest {

  case class Heroe(
    trabajo: Trabajo,
    inventario: Inventario = Inventario(),
    hp_base: Int = 100,
    fuerza_base: Int = 10,
    velocidad_base: Int = 10,
    inteligencia_base: Int = 10
	) {
    // getters
    def hp(): Int = hp_base + trabajo.hp + inventario.hp
    def fuerza(): Int = fuerza_base + trabajo.fuerza
    def velocidad(): Int = velocidad_base + trabajo.velocidad
    def inteligencia(): Int = inteligencia_base + trabajo.inteligencia
    
    def statPpal(): String = trabajo.statPpal.nombre
    
    def equipar(item: Item): Heroe = copy(inventario = inventario.equipar(item, this))
  }
  
  abstract class Stat(
    val nombre: String,
    val aplicar: (Heroe => Int)
  )
  
  case object Fuerza extends Stat("fuerza", (h: Heroe) => h.fuerza)
  case object Inteligencia extends Stat("inteligencia", (h: Heroe) => h.inteligencia)
  case object Velocidad extends Stat("velocidad", (h: Heroe) => h.velocidad)
  case object Vida extends Stat("vida", (h: Heroe) => h.hp)
  
  abstract class Trabajo(
    val statPpal: Stat,
    val hp: Int,
    val fuerza: Int,
    val velocidad: Int,
    val inteligencia: Int
  )
  
  case object Guerrero extends Trabajo(Fuerza, 10, 15, 0, -10)
  case object Mago extends Trabajo(Inteligencia, 0, -20, 0, 20)
  case object Ladron extends Trabajo(Velocidad, -5, 0, 10, 0)

  case class Inventario(
    talismanes: List[Item] = List(),
    manoIzq: Item = Item("manoIzq"),
    manoDer: Item = Item("manoDer"),
    cabeza: Item = Item("cabeza"),
    torso: Item = Item("torso")
	) {
    def equipar(item: Item, heroe: Heroe): Inventario = {
      item.parte match {
        // TODO: falta logica asignacion        
        case "talisman" => this.copy(talismanes = item :: talismanes)
        case "manoIzq" => {
          if (item.condiciones.forall(cond => cond(heroe))) return this.copy(manoIzq = item)
          return this
        }
        case "manoDer" => this.copy(manoDer = item)
        case "cabeza" => this.copy(cabeza = item)
        case "torso" => this.copy(torso = item)
        case "dosManos" => this.copy(manoIzq = item, manoDer = item)
      }
    }
    // TODO: agregar funcion para mapear segun atributo
    def hp(): Int = talismanes.map(_.hp).sum + manoIzq.hp // TODO sigue
  }

  case class Item(
    parte: String,
    condiciones: List[Heroe => Boolean] = List(),
    // TODO: los tipos de partes podrian ser WKO 
		hp: Int = 0,
		fuerza: Int = 0,
		velocidad: Int = 0,
		inteligencia: Int = 0
	) {}
  
  case class Equipo(
    heroes: List[Heroe],
    nombre: String,
    pozo: Int
  ) {
    def agregarHeroe(heroe: Heroe): Equipo = copy(heroes = heroe :: heroes )
//    def realizarMision(Mision): Try(Equipo) = 
//    def mejorHeroeSegun(criterio: Heroe => Int): Optional(Heroe) = heroes.sort(criterio).head
//    def lider(): Optional(Heroe)
//    def agregarRecompensa(Recomensa): Equipo = 
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
//    def hacer(equipo: Equipo): Try[Equipo]
  }

}