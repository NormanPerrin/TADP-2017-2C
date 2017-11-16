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
    val guante = Item("manoIzq", hp=3)
    guerreroBase.equipar(guante).hp should be (113) // hp default (100) + hp guerrero (10) + hp item (3)
  }

  // falla
  "Un heroe" should "quedar sin poder equiparse item si no cumple su condicion" in {
    val guantePotente = Item("manoIzq", hp=10, condiciones=List(
      (heroe: Heroe) => { heroe.fuerza() > 20 }    
    ))
    guerreroBase.equipar(guantePotente).hp should be (110) // hp default (100) + hp guerrero (10)
  }
}