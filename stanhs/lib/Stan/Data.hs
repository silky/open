module Stan.Data where

import Data.List
import qualified Data.Sequence as Seq
import Data.Monoid

class Dump1 a where
  dump1 :: a -> ([String], [Int])

instance Dump1 Double where
    dump1 x = ([show x], [])
instance Dump1 Int where
    dump1 x = ([show x], [])
instance Dump1 Bool where
    dump1 True = (["1"], [])
    dump1 False = (["0"], [])

--dump1c xs = concat $ "c(" : intersperse "," (map dump1 xs) ++[")"]

instance Dump1 a => Dump1 [a] where
    dump1 xs = let xss = map dump1 xs
               in (concatMap fst xss, length xss:(snd $ head xss) )


dumpAll :: ([String], [Int]) -> String
dumpAll ([s], []) = s
dumpAll (ss, [_]) = concat $ "c(" : intersperse "," ss ++[")"]
dumpAll (ss, ns) = concat $ "structure(c(" : intersperse "," ss ++["), .Dim = c("]
                             ++intersperse "," (map show ns)++[")"]

dumpAs :: Dump1 a => String -> a -> StanData
dumpAs nm x = StanData $ Seq.singleton $ nm++"<-"++(dumpAll $ dump1 x)

(<~) :: Dump1 a => String -> a -> StanData
(<~) = dumpAs

newtype StanData = StanData { unStanData :: Seq.Seq String }

instance Monoid StanData where
  StanData s1 `mappend` StanData s2 = StanData $ s1 <> s2
  mempty = StanData mempty


--class ToStanData a where
--  toStanData :: a -> String
