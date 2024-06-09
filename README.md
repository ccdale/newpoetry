# New Poetry Project

This generates a new Python project using Poetry.

## Usage

```bash
scripts/newpkg.sh packagename
```

## Features

* Uses the excellent Makefile from https://github.com/hackersandslackers
* Uses Poetry for dependency management
* Initialises the pyproject.toml file with the latest versions of the development tools
    * black
    * flake8
    * isort
    * pytest
    * pytest-cov
* Adds a .gitignore file
* Uses my own ccaerrors and ccalogging packages
* Adds a blank README.md file
* The project is placed in the directory $HOME/src/packagename
* The project directory is initialised as a git repository
* It's a shell script, so it's easy to modify to suit your own needs
