{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Web.Firestore.SetOptions where

type Merge = Boolean

foreign import data MergeField :: Type

foreign import stringMergeField :: String -> MergeField

foreign import fieldPathMergeField :: Array String -> MergeField

type MergeFields = Array MergeField

foreign import data SetOptions :: Type

foreign import mergeOption :: Merge -> SetOptions

foreign import mergeFieldsOption :: MergeFields -> SetOptions
