
from distutils.core import setup
from git import Repo

repo = Repo()

# Get version before adding version file
ver = repo.git.describe('--tags')

# append version constant to package init
with open('python/epix_hr_core/__init__.py','a') as vf:
    vf.write(f'\n__version__="{ver}"\n')

setup (
   name='epix_hr_core',
   version=ver,
   packages=['epix_hr_core', ],
   package_dir={'':'python'},
)

