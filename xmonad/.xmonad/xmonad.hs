-- -*- eval: (flycheck-mode -1) -*-
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

import           Control.Arrow                  ( Arrow
                                                , (***)
                                                )
import           Control.Exception              ( catch
                                                , SomeException
                                                )
import qualified Data.Aeson                    as Aeson
import           Data.Aeson                     ( FromJSON )
import qualified Data.Text                     as T
import           Data.Text                      ( Text )
import qualified Data.ByteString.Lazy          as BS
import           Data.ByteString.Lazy           ( ByteString )
import qualified Data.Map                      as M
import           Data.Map                       ( Map )
import           GHC.Generics                   ( Generic )
import           System.Directory               ( getHomeDirectory )
import           System.Exit                    ( ExitCode(..)
                                                , exitWith
                                                )

-- xmonad core
import           XMonad
import qualified XMonad.StackSet               as W

-- xmonad contrib
import           XMonad.Actions.Navigation2D    ( Direction2D(..)
                                                , windowGo
                                                , windowSwap
                                                , withNavigation2DConfig
                                                )
import           XMonad.Hooks.EwmhDesktops      ( ewmh
                                                , fullscreenEventHook
                                                )
import           XMonad.Layout.NoBorders        ( noBorders
                                                , smartBorders
                                                )
import           XMonad.Layout.ResizableTile    ( MirrorResize(..)
                                                , ResizableTall(..)
                                                )
import           XMonad.Util.SpawnOnce          ( spawnOnce )

-- | Colors type derived from pywal generated json
--
data Colors = Colors
  { special :: SpecialColors
  , colors  :: ColorPalette
  } deriving (Show, Generic)

data SpecialColors = SpecialColors
  { background :: !Text
  , foreground :: !Text
  , cursor     :: !Text
  } deriving (Show, Generic)

data ColorPalette = ColorPalette
  { color0  :: !Text
  , color1  :: !Text
  , color2  :: !Text
  , color3  :: !Text
  , color4  :: !Text
  , color5  :: !Text
  , color6  :: !Text
  , color7  :: !Text
  , color8  :: !Text
  , color9  :: !Text
  , color10 :: !Text
  , color11 :: !Text
  , color12 :: !Text
  , color13 :: !Text
  , color14 :: !Text
  , color15 :: !Text
  } deriving (Show, Generic)

instance FromJSON Colors
instance FromJSON SpecialColors
instance FromJSON ColorPalette

-- | The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = tiled ||| Mirror tiled ||| noBorders Full
 where
  -- Unlike Tall, ResizableTall can resize windows vertically
  tiled   = ResizableTall nmaster delta ratio []
  -- The default number of windows in the master pane
  nmaster = 1
  -- Default proportion of screen occupied by master pane
  ratio   = 1 / 2
  -- Percent of screen to increment by when resizing panes
  delta   = 3 / 100

