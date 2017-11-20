package ar.edu.tadp.quest

import org.scalatest.{FlatSpec, Matchers}
import scala.Option
import ar.edu.tadp.quest._

class ItemsSpec extends FlatSpec with Matchers {
  val guerreroBase = fixture.guerreroBase
  val guante = fixture.guante
  val guanteLiviano = fixture.guanteLiviano
  val guantePotente = fixture.guantePotente
  val lanza = fixture.lanza

  "Un heroe" should "poderse equipar items" in {
    val guante = Item(ManoIzq, Stats(3))
    guerreroBase.equipar(guante).hp should be(113) // hp heroe (100) + hp guerrero (10) + hp item (3)
  }

  "Un heroe" should "quedar sin poder equiparse item si cumple las condiciones" in {
    guerreroBase.equipar(guanteLiviano).hp should be(120) // hp heroe (100) + hp guerrero (10) + hp item (10)
  }

  "Un heroe" should "quedar sin poder equiparse item si no cumple alguna condicion" in {
    guerreroBase.equipar(guantePotente).hp should be(110) // hp heroe (100) + hp guerrero (10)
  }

  // dos manos 
  "Un heroe" should "devolver atributo correctamente al equipar un item de dos manos" in {
    guerreroBase.equipar(lanza).fuerza should be(35) // fuerza heroe (10) + fuerza guerrero (15) + fuerza item (10)
  }

  "Un heroe" should "devolver atributo correctamente al equipar un item de 1 mano y luego ser reemplazado por uno de dos manos" in {
    val equipado = guerreroBase
      .equipar(guante)
      .equipar(lanza)

    equipado.inventario.obtenerItems should be(List(lanza))
  }

  "Un heroe" should "devolver atributo correctamente al equipar un item de dos manos y luego ser reemplazado por uno de 1 mano" in {
    val equipado = guerreroBase
      .equipar(lanza)
      .equipar(guante)

    equipado.inventario.obtenerItems should be(List(guante))
  }

}