{-# LANGUAGE NoImplicitPrelude #-}
module Boris.Prelude (
    module X
  , fromMaybeM
  , whenM
  , unlessM
  , with
  , bind
  , valueOrEmpty
  , emptyOrValue
  , orEmpty
  ) where

import           Boris.Prelude.EitherT as X
import           Control.Applicative as X
import           Control.Monad as X
import           Data.Bits as X (Bits (..))
import           Data.Bool as X (Bool (..), (||), (&&), not, bool, otherwise)
import           Data.Char as X (Char)
import           Data.Bifunctor as X (Bifunctor (..))
import           Data.Either as X (Either (..), either)
import           Data.Foldable as X
import           Data.Function as X ((.), ($), (&), flip, id, const)
import           Data.Functor as X (($>))
import           Data.Int as X
import           Data.Maybe as X (Maybe (..), isNothing, isJust, maybe, fromMaybe, catMaybes)
import           Data.Monoid as X (Monoid (..), (<>))
import           Data.Text as X (Text)
import           Data.Traversable as X
import           Data.Word as X (Word8, Word16, Word32, Word64)
import           Prelude as X (Eq (..), Show (..), Ord (..), Num (..), Enum, Bounded (..), Integral (..), Double, error, seq, fromIntegral, (/), (^), fst, snd, Integer, Real (..), floor, subtract)
import           Text.Read as X (Read (..), readMaybe)


fromMaybeM :: Applicative f => f a -> Maybe a -> f a
fromMaybeM =
  flip maybe pure

whenM :: Monad m => m Bool -> m () -> m ()
whenM p m =
  p >>= flip when m

unlessM :: Monad m => m Bool -> m () -> m ()
unlessM p m =
  p >>= flip unless m

with :: Functor f => f a -> (a -> b) -> f b
with =
  flip fmap

bind :: Monad m => (a -> m b) -> m a -> m b
bind =
  (=<<)
{-# INLINE bind #-}

valueOrEmpty :: Alternative f => Bool -> a -> f a
valueOrEmpty b a =
  if b then pure a else empty

emptyOrValue :: Alternative f => Bool -> a -> f a
emptyOrValue =
  valueOrEmpty . not

orEmpty :: (Alternative f, Monoid a) => f a -> f a
orEmpty f =
  f <|> pure mempty