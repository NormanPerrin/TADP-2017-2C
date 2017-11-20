package ar.edu.tadp.quest
import ar.edu.tadp.quest._

case class Tarea(
    nombre: String,
    efecto: Heroe => Heroe,
    facilidad: (Equipo,Heroe) => Option[Int]
  ) {
    def hacer(heroe: Heroe): Heroe = efecto(heroe) 
  }