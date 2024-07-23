import sys
import logging
logging.basicConfig(stream=sys.stderr)
sys.path.insert(0, "/home/ubuntu/testrepo/three-tier/python/test")

from app import app as application
