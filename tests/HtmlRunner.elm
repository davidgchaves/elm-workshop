module HtmlRunner exposing (..)

import Tests
import Test.Runner.Html exposing (run, TestProgram)


main : TestProgram
main =
    run Tests.all
