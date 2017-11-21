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
  val misionEspecial = fixture.misionRecompensaEspecial
  val taberna = fixture.taberna
  val equipoTriunfador = fixture.equipoTriunfador
  val mayorOro = fixture.mayorOro

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
  
  "Un equipo" should "otorgar recompensa al ladron y otorgar item tarea al mago" in {
    val magoVeloz = Heroe(Mago, stats=Stats(velocidad=100, inteligencia=(-10)))
    
    val equipoAntes = equipoVacio
      .agregarHeroe(ladronBase)
      .agregarHeroe(magoVeloz)

    val equipoDsps = equipoAntes.realizarMision(misionEspecial).equipoRacha()
    
    val magoVelozDsps = magoVeloz.equipar(Item(Cuello))
    val ladronDsps = ladronBase.equipar(Item(Cabeza, Stats(10, 10, 100, 10), precio=100))
    
    equipoDsps.heroes should contain allOf (magoVelozDsps, ladronDsps)
  }
  
  "Una taberna" should "elegir mejor mision para un equipo" in {
    val mejorMision = taberna.elegirMision(equipoTriunfador, mayorOro)
    
    mejorMision should be (Some(misionOro))
  }
  
  "Una taberna" should "no elegir ninguna mision si ninguna se puede ganar" in {
    val mejorMision = taberna.elegirMision(equipoCompleto, mayorOro)
    
    mejorMision should be (None)
  }
  
  
  "Una taberna" should "entrenar un equipo y devolver nuevo equipo con efectos de todas las misiones" in {
    val equipoDsps = taberna.entrenar(equipoTriunfador, mayorOro)
    
    val equipoExpected = equipoTriunfador.realizarMision(misionOro).equipoRacha.realizarMision(misionItem).equipoRacha()
    
    equipoDsps should be (equipoExpected) 
  }
  
  "Una taberna" should "entrenar un equipo completo y devolver nuevo equipo sin efectos" in {
    taberna.entrenar(equipoCompleto, mayorOro) should be (equipoCompleto) 
  }
}