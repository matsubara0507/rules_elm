module Tests exposing (..)

import Expect
import Test exposing (..)


suite : Test
suite =
    test "two plus two equals four"
        (\_ -> Expect.equal 4 (2 + 2))
