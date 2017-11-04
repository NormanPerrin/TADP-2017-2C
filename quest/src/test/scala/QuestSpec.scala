package ar.edu.tadp.quest

import org.scalatest.FlatSpec
import org.scalatest.Matchers
import ar.edu.tadp.quest.Quest._

// http://www.scalatest.org/user_guide/writing_your_first_test

// Ejemplo test
class QuestSpec extends FlatSpec with Matchers {
  "Un heroe" should "blah" in {
    assert(true)
  }
}