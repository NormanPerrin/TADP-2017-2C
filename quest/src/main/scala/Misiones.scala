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
  
  case class Taberna(
    misiones: List[Mision] = List()
  ) {
    type Criterio = (Equipo, Equipo) => Boolean
    def elegirMision(equipo: Equipo, criterio: Criterio, misionesDisponibles:List[Mision]): Option[Mision] = {
      
      val misionesGanadas = misionesDisponibles.filter( (mision) => {
        equipo.realizarMision(mision) match {
          case RachaGanadora(_) => true
          case _ => false
        }
      })

      val misionesOrdenadas = misionesGanadas.sortWith((m1, m2) => {
        val resultado1 = equipo.realizarMision(m1)
        val resultado2 = equipo.realizarMision(m2)
        criterio(resultado1.equipoRacha, resultado2.equipoRacha)
      })
      
      if (misionesGanadas.length > 0) return Some(misionesOrdenadas.head)
      return None
    }
    
    def elegirMision(equipo:Equipo, criterio:Criterio): Option[Mision]={
      elegirMision(equipo,criterio,misiones)
    }

    def entrenar(equipo: Equipo, criterio: Criterio): Equipo = {
      var misionesDisponibles = misiones
      var equipoMisioneando:Racha = RachaGanadora(equipo)
      
      while (!misionesDisponibles.isEmpty) {
        var misionARealizar = elegirMision(equipo,criterio,misionesDisponibles).getOrElse(misionesDisponibles.head)
        equipoMisioneando = equipoMisioneando.flatMap(_.realizarMision(misionARealizar))
        misionesDisponibles = misionesDisponibles.diff(List(misionARealizar))
      }
      
      return equipoMisioneando.equipoRacha
    }
      
  }