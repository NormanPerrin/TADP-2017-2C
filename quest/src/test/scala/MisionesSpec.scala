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
  val misionOro = fixture.misionOro
  val misionItem = fixture.misionItem

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

  "Un equipo" should "poder realizar una mision y obtener oro" in {
    val equipoMision = equipoVacio
      .agregarHeroe(ladronBase)
      .realizarMision(misionOro)

    equipoMision.equipoRacha().pozo should be(1000)
    equipoMision.equipoRacha().heroes should contain(ladronBase.equipar(Item(Cuello)))
  }
  
  "Un equipo" should "poder realizar una mision y obtener un item" in {
    val equipoMision = equipoVacio
      .agregarHeroe(ladronBase)
      .realizarMision(misionItem)
    
    val ladronDsps = ladronBase.equipar(Item(Cuello)).equipar(Item(Piernas, Stats(10, 10, 10, 10), precio = 100))
    equipoMision.equipoRacha().heroes should contain(ladronDsps)
  }
  
  "Un equipo" should "no poder realizar una mision" in {
    val equipoAntes = equipoVacio
      .agregarHeroe(guerreroBase)
    val equipoDsps = equipoAntes.realizarMision(misionOro).equipoRacha()

    equipoAntes should be (equipoDsps)
  }
  
//  "Un equipo" should "otorgar item al lider, no al que hizo la tarea" in {
//    val equipoAntes = equipoVacio
//      .agregarHeroe(guerreroBase)
//      .
//    val equipoDsps = equipoAntes.realizarMision(misionOro).equipoRacha()
//
//    equipoAntes should be (equipoDsps)
//  }
}