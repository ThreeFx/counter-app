{-# LANGUAGE OverloadedStrings #-}

import Snap.Core
import Snap.Http.Server
import Snap.Http.Server.Config
import Snap.Internal.Http.Server.Config

import Database.Redis hiding (append)

import System.IO.Unsafe

import Data.Time
import Data.Time.ISO8601

import Data.ByteString.Char8

import Control.Monad.IO.Class

--import Snap.Snaplet.RedisDB

--import Hedis

main = do
    conn <- checkedConnect $ defaultConnectInfo { connectHost = "redis" }
    httpServe snapCfg $ route [("/", ifTop $ requestHandler conn)]

--storeTimestamp :: ByteString -> Redis (Either Reply Integer)
storeTimestamp ts = do
    rpush "visits" [ts]

getVisits :: Redis (Either Reply Integer)
getVisits = llen "visits"

requestHandler :: Connection -> Snap ()
requestHandler conn = do
    req <- getRequest
    let resp = emptyResponse
    let timestamp = pack . formatISO8601 <$> getCurrentTime
    liftIO $ runRedis conn =<< (storeTimestamp <$> timestamp)
    len <- liftIO $ runRedis conn getVisits
    case len of
      (Left err) -> writeBS "An error occured while fetching the number of vists"
      (Right v) -> writeBS $ "Number of visits: " `append` pack (show v)

snapCfg = defaultConfig { port = Just 5000 }
