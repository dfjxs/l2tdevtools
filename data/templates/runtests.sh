#!/bin/bash
#
# Script to run tests on Travis-CI.
#
# This file is generated by l2tdevtools update-dependencies.py, any dependency
# related changes should be made in dependencies.ini.

# Exit on error.
set -e;

if test "$${TARGET}" = "jenkins";
then
	./config/jenkins/linux/run_end_to_end_tests.sh "travis";

elif test "$${TARGET}" = "pylint";
then
	pylint --version

	for FILE in `find ${paths_to_lint} -name \*.py`;
	do
		echo "Checking: $${FILE}";

		pylint --rcfile=.pylintrc $${FILE};
	done

elif test "$${TRAVIS_OS_NAME}" = "osx";
then
	PYTHONPATH=/Library/Python/2.7/site-packages/ /usr/bin/python ./run_tests.py;

	python ./setup.py build

	python ./setup.py sdist

	python ./setup.py bdist

	if test -f tests/end-to-end.py;
	then
		PYTHONPATH=. python ./tests/end-to-end.py --debug -c config/end-to-end.ini;
	fi

elif test -n "$${FEDORA_VERSION}";
then
	CONTAINER_NAME="fedora$${FEDORA_VERSION}";

	if test $${TRAVIS_PYTHON_VERSION} = "2.7";
	then
		docker exec $${CONTAINER_NAME} sh -c "export LANG=en_US.UTF-8; cd ${project_name} && python2 run_tests.py";
	else
		docker exec $${CONTAINER_NAME} sh -c "cd ${project_name} && python3 run_tests.py";
	fi

elif test -n "$${UBUNTU_VERSION}";
then
	CONTAINER_NAME="ubuntu$${UBUNTU_VERSION}";

	if test $${TRAVIS_PYTHON_VERSION} = "2.7";
	then
		docker exec $${CONTAINER_NAME} sh -c "export LANG=en_US.UTF-8; cd ${project_name} && python2 run_tests.py";
	else
		docker exec $${CONTAINER_NAME} sh -c "cd ${project_name} && python3 run_tests.py";
	fi

elif test "$${TRAVIS_OS_NAME}" = "linux";
then
	COVERAGE="/usr/bin/coverage";

	if ! test -x "$${COVERAGE}";
	then
		# Ubuntu has renamed coverage.
		COVERAGE="/usr/bin/python-coverage";
	fi

	if test -n "$${TOXENV}";
	then
		tox --sitepackages $${TOXENV};

	elif test "$${TRAVIS_PYTHON_VERSION}" = "2.7";
	then
		$${COVERAGE} erase
		$${COVERAGE} run --source=${project_name} --omit="*_test*,*__init__*,*test_lib*" ./run_tests.py
	else
		python ./run_tests.py

		python ./setup.py build

		python ./setup.py sdist

		python ./setup.py bdist

		TMPDIR="$${PWD}/tmp";
		TMPSITEPACKAGES="$${TMPDIR}/lib/python$${TRAVIS_PYTHON_VERSION}/site-packages";

		mkdir -p $${TMPSITEPACKAGES};

		PYTHONPATH=$${TMPSITEPACKAGES} python ./setup.py install --prefix=$${TMPDIR};

		if test -f tests/end-to-end.py;
		then
			PYTHONPATH=. python ./tests/end-to-end.py --debug -c config/end-to-end.ini;
		fi
	fi
fi
