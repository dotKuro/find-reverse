module FindReverse
where

import Control.Monad (liftM)
import Control.Exception (catch)
import Data.List (sort)
import Data.Maybe (fromMaybe)
import System.Directory (getCurrentDirectory, getDirectoryContents)
import System.Environment (getArgs)
import System.FilePath (splitPath)
import System.IO (FilePath)

import qualified Data.Map.Strict as MapS

-- | This is the main function.
-- | This function will return the closest ancestor directory of one of the searched files.
-- | By default if no directory is found it will return "/". This can be modified with the -d/--default option.
findReverse :: IO ()
findReverse = do
  (opts, args) <- parseArgs `liftM` getArgs
  putStrLn =<< (fromMaybe $ defaultPath opts ) `liftM` (getPathOfFoundFile (sort args) =<< getCurrentDirectory)
  return ()
  where
    defaultPath opts = fromMaybe "/" (MapS.lookup "defaultPath" opts)

-- | This function will take a list of file names and an initial file path and will return a file path of the directory
-- | one of the files was found in. This function will return Nothing if no file was found.
-- | This function requires a sorted list of file names in order to work.
getPathOfFoundFile 
  :: [String] -- ^ sorted list of file names to be searched
  -> FilePath -- ^ file path that will be searched in recursivly
  -> IO (Maybe FilePath) -- ^ file path of the directory a file was found in
getPathOfFoundFile fileNames "" = return Nothing
getPathOfFoundFile fileNames curFilePath = do
  curDirContent <- sort `liftM` (getDirectoryContents $ curFilePath)
  if isElemOfLeftInRight fileNames curDirContent
    then return $ Just curFilePath
    else getPathOfFoundFile fileNames $ concat $ init $ splitPath $ curFilePath

-- | Function that takes to lists and checks if there is one element in the first list that is also element of the second list.
-- | Time complexity of this function is O(n) where n is the size of the larger list.
-- | In order to support this performance the given lists need to be sorted.
isElemOfLeftInRight :: (Ord a) 
  => [a] -- ^ list that contains the searched elements
  -> [a] -- ^ list in which the elements will be searched
  -> Bool -- ^ bool that indicates if a serached element was found
isElemOfLeftInRight (lElem:lElems) (rElem:rElems) = 
  case (compare lElem rElem) of
    EQ -> True
    GT -> isElemOfLeftInRight (lElem:lElems) rElems
    LT -> isElemOfLeftInRight lElems (rElem:rElems)
isElemOfLeftInRight _ _ = False

-- | This function parses the arguments and splits them into options and arguments.
-- | Arguments are just the file names that the programm will search for.
-- | Options are key-value pairs which can modify the behavoiur of the program.
parseArgs 
  :: [String] -- ^ raw command line arguments
  -> (MapS.Map String String, [String]) -- ^ parsed arguments split into options and arguments
parseArgs args = parseArgs' args MapS.empty
  where
    parseArgs' :: [String] -> (MapS.Map String String) -> (MapS.Map String String, [String])
    parseArgs' [] optMap = error noArgumentsProvided
    parseArgs' (arg1:args) optMap =
      case arg1 of
        "-d" -> processFirstOptionWithValue (arg1:args) optMap "defaultPath"
        "--default" -> processFirstOptionWithValue (arg1:args) optMap "defaultPath"
        _ -> (optMap, (arg1:args))
    processFirstOptionWithValue (arg1:[]) optMap filedName = error $ optionNeedsValue arg1
    processFirstOptionWithValue (arg1:args) optMap fieldName = parseArgs' (tail args) (MapS.insert fieldName (head args) optMap) 
   

-- Some convenience functions here

optionNeedsValue :: String -> String
optionNeedsValue opt = "option " ++ opt ++ " needs a value"

noArgumentsProvided :: String
noArgumentsProvided = "no arguments provided"
