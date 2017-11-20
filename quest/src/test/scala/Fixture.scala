package ar.edu.tadp.quest

import ar.edu.tadp.quest._

object fixture {
  def guerreroBase = Heroe(Guerrero)
  
  def magoBase = Heroe(Mago)
  
  def ladronBase = Heroe(Ladron)
  
  def equipoVacio = Equipo("Alto Equipo")
  
  def equipoCompleto = equipoVacio
    .agregarHeroe(magoBase)
    .agregarHeroe(guerreroBase)
    .agregarHeroe(ladronBase)
    
  def guante = Item(ManoIzq, Stats(3))
  
  def guantePotente = Item(ManoIzq, Stats(hp = 10), condiciones = List(
    (heroe: Heroe) => { heroe.statPpal == Fuerza },
    (heroe: Heroe) => { heroe.fuerza > 100 }))
    
  def guanteLiviano = Item(ManoIzq, Stats(hp = 10))
  
  def lanza = Item(DosManos, Stats(fuerza = 10))
}