module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (Fiber, launchAff)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

import Test.Web.FirestoreSpec as Firestore
import Test.Web.Firestore.OptionsSpec as Options
import Test.Web.Firestore.PathSpec as Path
import Test.Web.Firestore.PrimitiveValueSpec as PrimitiveValue

main :: Effect (Fiber Unit)
main = launchAff $ runSpec [consoleReporter] do
  Options.suite
  Path.suite
  PrimitiveValue.suite
  Firestore.suite