-- | The xmonad key bindings. Add, modify or remove key bindings here.
--
-- Media keys, application shortcuts, etc defined in sxhkd.
--
myKeys :: XConfig Layout -> Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig { XMonad.modMask = modMask }) =
  M.fromList
    $
       -- Close focused window.
       [ ( (modMask .|. shiftMask, xK_q)
         , kill
         )

       -- Launch dmenu.
       , ( (modMask, xK_p)
         , spawn "dmenu_run"
         )

       -- Cycle through the available layout algorithms.
       , ( (modMask, xK_space)
         , sendMessage NextLayout
         )

       --  Reset the layouts on the current workspace to default.
       , ( (modMask .|. shiftMask, xK_space)
         , setLayout $ XMonad.layoutHook conf
         )

       -- Resize viewed windows to the correct size.
       , ( (modMask, xK_n)
         , refresh
         )

       -- Move focus to the next window.
       , ( (modMask, xK_Tab)
         , windows W.focusDown
         )

       -- Move focus to the previous window.
       , ( (modMask .|. shiftMask, xK_Tab)
         , windows W.focusUp
         )

       -- Swap the focused window and the master window.
       , ( (modMask, xK_m)
         , windows W.swapMaster
         )

       -- Focus window toward the left
       , ( (modMask, xK_h)
         , windowGo L False
         )

       -- Focus window toward the right
       , ( (modMask, xK_l)
         , windowGo R False
         )

       -- Focus window toward the top
       , ( (modMask, xK_k)
         , windowGo U False
         )

       -- Focus window toward the bottom
       , ( (modMask, xK_j)
         , windowGo D False
         )

       -- Focus window toward the left
       , ( (modMask .|. shiftMask, xK_h)
         , windowSwap L False
         )

       -- Focus window toward the right
       , ( (modMask .|. shiftMask, xK_l)
         , windowSwap R False
         )

       -- Focus window toward the top
       , ( (modMask .|. shiftMask, xK_k)
         , windowSwap U False
         )

       -- Focus window toward the bottom
       , ( (modMask .|. shiftMask, xK_j)
         , windowSwap D False
         )

       -- Shrink master horizontally. Resize left.
       , ( (modMask .|. controlMask, xK_h)
         , sendMessage Shrink
         )

       -- Expand master horizontally. Resize right.
       , ( (modMask .|. controlMask, xK_l)
         , sendMessage Expand
         )

       -- Shrink master vertically. Resize down.
       , ( (modMask .|. controlMask, xK_j)
         , sendMessage MirrorShrink
         )

       -- Expand master vertically. Resize up.
       , ( (modMask .|. controlMask, xK_k)
         , sendMessage MirrorExpand
         )

       -- Push window back into tiling.
       , ( (modMask, xK_t)
         , withFocused $ windows . W.sink
         )

       -- Increment the number of windows in the master area.
       , ( (modMask, xK_comma)
         , sendMessage (IncMasterN 1)
         )

       -- Decrement the number of windows in the master area.
       , ( (modMask, xK_period)
         , sendMessage (IncMasterN (-1))
         )

       -- Quit xmonad.
       , ( (modMask .|. shiftMask .|. controlMask, xK_q)
         , io (exitWith ExitSuccess)
         )

       -- Restart xmonad.
       , ((modMask, xK_q), restart "xmonad" True)
       ]
    ++

       -- mod-[1..9], Switch to workspace N
       -- mod-shift-[1..9], Move client to workspace N
       [ ((m .|. modMask, k), windows $ f i)
       | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
       , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
       ]
    ++

       -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
       -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
       [ ( (m .|. modMask, key)
         , screenWorkspace sc >>= flip whenJust (windows . f)
         )
       | (key, sc) <- zip [xK_w, xK_e, xK_r] [0 ..]
       , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
       ]

-- | Tuple map utility function
--
mapTuple :: Arrow a => a b c -> a (b, b) (c, c)
mapTuple f = f *** f

-- | A wrapper for ByteString.readFile.  It returns empty string where
-- there would usually be an exception.
--
safeReadFile :: FilePath -> IO ByteString
safeReadFile file = BS.readFile file `catch` returnEmpty
 where
  returnEmpty :: SomeException -> IO ByteString
  returnEmpty _ = return ""

-- | Get a pair of colors.  Trys to fetch colors generated by wal.
-- Returns ("#222222", "#808080") if cannot get wal colors.
--
getColors :: IO (Text, Text)
getColors = do
  home <- getHomeDirectory
  json <- safeReadFile $ home ++ "/.cache/wal/colors.json"
  return $ case Aeson.decode json :: Maybe Colors of
    Nothing  -> ("#222222", "#808080")
    Just col -> (background $ special col, color6 $ colors col)

main :: IO ()
main = do
  (normalColor, focusedColor) <- mapTuple T.unpack <$> getColors
  xmonad $ withNavigation2DConfig def $ ewmh def
    { terminal           = "~/scripts/term.sh"
    , modMask            = mod4Mask
    , keys               = myKeys
    , borderWidth        = 2
    , normalBorderColor  = normalColor
    , focusedBorderColor = focusedColor
    , handleEventHook    = fullscreenEventHook
    , layoutHook         = smartBorders myLayout
    , startupHook        = spawnOnce "~/scripts/startup.sh --fix-cursor"
    }
