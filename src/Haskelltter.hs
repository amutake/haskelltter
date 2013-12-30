module Haskelltter
    ( l
    , lc
    , lu
    , m
    , u
    , re
    , del
    , rt
    ) where

import Data.Monoid
import Data.Int
import qualified Data.Text as T
import qualified Data.Text.IO as T
import System.IO.Unsafe

import Web.Twitter

oauth :: OAuth
oauth = unsafePerformIO $ readOAuthFromJsonFile "oauth_consumer.json"

token :: AccessToken
token = unsafePerformIO $ readAccessTokenFromJsonFile "access_token.json"

run :: Twitter a -> IO a
run = runTwitter oauth token

printStatus :: Status -> IO ()
printStatus status = do
  T.putStr $ "(" <> statusCreatedAt status <> ") "
  T.putStr $ (userScreenName $ statusUser status) <> ": "
  T.putStr $ statusText status <> " "
  print $  statusId status

l :: IO ()
l = do
  tl <- run $ homeTimeline Nothing Nothing Nothing Nothing Nothing Nothing Nothing
  mapM_ printStatus tl

lc :: Int -> IO ()
lc n = do
  tl <- run $ homeTimeline (Just n) Nothing Nothing Nothing Nothing Nothing Nothing
  mapM_ printStatus tl

lu :: String -> IO ()
lu name = do
  tl <- run $ userTimeline Nothing (Just $ T.pack name)
        Nothing Nothing Nothing Nothing Nothing Nothing Nothing
  mapM_ printStatus tl

m :: IO ()
m = do
  ms <- run $ mentionsTimeline Nothing Nothing Nothing Nothing Nothing Nothing
  mapM_ printStatus ms

u :: String -> IO ()
u text = do
  st <- run $ update (T.pack text)
        Nothing Nothing Nothing Nothing Nothing Nothing
  printStatus st

re :: Int64 -> String -> IO ()
re sid text = do
  s <- run $ do
    target <- showStatus sid Nothing Nothing Nothing
    let t = "@" <> userScreenName (statusUser target) <> " " <> T.pack text
    update t (Just $ statusId target) Nothing Nothing Nothing Nothing Nothing
  printStatus s

del :: Int64 -> IO ()
del sid = do
  s <- run $ destroy sid Nothing
  printStatus s

rt :: Int64 -> IO ()
rt sid = do
  s <- run $ retweet sid Nothing
  printStatus s
