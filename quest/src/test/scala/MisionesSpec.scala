package ar.edu.tadp.quest

import org.scalatest.{ FlatSpec, Matchers }
import scala.Option
import ar.edu.tadp.quest._

class MisionesSpec extends FlatSpec with Matchers {

  val tarea = fixture.tarea
  val equipoCompleto = fixture.equipoCompleto
  val equipoVacio = fixture.equipoVacio
  val guerreroBase = fixture.guerreroBase
  val ladronBase = fixture.ladronBase
  val mision = fixture.mision

  "Un heroe" should "tiene facilidad para realizar una tarea" in {
    tarea.facilidad(equipoCompleto, guerreroBase) should be(Some(1))
  }

  "Un heroe" should "no deberia tener facilidad para hacer una tarea si no cumple la condicion de facilidad" in {
    RobarTalisman.facilidad(equipoCompleto, guerreroBase) // La condicion para robar talisman es que el lider sea ladron y es mago en este
  }

  "Un heroe" should "deberia tener facilidad para hacer una tarea porque cumple condicion" in {
    RobarTalisman.facilidad(equipoVacio.agregarHeroe(ladronBase), ladronBase) should be(Some(20)) // la facilidad deberia ser igual a la velocidad del guerreroBase
  }

  "Un heroe" should "quedar afectado por una tarea" in {
    val talismanRobado = Item(Cuello)
    RobarTalisman.hacer(ladronBase).inventario.talismanes should contain(talismanRobado)
  }

  "Un equipo" should "poder realizar una mision" in {
    val equipoMision = equipoVacio
      .agregarHeroe(ladronBase)
      .realizarMision(mision)

    equipoMision.equipoRacha().pozo should be(1000)
    equipoMision.equipoRacha().heroes should contain(ladronBase.equipar(Item(Cuello)))
  }
}