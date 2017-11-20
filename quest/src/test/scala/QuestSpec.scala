package ar.edu.tadp.quest

import org.scalatest.FlatSpec
import org.scalatest.Matchers
import ar.edu.tadp.quest.Quest._
import scala.Option

// Ejemplo test
class QuestSpec extends FlatSpec with Matchers {
  
  def guerreroBase = Heroe(Guerrero)
  def magoBase = Heroe(Mago)
  def ladronBase = Heroe(Ladron)
  def equipoVacio = Equipo("Alto Equipo")
  def equipoCompleto = equipoVacio
  .agregarHeroe(magoBase)
  .agregarHeroe(guerreroBase)
  .agregarHeroe(ladronBase)
  def guante = Item(ManoIzq, Stats(3))
  def guantePotente = Item(ManoIzq, Stats(hp=10), condiciones=List(
    (heroe: Heroe) => { heroe.statPpal == Fuerza },
    (heroe: Heroe) => { heroe.fuerza > 100 }
  ))
  def guanteLiviano = Item(ManoIzq, Stats(hp=10))
  def lanza = Item(DosManos, Stats(fuerza=10))
  
  // HEROES TESTS  
  "Un heroe" should "tener vida" in {
    guerreroBase.hp should be (110) // hp heroe (100) + hp guerrero (10)
  }
  
  "Un heroe" should "poderse equipar items" in {
    val guante = Item(ManoIzq, Stats(3))
    guerreroBase.equipar(guante).hp should be (113) // hp heroe (100) + hp guerrero (10) + hp item (3)
  }

  "Un heroe" should "quedar sin poder equiparse item si no cumple una condicion" in {
    val guantePotente = Item(ManoIzq, Stats(10), condiciones=List(
      (heroe: Heroe) => { heroe.fuerza() > 100 }    
    ))
    guerreroBase.equipar(guantePotente).hp should be (110) // hp heroe (100) + hp guerrero (10)
  }
  
  "Un heroe" should "quedar sin poder equiparse item si cumple las condiciones" in {
    guerreroBase.equipar(guanteLiviano).hp should be (120) // hp heroe (100) + hp guerrero (10) + hp item (10)
  }
  
  "Un heroe" should "quedar sin poder equiparse item si no cumple alguna condicion" in {
    guerreroBase.equipar(guantePotente).hp should be (110) // hp heroe (100) + hp guerrero (10)
  }
  
  // dos manos 
  "Un heroe" should "devolver atributo correctamente al equipar un item de dos manos" in {
    guerreroBase.equipar(lanza).fuerza should be (35) // fuerza heroe (10) + fuerza guerrero (15) + fuerza item (10)
  }
  
  "Un heroe" should "devolver atributo correctamente al equipar un item de 1 mano y luego ser reemplazado por uno de dos manos" in {
    val equipado = guerreroBase
      .equipar(guante)
      .equipar(lanza)
      
     equipado.inventario.obtenerItems should be (List(lanza))
  }
  
  "Un heroe" should "devolver atributo correctamente al equipar un item de dos manos y luego ser reemplazado por uno de 1 mano" in {
    val equipado = guerreroBase
      .equipar(lanza)
      .equipar(guante)
      
     equipado.inventario.obtenerItems should be (List(guante))
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
  
  "Un equipo" should "otorgar item al heroe con mayor aumento de stat principal al obtener item" in {
    val item = Item(Cabeza, Stats(fuerza=20), List(), 1000)
    val equipo = equipoVacio
      .agregarHeroe(guerreroBase)
      .agregarHeroe(magoBase)
    
    val nuevos_heroes = equipo.obtenerItem(item).heroes
    val heroes_viejos = equipo.heroes
      
    nuevos_heroes should not be (heroes_viejos) 
  }
  
  "Un equipo" should "vender item si ningun heroe tiene aumento de stat principal al obtener item" in {
    val item = Item(Cabeza, Stats(0, 0, 0, 0), List(), 1000)   
    val equipo = equipoVacio
      .agregarHeroe(guerreroBase)
      .agregarHeroe(magoBase)
      .obtenerItem(item)
      .pozo should be (1000)
  }
  
  "Un equipo" should "vender item si ningun heroe se puede equipar el item" in {
    val item = Item(Cabeza, Stats(inteligencia=1000), List((heroe: Heroe) => heroe.inteligencia > 1000), 1000)
    val equipo = equipoVacio
      .agregarHeroe(guerreroBase)
      .agregarHeroe(magoBase)
      .obtenerItem(item)
      .pozo should be (1000)
  }
  
  "Un equipo" should "otorgar item al heroe con mayor aumento de stat principal al obtener item y pasa condicion" in {
    val item = Item(Cabeza, Stats(fuerza=20), List((heroe: Heroe) => heroe.fuerza > 10), 1000)
    val equipo = equipoVacio
      .agregarHeroe(guerreroBase)
      .agregarHeroe(magoBase)
    
    val nuevos_heroes = equipo.obtenerItem(item).heroes
    val heroes_viejos = equipo.heroes
      
    nuevos_heroes should not be (heroes_viejos) 
  }
  
  "Un equipo vacio" should "vender item al obtener item" in {
    val item = Item(Cabeza, Stats(), List(), 1000)   
    equipoVacio.obtenerItem(item).pozo should be (1000)
  }
  
  "Un equipo" should "poder reemplazar miembro de equipo" in {
    val equipoInicial = equipoVacio.agregarHeroe(guerreroBase)
    val equipoDsps = equipoInicial.reemplazarMiembro(guerreroBase, magoBase)
    
    equipoDsps.heroes should contain (magoBase)
  }
  
  "Un equipo" should "poder reemplazar miembro de equipo y que los otros no reemplazados sigan estando" in {
    val equipoInicial = equipoVacio.agregarHeroe(guerreroBase).agregarHeroe(ladronBase)
    val equipoDsps = equipoInicial.reemplazarMiembro(guerreroBase, magoBase)
    
    equipoDsps.heroes should contain allOf (magoBase, ladronBase)
  }
  
  "Un equipo" should "tener un lider definido si no hay empate" in {
    val equipoInicial = equipoVacio
      .agregarHeroe(guerreroBase)
      .agregarHeroe(ladronBase)
      .agregarHeroe(magoBase)
    
    equipoInicial.lider should be (Some(magoBase))
  }
  
  "Un equipo" should "no tener un lider si hay empate entre miembros" in {
    val item = Item(Cabeza, stats=Stats(0, fuerza=5, 0, 0))
    val equipoInicial = equipoVacio
      .agregarHeroe(guerreroBase.equipar(item))
      .agregarHeroe(ladronBase)
      .agregarHeroe(magoBase)
    
    equipoInicial.lider should be (None)
  }
  
  "Un equipo" should "no tener lider no hay miembros" in {
    equipoVacio.lider should be (None)
  }
  
//  "Un heroe" should "poder realizar una tarea" in {
//    magoBase.realizar(Tarea())
//  }
}