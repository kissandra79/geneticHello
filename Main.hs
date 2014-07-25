import Control.Monad (replicateM)
import Data.List (concatMap, minimumBy)
import Data.Char (ord, chr)
import Moo.GeneticAlgorithm.Random (shuffle, randomSample)
import Moo.GeneticAlgorithm.Binary

--The goal is to evolve the string "hello"
--This is just a demonstration of a genetic
--algorithm

type Letter = Bool
type Word = Genome Letter
type Wordscore = Objective

lettersInWord = 5
rangeOfLetters = (ord 'a', ord 'z')
bitsPerLetter = bitsNeeded rangeOfLetters
bitsPerWord = bitsPerLetter * lettersInWord

targetWord = encodeWord "hello"


encodeWord :: String -> Word
encodeWord = concatMap (encodeBinary rangeOfLetters . ord)

decodeWord :: Word -> String
decodeWord = map (chr. decodeBinary rangeOfLetters) . splitEvery bitsPerLetter

wordFitness :: Word -> Wordscore
wordFitness = flip hammingDistance targetWord

randomWord :: Rand Word
randomWord = do
    rndstring <- do s <- randomSample lettersInWord "abcdefghijklmnopqrstuvwxyz"
                    shuffle s
    return $ encodeWord rndstring

randomWordPopulation :: Int -> Rand [Word]
randomWordPopulation n = replicateM n randomWord

bestGenomeInGeneration :: Population Letter -> String
bestGenomeInGeneration p = (decodeWord g) ++ " " ++ show gs where
    (g, gs) = minimumBy helper p
    helper (_, g1s) (_, g2s)= compare g1s g2s

population = 30
elitecount = 1
initialpopulation = randomWordPopulation population
selection = tournamentSelect Minimizing 2 (population - elitecount)
crossover = onePointCrossover 0.7
mutation = pointMutate 0.03
nextgen = nextGeneration Minimizing wordFitness selection elitecount crossover mutation
stop = (IfObjective ((==0) . minimum))


main = do
    p <- runIO initialpopulation (loopIO [ioact] stop nextgen)
    let best = bestGenomeInGeneration p
    putStrLn best where
        ioact :: IOHook Letter
        ioact = DoEvery 10 helper where
            helper g p = do
                let best = show g ++ " " ++ (bestGenomeInGeneration p)
                putStrLn best


--Checking out the library
{-fitnessTest = do                                                       -}
{-    mt <- newPureMT                                                    -}
{-    let pop = replicateM 10 randomWord                                 -}
{-        bits = evalRandom pop mt                                       -}
{-    mapM_ putStrLn $ map (\b -> show (decodeWord b, wordFitness b))bits-}

{-inbuiltInitialize = do                                                 -}
{-    mt <- newPureMT                                                    -}
{-    let pop = getRandomBinaryGenomes 10 bitsPerWord                    -}
{-        bits = evalRandom pop mt                                       -}
{-    mapM_ putStrLn $ map decodeWord bits                               -}

{-manualInitialize = do                                                  -}
{-    mt <- newPureMT                                                    -}
{-    let pop = replicateM 10 randomWord                                 -}
{-        bits = evalRandom pop mt                                       -}
{-    mapM_ putStrLn $ map decodeWord bits                               -}

