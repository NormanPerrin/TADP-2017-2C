package ar.edu.tadp.quest

import org.scalatest.FlatSpec
import org.scalatest.Matchers
import ar.edu.tadp.quest.Quest._

// Ejemplo test
class QuestSpec extends FlatSpec with Matchers {
  
  def guerreroBase = Heroe(Guerrero)
  
  "Un heroe" should "tener vida" in {
    guerreroBase.hp should be (110) // hp default (100) + hp guerrero (10)
  }
  
  "Un heroe" should "poderse equipar items" in {
    val guante = Item("manoIzq", Stats(3))
    guerreroBase.equipar(guante).hp should be (113) // hp default (100) + hp guerrero (10) + hp item (3)
  }

  "Un heroe" should "quedar sin poder equiparse item si no cumple una condicion" in {
    val guantePotente = Item("manoIzq", Stats(10), condiciones=List(
      (heroe: Heroe) => { heroe.fuerza() > 100 }    
    ))
    guerreroBase.equipar(guantePotente).hp should be (110) // hp default (100) + hp guerrero (10)
  }
  
  "Un heroe" should "quedar sin poder equiparse item si cumple las condiciones" in {
    val guantePotente = Item("manoIzq", Stats(10), condiciones=List(
      (heroe: Heroe) => { heroe.statPpal == "fuerza" },
      (heroe: Heroe) => { heroe.fuerza() > 20 }
    ))
    guerreroBase.equipar(guantePotente).hp should be (120) // hp default (100) + hp guerrero (10)
  }
  
    "Un heroe" should "quedar sin poder equiparse item si no cumple alguna condicion" in {
    val guantePotente = Item("manoIzq", Stats(10), condiciones=List(
      (heroe: Heroe) => { heroe.statPpal == "fuerza" },
      (heroe: Heroe) => { heroe.fuerza > 100 }
    ))
    guerreroBase.equipar(guantePotente).hp should be (110) // hp default (100) + hp guerrero (10)
  }
}