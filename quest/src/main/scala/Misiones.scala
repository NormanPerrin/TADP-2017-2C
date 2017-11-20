package ar.edu.tadp.quest
import ar.edu.tadp.quest._
  
    trait Recompensa
  case class RecompensaItem(item: Item) extends Recompensa
  case class RecompensaOro(oro: Int) extends Recompensa

case class Mision(
  nombre: String,
  tareas: List[Tarea],
  recompensa: Recompensa) {
  def serRealizadaPor(equipo: Equipo): Racha = {
    var equipoBaqueta = tareas.foldLeft(RachaGanadora(equipo): Racha) { (racha, tareaNueva) =>
      {
        racha match {
          case RachaGanadora(equipo) => equipo.realizarTarea(tareaNueva)
          case fallido => fallido
        }
      }
    }

    equipoBaqueta match {
      case RachaGanadora(equipo) => RachaGanadora(equipo.obtenerRecompensa(recompensa))
      case RachaPerdedora(_, tarea) => RachaPerdedora(equipo, tarea)
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