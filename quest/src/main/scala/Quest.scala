package ar.edu.tadp.quest

import scala.util.{Try, Success, Failure}
import scala.Option

object Quest {

  case class Item(
    parte: ParteCuerpo,
    stats: Stats = Stats(0, 0, 0, 0),
    condiciones: List[Heroe => Boolean] = List(),
    precio: Int = 0
	) {
    def puedeEquipar(heroe: Heroe): Boolean = condiciones.forall(cond => cond(heroe))
  }
  
  case class Heroe(
    trabajo: Trabajo,
    inventario: Inventario = Inventario(),
    stats: Stats = Stats()
	) {
    // getters
    def hp(): Int = stats.hp + trabajo.stats.hp + inventario.hp
    def fuerza(): Int = stats.fuerza + trabajo.stats.fuerza + inventario.fuerza
    def velocidad(): Int = stats.velocidad + trabajo.stats.velocidad + inventario.velocidad
    def inteligencia(): Int = stats.inteligencia + trabajo.stats.inteligencia + inventario.inteligencia

    def hp(_hp: Int): Heroe = copy(stats = Stats(_hp, stats.fuerza, stats.velocidad, stats.inteligencia))
    def fuerza(_fuerza: Int): Heroe = copy(stats = Stats(stats.hp, _fuerza, stats.velocidad, stats.inteligencia))
    def velocidad(_velocidad: Int): Heroe = copy(stats = Stats(stats.hp, stats.fuerza, _velocidad, stats.inteligencia))
    def inteligencia(_inteligencia: Int): Heroe = copy(stats = Stats(stats.hp, stats.fuerza, stats.velocidad, _inteligencia))
    def trabajo(_trabajo: Trabajo) = copy(trabajo = _trabajo)
    
    def statPpal(): StatPpal = trabajo.statPpal
    def valorStatPpal(): Int = trabajo.statPpal.aplicar(this)

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
  
//  TODO: agregar obtener stat con 2 manos
  case class Manos(
    manoDer: Option[Item] = None,
    manoIzq: Option[Item] = None,
    estoyADosManos: Boolean = false
  ) {
    def obtenerItems(): List[Option[Item]] = {
      if (estoyADosManos) return List(manoDer) 
      return List(manoDer, manoIzq)
    }
    def agarrar(item: Item): Manos = {
      item.parte match {
        case ManoDer => {
          if (estoyADosManos) return copy(Some(item), None, false)
          return copy(manoDer=Some(item))
        }
        case ManoIzq => {
          if (estoyADosManos) return copy(None, Some(item), false)
          return copy(manoIzq=Some(item))
        }
        case DosManos => copy(Some(item), Some(item), true)
      }
    }
  }
  
  trait ParteCuerpo
  case object Cabeza extends ParteCuerpo
  case object Torso extends ParteCuerpo
  case object Piernas extends ParteCuerpo
  case object Cuello extends ParteCuerpo
  case object ManoDer extends ParteCuerpo
  case object ManoIzq extends ParteCuerpo
  case object DosManos extends ParteCuerpo
  
  case class Inventario(
    talismanes: List[Item] = List(),
    manos: Manos = Manos(),
    cabeza: Option[Item] = None,
    torso: Option[Item] = None,
    piernas: Option[Item] = None
	) {
    def equipar(item: Item, heroe: Heroe): Inventario = {
      
      if (!item.puedeEquipar(heroe)) return this
      
      item.parte match {
        case Cuello => this.copy(talismanes = item :: talismanes)
        case ManoIzq | ManoDer | DosManos => this.copy(manos=manos.agarrar(item))
        case Cabeza => this.copy(cabeza=Some(item))
        case Torso => this.copy(torso = Some(item))
        case Piernas => this.copy(piernas = Some(item))
      }
    }
    def obtenerItems: List[Item] = {
      val items = List(cabeza, torso) ++ manos.obtenerItems()
      items.filter(_.isDefined).map(_.get) ++ talismanes
    }
    def hp(): Int = obtenerItems.map(_.stats.hp).sum
    def fuerza(): Int = obtenerItems.map(_.stats.fuerza).sum
    def velocidad(): Int = obtenerItems.map(_.stats.velocidad).sum
    def inteligencia(): Int = obtenerItems.map(_.stats.inteligencia).sum
  }
  
  trait Recompensa
  case class RecompensaItem(item: Item) extends Recompensa
  case class RecompensaOro(oro: Int) extends Recompensa
  
  case class Equipo(
    nombre: String,
    heroes: List[Heroe] = List(),
    pozo: Int = 0,
  ) {
    def agregarHeroe(heroe: Heroe): Equipo = copy(heroes = heroe :: heroes )
    def mejorHeroeSegun(criterio: Heroe => Int): Option[Heroe] = {
      val heroesOrdenados = heroes.sortWith((h1, h2) => criterio(h1) > criterio(h2))
      heroesOrdenados match {
        case h1 :: h2 :: _ => {
          if (criterio(h1) == criterio(h2)) return None
          return Some(h1)
        }
        case h1 :: _ => Some(h1)
        case _ => None
      }
    }
    def obtenerRecompensa(recompensa: Recompensa)  {
      recompensa match {
        case RecompensaOro(oro) => copy(pozo= pozo + oro)
        case RecompensaItem(item) => obtenerItem(item)
      }
    }
    def obtenerItem(item: Item): Equipo = {
      def incrementoStatPpal(heroe: Heroe, item: Item): Int = heroe.equipar(item).valorStatPpal - heroe.valorStatPpal
      
      // TODO: reusar mejor heroe segun
    		  val heroesOrdenados = heroes 
        .sortWith((h1, h2) => incrementoStatPpal(h1, item) > incrementoStatPpal(h2, item))
        
      if (heroesOrdenados.length > 0 && incrementoStatPpal(heroesOrdenados.head, item) > 0 ) {
        val nuevoHeroe = heroesOrdenados.head.equipar(item)
        return this.copy(heroes = nuevoHeroe :: heroesOrdenados.slice(1, heroesOrdenados.length))
      }
        
      return this.copy(pozo = pozo + item.precio)
    }
    def reemplazarMiembro(heroeAReemplazar: Heroe, heroeNuevo: Heroe) =
      copy(heroes = heroes.map { case `heroeAReemplazar` => heroeNuevo ; case heroe => heroe })
    def lider(): Option[Heroe] =  mejorHeroeSegun(_.valorStatPpal)
//    def realizarMision(Mision): Try(Equipo) = 
//    def realizarTarea(tarea:Tarea) : Racha[Equipo] = ???
//    def agregarRecompensa(Recomensa): Equipo = 
  }
  
  case class Mision(
    nombre: String,
    tareas: List[Tarea],
    recompensa: Equipo => Equipo
  ) {
    def serRealizadaPor(equipo: Equipo): Try[Equipo] = {
      var equipoBaqueta = tareas.fold(Success(equipo): Try[Equipo]){(equipo,tareaNueva) => {
        equipo match {
          case Success(equipo) => equipo.realizarTarea(tareaNueva)
          case x => x
        }
      }}
      
      equipoBaqueta match {
        case Success(equipo) => recompensa(equipo)
        case Failure(err) => equipo
      }
    }
  }
    
 
  
  case class Tarea(
    nombre: String,
    hacer: Heroe => Heroe,
    facilidad: (Equipo, Heroe) => Option[Int]
  )
  
  object RobarTalisman extends Tarea(
    "robar talisman",
    (heroe: Heroe) => {
      val talismanRobado = Item(Cuello)
      heroe.equipar(talismanRobado)
    },
    (equipo: Equipo, heroe: Heroe) => {
      equipo.lider match {
        case Some(Heroe(Ladron, _, _)) => Some(heroe.velocidad)
        case _ => None
      }
    }
  )
  
  

}