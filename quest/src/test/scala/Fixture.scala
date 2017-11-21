package ar.edu.tadp.quest

import ar.edu.tadp.quest._

object fixture {
  def guerreroBase = Heroe(Guerrero)
  
  def magoBase = Heroe(Mago)
  
  def magoTonto = Heroe(Mago, stats=Stats(inteligencia=(-10)))
  
  def ladronBase = Heroe(Ladron)
  
  def equipoVacio = Equipo("Alto Equipo")
  
  def equipoCompleto = equipoVacio
    .agregarHeroe(magoBase)
    .agregarHeroe(guerreroBase)
    .agregarHeroe(ladronBase)
  
  def equipoTriunfador = equipoVacio.agregarHeroe(ladronBase).agregarHeroe(magoTonto)
    
  def guante = Item(ManoIzq, Stats(3))
  
  def guantePotente = Item(ManoIzq, Stats(hp = 10), condiciones = List(
    (heroe: Heroe) => { heroe.statPpal == Fuerza },
    (heroe: Heroe) => { heroe.fuerza > 100 }))
    
  def guanteLiviano = Item(ManoIzq, Stats(hp = 10))
  
  def lanza = Item(DosManos, Stats(fuerza = 10))
  
  def tarea = Tarea("sacar la basura", (heroe: Heroe) => heroe, (equipo: Equipo, heroe: Heroe) => Some(1))
  
  def misionOro = Mision("Robar cosas", List(RobarTalisman), RecompensaOro(1000))
  
  def misionItem = Mision("Robar cosas", List(RobarTalisman), RecompensaItem(Item(Piernas, Stats(10, 10, 10, 10), precio=100)))
  
  def misionRecompensaEspecial = Mision("Robar especial", List(RobarTalisman), RecompensaItem(Item(Cabeza, Stats(10, 10, 100, 10), precio=100)))
  
  def taberna = Taberna(List(misionItem, misionOro))
  
  def mayorOro = (e1: Equipo, e2: Equipo) => { e1.pozo > e2.pozo }
}