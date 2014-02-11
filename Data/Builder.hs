{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
-- | Abstraction for different kinds of builders.
--
-- Note that whenever a character encoding is used, it will be UTF8. For
-- different behavior, please use the underlying library.
module Data.Builder
    ( TextBuilder
    , BlazeBuilder
    , Builder (..)
    , ToBuilder (..)
    , textToBuilder
    ) where

import Data.Monoid (Monoid)

import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Builder as TB

import qualified Data.ByteString as S
import qualified Data.ByteString.Lazy as L
import qualified Blaze.ByteString.Builder as BB
import qualified Blaze.ByteString.Builder.Char.Utf8 as BB

-- | Since 0.1.0.0
type TextBuilder = TB.Builder

-- | Since 0.1.0.0
type BlazeBuilder = BB.Builder

-- | Since 0.1.0.0
class Monoid builder => Builder builder lazy | builder -> lazy, lazy -> builder where
    -- | Since 0.1.0.0
    builderToLazy :: builder -> lazy

    -- | Since 0.1.0.0
    flushBuilder :: builder

instance Builder TB.Builder TL.Text where
    builderToLazy = TB.toLazyText
    flushBuilder = TB.flush

instance Builder BB.Builder L.ByteString where
    builderToLazy = BB.toLazyByteString
    flushBuilder = BB.flush

-- | Since 0.1.0.0
class ToBuilder value builder where
    -- | Since 0.1.0.0
    toBuilder :: value -> builder

-- Text
instance ToBuilder TB.Builder TB.Builder where
    toBuilder = id
instance ToBuilder T.Text TB.Builder where
    toBuilder = TB.fromText
instance ToBuilder TL.Text TB.Builder where
    toBuilder = TB.fromLazyText
instance ToBuilder Char TB.Builder where
    toBuilder = TB.singleton
instance (a ~ Char) => ToBuilder [a] TB.Builder where
    toBuilder = TB.fromString

-- Blaze
instance ToBuilder BB.Builder BB.Builder where
    toBuilder = id
instance ToBuilder T.Text BB.Builder where
    toBuilder = BB.fromText
instance ToBuilder TL.Text BB.Builder where
    toBuilder = BB.fromLazyText
instance ToBuilder Char BB.Builder where
    toBuilder = BB.fromChar
instance (a ~ Char) => ToBuilder [a] BB.Builder where
    toBuilder = BB.fromString

instance ToBuilder S.ByteString BB.Builder where
    toBuilder = BB.fromByteString
instance ToBuilder L.ByteString BB.Builder where
    toBuilder = BB.fromLazyByteString

-- | Provided for type disambiguation in the presence of OverloadedStrings.
--
-- Since 0.1.0.0
textToBuilder :: ToBuilder T.Text builder => T.Text -> builder
textToBuilder = toBuilder
