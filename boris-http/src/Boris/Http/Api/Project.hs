{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Boris.Http.Api.Project (
    picker
  , pick
  , list
  , discover
  , new
  ) where

import           Boris.Core.Data.Build
import           Boris.Core.Data.Project
import           Boris.Core.Data.Repository
import           Boris.Core.Data.Tenant
import           Boris.Http.Data
import qualified Boris.Http.Db.Query as Query

import qualified Data.List as List

import           P

import           System.IO (IO)

import           Traction.Control (DbPool, DbError)
import qualified Traction.Control as Traction

import           X.Control.Monad.Trans.Either (EitherT)

picker :: Project -> [Definition] -> Maybe Repository
picker project =
  fmap definitionRepository . List.find ((==) project . definitionProject)

pick :: DbPool -> Tenant -> AuthenticatedBy -> Project -> EitherT DbError IO (Maybe Repository)
pick pool tenant authenticated project =
  Traction.runDb pool $ case tenant of
    SingleTenant ->
      case authenticated of
        AuthenticatedByDesign _ ->
          picker project <$> Query.getAllProjects
        AuthenticatedByGithub _session user ->
           picker project <$> Query.getAccountProjects (userIdOf user)
    MultiTenant ->
      case authenticated of
        AuthenticatedByDesign _ ->
          pure Nothing
        AuthenticatedByGithub _session user ->
          picker project <$> Query.getAccountProjects (userIdOf user)

list :: DbPool -> Tenant -> AuthenticatedBy -> EitherT DbError IO [Project]
list pool tenant authenticated =
  (fmap . fmap) definitionProject . Traction.runDb pool $ case tenant of
    SingleTenant ->
      case authenticated of
        AuthenticatedByDesign _ ->
          Query.getAllProjects
        AuthenticatedByGithub _session user ->
          Query.getAccountProjects (userIdOf user)
    MultiTenant ->
      case authenticated of
        AuthenticatedByDesign _ ->
          pure []
        AuthenticatedByGithub _session user ->
          Query.getAccountProjects (userIdOf user)

-- FIX MTH error type
discover :: DbPool -> Tenant -> AuthenticatedBy -> Project -> EitherT Text IO (Maybe BuildId)
discover pool tenant authenticated project = do
  r <- firstT Traction.renderDbError $
    pick pool tenant authenticated project
  case r of
    Nothing ->
      pure Nothing
    Just _repository -> do
      i <- firstT Traction.renderDbError . Traction.runDb pool $
        Query.tick
      firstT Traction.renderDbError . Traction.runDb pool $
        Query.discover i project
      pure (Just i)

new :: DbPool -> AuthenticatedBy -> Project -> Repository -> EitherT DbError IO ()
new pool authenticated project repository =
  Traction.runDb pool $
    case authenticated of
      AuthenticatedByGithub _ u ->
        Query.createProject (OwnedByGithubUser <$> fmap githubUserLogin u) project repository
      AuthenticatedByDesign u ->
        Query.createProject (OwnedByBoris <$> u) project repository
