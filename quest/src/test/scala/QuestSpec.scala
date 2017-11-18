package ar.edu.tadp.quest

import org.scalatest.FlatSpec
import org.scalatest.Matchers
import ar.edu.tadp.quest.Quest._
import scala.Option

// Ejemplo test
class QuestSpec extends FlatSpec with Matchers {
  
  def guerreroBase = Heroe(Guerrero)
  def magoBase = Heroe(Mago)
  def equipoVacio = Equipo("Alto Equipo")
  
  // HEROES TESTS  
  "Un heroe" should "tener vida" in {
    guerreroBase.hp should be (110) // hp heroe (100) + hp guerrero (10)
  }
  
  "Un heroe" should "poderse equipar items" in {
    val guante = Item("manoIzq", Stats(3))
    guerreroBase.equipar(guante).hp should be (113) // hp heroe (100) + hp guerrero (10) + hp item (3)
  }

  "Un heroe" should "quedar sin poder equiparse item si no cumple una condicion" in {
    val guantePotente = Item("manoIzq", Stats(10), condiciones=List(
      (heroe: Heroe) => { heroe.fuerza() > 100 }    
    ))
    guerreroBase.equipar(guantePotente).hp should be (110) // hp heroe (100) + hp guerrero (10)
  }
  
  "Un heroe" should "quedar sin poder equiparse item si cumple las condiciones" in {
    val guantePotente = Item("manoIzq", Stats(10), condiciones=List(
      (heroe: Heroe) => { heroe.statPpal == Fuerza },
      (heroe: Heroe) => { heroe.fuerza() > 20 }
    ))
    guerreroBase.equipar(guantePotente).hp should be (120) // hp heroe (100) + hp guerrero (10)
  }
  
  "Un heroe" should "quedar sin poder equiparse item si no cumple alguna condicion" in {
    val guantePotente = Item("manoIzq", Stats(10), condiciones=List(
      (heroe: Heroe) => { heroe.statPpal == Fuerza },
      (heroe: Heroe) => { heroe.fuerza > 100 }
    ))
    guerreroBase.equipar(guantePotente).hp should be (110) // hp heroe (100) + hp guerrero (10)
  }
  
  "Un heroe" should "poder cambiar de trabajo" in {
    guerreroBase.trabajo(Mago).trabajo.statPpal should be (Inteligencia)
  }
  
  "Un heroe" should "poder cambiar de stats" in {
    guerreroBase.fuerza(100).fuerza should be (115) // fuerza heroe (100) + fuerza guerrero (15)
  }
  
  // EQUIPO TESTS
  "Un equipo vacio" should "no deberia tener heroes" in {
    equipoVacio.heroes.length should be (0)
  }
  
  "Un equipo vacio" should "poder reclutar heroes" in {
    equipoVacio.agregarHeroe(guerreroBase).heroes.length should be (1)
  }
  
  "Un equipo vacio" should "tener al mejor heroe segun un criterio que le pase" in {
    val heroe = equipoVacio
      .agregarHeroe(guerreroBase)
      .mejorHeroeSegun((heroe: Heroe) => heroe.stats.fuerza)
      
    heroe should contain (guerreroBase)
  }
  
  "Un equipo vacio" should "no darme mejor heroe si no tengo heroes en el equipo" in {
    val heroe = equipoVacio
      .mejorHeroeSegun((heroe: Heroe) => heroe.stats.fuerza)
      
    heroe shouldBe None
  }
  
//  "Un equipo" should "otorgar item al heroe con mayor aumento de stat principal al obtener item" in {
//    val item = Item("cabeza", Stats(), List((heroe: Heroe) => heroe.fuerza > 10), 1000)   
//    val equipo = equipoVacio
//      .agregarHeroe(guerreroBase)
//      .agregarHeroe(magoBase)
//      .obtenerItem(item)
//      .heroes
//      .head
//      .inventario
//      .cabeza should be (item)
//  }
  
  "Un equipo" should "vender item si ningun heroe tiene aumento de stat principal al obtener item" in {
    val item = Item("cabeza", Stats(), List(), 1000)   
    val equipo = equipoVacio
      .agregarHeroe(guerreroBase)
      .agregarHeroe(magoBase)
      .obtenerItem(item)
      .pozo should be (1000)
  }
  
  "Un equipo vacio" should "vender item al obtener item" in {
    val item = Item("cabeza", Stats(), List(), 1000)   
    equipoVacio.obtenerItem(item).pozo should be (1000)
  }
}