{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}

module Control.Distributed.Spark.PairRDD where

import Control.Distributed.Spark.Context
import Control.Distributed.Spark.RDD
import Data.Int
import Data.Text (Text)
import Foreign.JNI
import Language.Java

newtype PairRDD a b = PairRDD (J ('Class "org.apache.spark.api.java.JavaPairRDD"))
instance Coercible (PairRDD a b) ('Class "org.apache.spark.api.java.JavaPairRDD")

zipWithIndex :: RDD a -> IO (PairRDD Int64 a)
zipWithIndex rdd = do
  cls <- findClass "org/apache/spark/api/java/JavaRDD"
  method <- getMethodID cls "zipWithIndex" "()Lorg/apache/spark/api/java/JavaPairRDD;"
  unsafeUncoerce . coerce <$> callObjectMethod rdd method []

wholeTextFiles :: SparkContext -> Text -> IO (PairRDD Text Text)
wholeTextFiles sc uri = do
  juri <- reflect uri
  cls <- findClass "org/apache/spark/api/java/JavaSparkContext"
  method <- getMethodID cls "wholeTextFiles" "(Ljava/lang/String;)Lorg/apache/spark/api/java/JavaPairRDD;"
  unsafeUncoerce . coerce <$> callObjectMethod sc method [coerce juri]

justValues :: PairRDD a b -> IO (RDD b)
justValues prdd = do
  cls <- findClass "org/apache/spark/api/java/JavaPairRDD"
  values <- getMethodID cls "values" "()Lorg/apache/spark/api/java/JavaRDD;"
  unsafeUncoerce . coerce <$> callObjectMethod prdd values []
