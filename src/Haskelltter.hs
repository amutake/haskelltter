module Haskelltter
    ( l
    , lc
    , lu
    , m
    , u
    , re
    , del
    , rt
    , us
    , setup
    ) where

import Control.Monad.IO.Class (liftIO)
import Data.Conduit
import Data.Monoid
import Data.Int
import qualified Data.Text as T
import qualified Data.Text.IO as T
import System.Directory
import System.IO.Unsafe

import Web.Twitter

n :: Maybe a
n = Nothing

getHaskelltterDir :: IO FilePath
getHaskelltterDir = fmap (++ "/.haskelltter") getHomeDirectory

oauth :: OAuth
oauth = unsafePerformIO $ do
  dir <- getHaskelltterDir
  readOAuthFromJsonFile $ dir ++ "/oauth_consumer.json"

token :: AccessToken
token = unsafePerformIO $ do
  dir <- getHaskelltterDir
  readAccessTokenFromJsonFile $ dir ++ "/access_token.json"

run :: Twitter a -> IO a
run = runTwitter oauth token

printStatus :: Status -> IO ()
printStatus status = do
  putStr $ show (statusId status) ++ " "
  putStr $ "(" <> show (statusCreatedAt status) <> ") "
  T.putStrLn $ (userScreenName $ statusUser status) <> ": "
  T.putStrLn $ statusText status
  putStrLn ""

printEvent :: Event -> IO ()
printEvent event = do
  putStr $ "(" <> show (eventCreatedAt event) <> ") "
  T.putStr $ "Event: " <> T.pack (show $ eventType event) <> " "
  T.putStrLn $ "@" <> (userScreenName $ eventSource event) <> " -> " <>
               "@" <> (userScreenName $ eventTarget event)

printStatusDeletion :: StatusDeletion -> IO ()
printStatusDeletion sd = do
  T.putStr "Status deletion: "
  putStrLn $ show $ statusDeletionId sd

printDM :: DirectMessage -> IO ()
printDM dm = do
  putStr $ "(" <> show (directMessageCreatedAt dm) <> ") "
  T.putStr "Direct message from "
  T.putStr $ directMessageSenderScreenName dm <> ": "
  T.putStr $ directMessageText dm
  print $ directMessageId dm

l :: IO ()
l = do
  tl <- run $ homeTimeline n n n n n n n
  mapM_ printStatus tl

lc :: Int -> IO ()
lc count = do
  tl <- run $ homeTimeline (Just count) n n n n n n
  mapM_ printStatus tl

lu :: String -> IO ()
lu name = do
  tl <- run $ userTimeline n (Just $ T.pack name) n n n n n n n
  mapM_ printStatus tl

m :: IO ()
m = do
  ms <- run $ mentionsTimeline n n n n n n
  mapM_ printStatus ms

u :: String -> IO ()
u text = do
  st <- run $ update (T.pack text) n n n n n n
  printStatus st

re :: Int64 -> String -> IO ()
re sid text = do
  s <- run $ do
    target <- showStatus sid n n n
    let t = "@" <> userScreenName (statusUser target) <> " " <> T.pack text
    update t (Just $ statusId target) n n n n n
  printStatus s

del :: Int64 -> IO ()
del sid = do
  s <- run $ destroy sid n
  printStatus s

rt :: Int64 -> IO ()
rt sid = do
  s <- run $ retweet sid n
  printStatus s

us :: IO ()
us = do
  putStrLn "user stream (to stop, Ctrl-C)"
  putStrLn ""
  run $ do
    src <- user
    src $$+- sink
  where
    sink = awaitForever $ \s -> liftIO $ case s of
      StreamStatus st -> printStatus st
      StreamEvent ev -> printEvent ev
      StreamStatusDeletion sd -> printStatusDeletion sd
      StreamDirectMessage dm -> printDM dm
      _ -> return ()

setup :: IO ()
setup = do
  putStr "Input consumer key: "
  key <- getLine
  putStr "Input consumer secret: "
  secret <- getLine
  let oa = newOAuth key secret
  tok <- authorizeIO oa $ \url -> do
    putStr "Authorize URL: "
    putStrLn url
    putStr "Input PIN: "
    fmap read getLine
  dir <- getHaskelltterDir
  createDirectoryIfMissing True dir
  saveOAuthToJsonFile (dir ++ "/oauth_consumer.json") oa
  saveAccessTokenToJsonFile (dir ++ "/access_token.json") tok
  putStrLn "Done. Please reload GHCi."
