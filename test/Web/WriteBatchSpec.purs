{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Test.Web.WriteBatchSpec where

import Prelude
import Control.Promise (toAff)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromJust, isJust, isNothing)
import Data.Traversable (sequence)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Foreign.Object (fromFoldable)
import Partial.Unsafe (unsafePartial)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual)

import Test.Web.Firestore.OptionsUtils (buildTestOptions)
import Web.Firestore (batch, batchCommit, batchDelete, batchSet, batchUpdate, doc, initializeApp, firestore)
import Web.Firestore.DocumentData (DocumentData(..))
import Web.Firestore.DocumentValue (primitiveDocument)
import Web.Firestore.Path (pathFromString)
import Web.Firestore.PrimitiveValue (pvBoolean, pvNull, pvNumber, pvText)

suite :: Spec Unit
suite = do
  describe "Firestore" do
    it "creates a write batch" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch1")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              let writeBatch = batch firestoreInstance
              pure unit

    let document = DocumentData (fromFoldable [ "text"      /\ (primitiveDocument (pvText    "some text"))
                                              , "number"    /\ (primitiveDocument (pvNumber  273.15     ))
                                              , "bool"      /\ (primitiveDocument (pvBoolean true       ))
                                              , "null"      /\ (primitiveDocument (pvNull               ))
                                              ])

    it "sets document on a write batch" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch2")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              maybeDocRef <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test")
              case maybeDocRef of
                Nothing     -> fail "invalid path"
                Just docRef -> do
                  let writeBatch = batch firestoreInstance
                      _ = batchSet writeBatch docRef document Nothing
                  pure unit

    it "deletes document on a write batch" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch3")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              maybeDocRef <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test")
              case maybeDocRef of
                Nothing     -> fail "invalid path"
                Just docRef -> do
                  let writeBatch = batch firestoreInstance
                      _ = batchDelete writeBatch docRef
                  pure unit

    it "updates document on a write batch" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch4")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              maybeDocRef <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test")
              case maybeDocRef of
                Nothing     -> fail "invalid path"
                Just docRef -> do
                  let writeBatch = batch firestoreInstance
                      _ = batchUpdate writeBatch docRef document
                  pure unit

    it "commits a write batch" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch5")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              maybeDocRef <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test")
              case maybeDocRef of
                Nothing     -> fail "invalid path"
                Just docRef -> do
                  let writeBatch  = batch firestoreInstance
                      writeBatch1 = batchSet writeBatch docRef document Nothing
                      writeBatch2 = batchUpdate writeBatch docRef document
                      writeBatch3 = batchDelete writeBatch docRef
                  batchCommitPromise <- liftEffect $ batchCommit writeBatch3
                  isJust batchCommitPromise `shouldEqual` true
                  toAff (unsafePartial $ fromJust batchCommitPromise)

    it "does not commit a write batch twice" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch6")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              maybeDocRef <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test")
              case maybeDocRef of
                Nothing     -> fail "invalid path"
                Just docRef -> do
                  let writeBatch  = batch firestoreInstance
                      writeBatch1 = batchSet writeBatch docRef document Nothing
                      writeBatch2 = batchUpdate writeBatch docRef document
                      writeBatch3 = batchDelete writeBatch docRef
                  batchCommitPromise1 <- liftEffect $ batchCommit writeBatch3
                  isJust batchCommitPromise1 `shouldEqual` true
                  toAff (unsafePartial $ fromJust batchCommitPromise1)
                  batchCommitPromise2 <- liftEffect $ batchCommit writeBatch3
                  isNothing batchCommitPromise2 `shouldEqual` true
