{-# LANGUAGE NoImplicitPrelude #-}


module Lib where


import           Protolude

import           Data.Functor (void)
import           System.IO    (getChar)


waitForKey :: IO ()
waitForKey = print (1::Int) >> void getChar
