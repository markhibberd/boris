{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}
module Test.IO.Boris.Store.Index where

import qualified Boris.Store.Index as SI

import qualified Data.List as L

import           P

import           Test.Boris.Core.Arbitrary ()
import           Test.IO.Boris.Store
import           Test.QuickCheck
import           Test.Mismi (testAWS)

prop_project p b = once . testAWS . withClean environment (SI.deleteProjects environment p) $ do
  SI.addProject environment p b
  res <- SI.getProjects environment p
  pure $ res === [b]

prop_projectRef p r b = once . testAWS . withClean environment (SI.deleteProjectRefs environment p r) $ do
  SI.addProjectRef environment p r b
  res <- SI.getProjectRefs environment p r
  pure $ res === [b]

prop_projectCommit p c = once . testAWS . withClean environment (SI.deleteProjects environment p) $ do
  SI.addProjectCommit environment p c
  res <- SI.getProjectCommits environment p
  pure $ res === [c]

prop_projectCommitBuildId p c i = once . testAWS . withClean environment (SI.deleteProjectCommit environment p c) $ do
  SI.addProjectCommitBuildId environment p c i
  res <- SI.getProjectCommitBuildIds environment p c
  pure $ res === [i]

prop_buildId p b r i = once . testAWS . withClean environment (SI.deleteBuildIds environment p b r) $ do
  SI.addBuildId environment p b r i
  res <- SI.getBuildIds environment p b r
  pure $ res === [i]

prop_queued p b i1 i2 = once . testAWS . withClean environment (SI.deleteQueued environment p b) $ do
  SI.addQueued environment p b i1
  res1 <- SI.getQueued environment p b
  SI.addQueued environment p b i2
  res2 <- SI.getQueued environment p b
  SI.clearQueued environment p b i2
  res3 <- SI.getQueued environment p b
  SI.clearQueued environment p b i1
  res4 <- SI.getQueued environment p b
  pure $ [res1, L.sort res2, res3, res4] === [[i1], L.sort [i1, i2], [i1], []]

prop_buildRef p b r = once . testAWS . withClean environment (SI.deleteBuildRefs environment p b) $ do
  SI.addBuildRef environment p b r
  res <- SI.getBuildRefs environment p b
  pure $ res === [r]

return []
tests = $quickCheckAll