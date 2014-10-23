{-# LANGUAGE CPP #-}
module Language.Haskell.Ghcid.Terminal(
    terminalSize, terminalTopmost
    ) where

#if !defined(mingw32_HOST_OS)
import qualified System.Console.Terminal.Size as Terminal
import System.IO (stdout)
import Data.Tuple.Extra
#endif

#if defined(mingw32_HOST_OS)
import Data.Word
c_SWP_NOSIZE = 1 :: Word32
c_SWP_NOMOVE = 2 :: Word32
foreign import stdcall unsafe "windows.h GetConsoleWindow"
    c_GetConsoleWindow :: IO Int

foreign import stdcall unsafe "windows.h SetWindowPos"
    c_SetWindowPos :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> IO Int

c_HWND_TOPMOST :: Int
c_HWND_TOPMOST = -1
#endif


-- | Figure out the size of the current terminal, width\/height, or return 'Nothing'.
terminalSize :: IO (Maybe (Int, Int))
#if defined(mingw32_HOST_OS)
terminalSize = return Nothing
#else
terminalSize = do
    s <- Terminal.hSize stdout
    return $ fmap (Terminal.width &&& Terminal.height) s
#endif


-- | Raise the current terminal on top of all other screens, if you can.
terminalTopmost :: IO ()
#if defined(mingw32_HOST_OS)
terminalTopmost = do
    wnd <- c_GetConsoleWindow
    c_SetWindowPos wnd c_HWND_TOPMOST 0 0 0 0 (c_SWP_NOMOVE .|. c_SWP_NOSIZE)
    return ()
#else
terminalTopmost = return ()
#endif
