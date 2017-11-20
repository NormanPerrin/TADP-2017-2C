package ar.edu.tadp.quest

import ar.edu.tadp.quest._

  case class Item(
    parte: ParteCuerpo,
    stats: Stats = Stats(0, 0, 0, 0),
    condiciones: List[Heroe => Boolean] = List(),
    precio: Int = 0
	) {
    def puedeEquipar(heroe: Heroe): Boolean = condiciones.forall(cond => cond(heroe))
  }

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
      val items = List(cabeza, torso, piernas) ++ manos.obtenerItems()
      items.filter(_.isDefined).map(_.get) ++ talismanes
    }
    def hp(): Int = obtenerItems.map(_.stats.hp).sum
    def fuerza(): Int = obtenerItems.map(_.stats.fuerza).sum
    def velocidad(): Int = obtenerItems.map(_.stats.velocidad).sum
    def inteligencia(): Int = obtenerItems.map(_.stats.inteligencia).sum
  }