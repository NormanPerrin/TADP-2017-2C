package ar.edu.tadp.quest

import scala.util.{Try, Success, Failure}
 
// heroe
// trabajo
// items
// operaciones y validaciones

object Quest {

  case class Heroe(
    trabajo: Trabajo,
    inventario: Inventario = Inventario(),
    stats: Stats = Stats()
	) {
    // getters
    def hp(): Int = stats.hp + trabajo.stats.hp + inventario.hp
    def fuerza(): Int = stats.fuerza + trabajo.stats.fuerza
    def velocidad(): Int = stats.velocidad + trabajo.stats.velocidad
    def inteligencia(): Int = stats.inteligencia + trabajo.stats.inteligencia
    
    def statPpal(): String = trabajo.statPpal.nombre
    
    def equipar(item: Item): Heroe = copy(inventario = inventario.equipar(item, this))
  }
  
  abstract class StatPpal(
    val nombre: String,
    val aplicar: (Heroe => Int)
  )
  
  case class Stats(
    val hp: Int = 100,
    val fuerza: Int = 10,
    val velocidad: Int = 10,
    val inteligencia: Int = 10
  )
  
  case object Fuerza extends StatPpal("fuerza", (h: Heroe) => h.fuerza)
  case object Inteligencia extends StatPpal("inteligencia", (h: Heroe) => h.inteligencia)
  case object Velocidad extends StatPpal("velocidad", (h: Heroe) => h.velocidad)
  case object Vida extends StatPpal("vida", (h: Heroe) => h.hp)
  
  abstract class Trabajo(
    val statPpal: StatPpal,
    val stats: Stats
  )
  
  case object Guerrero extends Trabajo(Fuerza, Stats(10, 15, -10, 0))
  case object Mago extends Trabajo(Inteligencia, Stats(0, -20, 0, 20))
  case object Ladron extends Trabajo(Velocidad, Stats(-5, 0, 10, 0))

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
    def obtenerItems: List[Item] = List(manoIzq, manoDer, cabeza, torso) ++ talismanes
    def hp(): Int = obtenerItems.map(_.stats.hp).sum
    def fuerza(): Int = obtenerItems.map(_.stats.fuerza).sum
    def velocidad(): Int = obtenerItems.map(_.stats.velocidad).sum
    def inteligencia(): Int = obtenerItems.map(_.stats.inteligencia).sum
  }

  case class Item(
    parte: String,
    stats: Stats = Stats(0, 0, 0, 0),
    condiciones: List[Heroe => Boolean] = List()
    // TODO: los tipos de partes podrian ser WKO 
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