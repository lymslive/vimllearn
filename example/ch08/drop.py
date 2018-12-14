#! /usr/bin/env python
import sys, os
if len(sys.argv) > 1:
    fn = os.path.abspath(sys.argv[1])
    sys.stdout.write('\x1b]51;["drop", "%s"]\x07'%fn)

# https://www.zhihu.com/question/278228687/answer/413375553
