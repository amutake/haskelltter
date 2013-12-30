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
import qualified Data.ByteString as BS
import Data.Conduit
import Data.Monoid
import Data.Int
import qualified Data.Text as T
import qualified Data.Text.IO as T
import System.Directory
import System.IO.Unsafe

import Web.Twitter

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
  T.putStr $ "(" <> statusCreatedAt status <> ") "
  T.putStr $ (userScreenName $ statusUser status) <> ": "
  T.putStr $ statusText status <> " "
  print $ statusId status

printEvent :: Event -> IO ()
printEvent event = do
  T.putStr $ "(" <> eventCreatedAt event <> ") "
  T.putStr $ "Event: " <> T.pack (show $ eventType event) <> " "
  T.putStrLn $ "@" <> (userScreenName $ eventSource event) <> " -> " <>
               "@" <> (userScreenName $ eventTarget event)

printStatusDeletion :: StatusDeletion -> IO ()
printStatusDeletion sd = do
  T.putStr "Status deletion: "
  putStrLn $ show $ statusDeletionId sd

printDM :: DirectMessage -> IO ()
printDM dm = do
  T.putStr $ "(" <> directMessageCreatedAt dm <> ") "
  T.putStr "Direct message from "
  T.putStr $ directMessageSenderScreenName dm <> ": "
  T.putStr $ directMessageText dm
  print $ directMessageId dm

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

us :: IO ()
us = run $ do
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
  key <- BS.getLine
  putStr "Input consumer secret: "
  secret <- BS.getLine
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
