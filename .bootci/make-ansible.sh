#!/bin/sh
# Copyright (C) 2017 Wesley Tanaka
#
# This file is part of github.com/wtanaka/bootci
#
# github.com/wtanaka/bootci is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# github.com/wtanaka/bootci is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with github.com/wtanaka/bootci.  If not, see
# <http://www.gnu.org/licenses/>.

set -e

DIRNAME="`dirname $0`"
VERSION="$1"
TARGET="$DIRNAME/venv-ansible$VERSION"
PYTHON="${DIRNAME}"/python.sh

pip_local()
{
  "${PYTHON}" -m pip "$@"
}

PIP=pip_local

make -f "$DIRNAME"/python.mk virtualenv

if [ ! -x "$TARGET"/bin/ansible ]; then
  # without ANSIBLE_LIBRARY, package tries to write to /usr/share
  # without --no-use-wheel, module command scripts end up in
  # ansible1.6.1/lib/python2.7/site-packages/
  #    ANOTHER_PATH.../ansible1.6.1/ANSIBLE_LIBRARY/commands/raw
  # easy_install also puts module command scripts in site-packages
  #
  # pip install 'requests[security]'
  #    for https://stackoverflow.com/q/29099404/2034423
  # pip install 'pynacl' because its source distribution does not
  #    compile cleanly on CircleCI, so we want to install with wheel
  if [ ! -d "$TARGET" ]; then
    "$PYTHON" -m virtualenv "$TARGET";
    (
      . "$TARGET"/bin/activate ;
      "$PIP" --version;
      "$PIP" install --upgrade pip;
      "$PIP" --version;
      if grep "^${VERSION}$" "$DIRNAME"/ansible-broken-wheels.txt > /dev/null; then
        ANSIBLE_LIBRARY=share/ansible;
        export ANSIBLE_LIBRARY;
        INSTALL_OPTS=--no-use-wheel;
        "$PIP" install 'pynacl';
      fi;
      "$PIP" install 'requests[security]';
      "$PIP" $PIP_OPTS install $INSTALL_OPTS ansible=="$VERSION";
      if [ ! -x "$TARGET"/bin/ansible-playbook ]; then
        >&2 echo "Missing "$TARGET"/bin/ansible-playbook";
        rm -rf "$TARGET";
        exit 1;
      fi;
    );
  fi
fi
