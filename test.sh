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
set -x

cd `dirname $0`

make --debug=b pip
.bootci/python.sh -m pip

make --debug=b ansible
command -v venv/bin/ansible

make --debug=b .bootci/venv-ansible1.4
.bootci/venv-ansible1.4/bin/ansible-playbook --version | grep 'ansible-playbook 1.4'

make --debug=b .bootci/venv-ansible1.5.4
.bootci/venv-ansible1.5.4/bin/ansible-playbook --version | grep 'ansible-playbook 1.5.4'

make --debug=b .bootci/venv-ansible1.9.2
.bootci/venv-ansible1.9.2/bin/ansible-playbook --version | grep 'ansible-playbook 1.9.2'

make --debug=b .bootci/venv-ansible2.1.0.0
.bootci/venv-ansible2.1.0.0/bin/ansible-playbook --version | grep 'ansible-playbook 2.1.0.0'
