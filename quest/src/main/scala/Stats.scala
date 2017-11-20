package ar.edu.tadp.quest

import ar.edu.tadp.quest._

  abstract class StatPpal(
    val nombre: String,
    val aplicar: (Heroe => Int)
  )
  
  case class Stats(
    val hp: Int = 100,
    val fuerza: Int = 10,
    val velocidad: Int = 10,
    val inteligencia: Int = 10
  )
  
    case object Fuerza extends StatPpal("fuerza", (h: Heroe) => h.fuerza)
  case object Inteligencia extends StatPpal("inteligencia", (h: Heroe) => h.inteligencia)
  case object Velocidad extends StatPpal("velocidad", (h: Heroe) => h.velocidad)
  case object Vida extends StatPpal("vida", (h: Heroe) => h.hp)