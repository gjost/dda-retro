SHELL = /bin/bash
DEBIAN_CODENAME := $(shell lsb_release -sc)

INSTALL_BASE=/usr/local/src
INSTALL_RETRO=$(INSTALL_BASE)/dda-retro

VIRTUALENV=$(INSTALL_RETRO)/venv/ddaretro
SETTINGS=$(INSTALL_RETRO)/ddaretro/ddaretro/settings.py

CONF_BASE=/etc/dda
CONF_PRODUCTION=$(CONF_BASE)/ddaretro.cfg
CONF_LOCAL=$(CONF_BASE)/ddaretro-local.cfg
CONF_SECRET=$(CONF_BASE)/ddaretro-secret-key.txt

SQLITE_BASE=/var/lib/dda
LOG_BASE=/var/log/dda

MEDIA_BASE=/var/www/ddaretro
MEDIA_ROOT=$(MEDIA_BASE)/media
STATIC_ROOT=$(MEDIA_BASE)/static

SUPERVISOR_GUNICORN_CONF=/etc/supervisor/conf.d/ddaretro.conf
NGINX_CONF=/etc/nginx/sites-available/ddaretro.conf
NGINX_CONF_LINK=/etc/nginx/sites-enabled/ddaretro.conf


.PHONY: help


help:
	@echo "dda-retro Install Helper"
	@echo ""
	@echo "install - Does a complete install. Idempotent, so run as many times as you like."
	@echo "          IMPORTANT: Run 'adduser ddr' first to install ddr user and group."
	@echo "          Installation instructions: make howto-install"
	@echo "Subcommands:"
	@echo "    install-prep    - Various preperatory tasks"
	@echo "    install-daemons - Installs Nginx, Redis, Elasticsearch"
	@echo "    get-app         - Runs git-clone or git-pull on ddr-cmdln and dda-retro"
	@echo "    install-app     - Just installer tasks for ddr-cmdln and dda-retro"
	@echo "    install-static  - Downloads static media (Bootstrap, jquery, etc)"
	@echo ""
	@echo ""
	@echo "migrate  - Initialize or update Django app's database tables."
	@echo ""
	@echo "branch BRANCH=[branch] - Switches dda-retro and supporting repos to [branch]."
	@echo ""
	@echo "reload  - Reloads supervisord and nginx configs"
	@echo "reload-nginx"
	@echo "reload-supervisors"
	@echo ""
	@echo "restart - Restarts all servers"
	@echo "restart-elasticsearch"
	@echo "restart-redis"
	@echo "restart-nginx"
	@echo "restart-supervisord"
	@echo ""
	@echo "status  - Server status"
	@echo ""
	@echo "uninstall - Deletes 'compiled' Python files. Leaves build dirs and configs."
	@echo "clean   - Deletes files created by building the program. Leaves configs."
	@echo ""
	@echo "More install info: make howto-install"

howto-install:
	@echo "HOWTO INSTALL"
	@echo "- Basic Debian netinstall"
	@echo "- edit /etc/network/interfaces"
	@echo "- reboot"
	@echo "- apt-get install openssh fail2ban ufw"
	@echo "- ufw allow 22/tcp"
	@echo "- ufw allow 80/tcp"
	@echo "- ufw enable"
	@echo "- apt-get install make"
	@echo "- adduser ddr"
	@echo "- git clone $(SRC_REPO_PUBLIC) $(INSTALL_RETRO)"
	@echo "- cd $(INSTALL_RETRO)/ddaretro"
	@echo "- make install"
	@echo "- [make branch BRANCH=develop]"
	@echo "- [make install]"
	@echo "- make migrate"
	@echo "- make restart"

help-all:
	@echo "install - Do a fresh install"
	@echo "install-prep    - git-config, add-user, apt-update, install-misc-tools"
	@echo "install-daemons - install-nginx install-redis install-elasticsearch"
	@echo "install-ddr     - install-ddr-cmdln install-dda-retro"
	@echo "install-static  - "
	@echo "update  - Do an update"
	@echo "restart - Restart servers"
	@echo "status  - Server status"
	@echo "install-configs - "
	@echo "update-ddr - "
	@echo "uninstall - "
	@echo "clean - "


get: get-dda-retro

install: install-prep get-app install-app install-daemons install-static install-configs

uninstall: uninstall-app uninstall-configs

clean: clean-app


install-prep: apt-update install-core git-config install-misc-tools

apt-update:
	@echo ""
	@echo "Package update ---------------------------------------------------------"
	apt-get --assume-yes update

apt-upgrade:
	@echo ""
	@echo "Package upgrade --------------------------------------------------------"
	apt-get --assume-yes upgrade

install-core:
	apt-get --assume-yes install bzip2 curl gdebi-core git-core logrotate ntp p7zip-full wget

git-config:
	git config --global alias.st status
	git config --global alias.co checkout
	git config --global alias.br branch
	git config --global alias.ci commit

install-misc-tools:
	@echo ""
	@echo "Installing miscellaneous tools -----------------------------------------"
	apt-get --assume-yes install ack-grep byobu elinks htop mg multitail


install-daemons: install-nginx install-redis

install-nginx:
	@echo ""
	@echo "Nginx ------------------------------------------------------------------"
	apt-get --assume-yes install nginx

install-redis:
	@echo ""
	@echo "Redis ------------------------------------------------------------------"
	apt-get --assume-yes install redis-server

install-virtualenv:
	@echo ""
	@echo "install-virtualenv -----------------------------------------------------"
	apt-get --assume-yes install python-pip python-virtualenv
	test -d $(VIRTUALENV) || virtualenv --distribute --setuptools $(VIRTUALENV)

install-setuptools: install-virtualenv
	@echo ""
	@echo "install-setuptools -----------------------------------------------------"
	apt-get --assume-yes install python-dev
	source $(VIRTUALENV)/bin/activate; \
	pip install -U setuptools


get-app: get-dda-retro

install-app: install-virtualenv install-setuptools install-dda-retro install-configs install-daemon-configs

uninstall-app: uninstall-dda-retro uninstall-configs uninstall-daemon-configs

clean-app: clean-dda-retro


get-dda-retro:
	@echo ""
	@echo "get-dda-retro ---------------------------------------------------------"
	git pull

install-dda-retro: clean-dda-retro
	@echo ""
	@echo "install-dda-retro -----------------------------------------------------"
	apt-get --assume-yes install imagemagick sqlite3 supervisor
	source $(VIRTUALENV)/bin/activate; \
	pip install -U -r $(INSTALL_RETRO)/requirements.txt
# logs dir
	-mkdir $(LOG_BASE)
	chown -R ddr.root $(LOG_BASE)
	chmod -R 755 $(LOG_BASE)
# sqlite db dir
	-mkdir $(SQLITE_BASE)
	chown -R ddr.root $(SQLITE_BASE)
	chmod -R 755 $(SQLITE_BASE)

uninstall-dda-retro:
	@echo ""
	@echo "uninstall-dda-retro ---------------------------------------------------"
	source $(VIRTUALENV)/bin/activate; \
	cd $(INSTALL_RETRO)/ddaretro && pip uninstall -y -r $(INSTALL_RETRO)/requirements.txt
	-rm /usr/local/lib/python2.7/dist-packages/ddaretro-*
	-rm -Rf /usr/local/lib/python2.7/dist-packages/ddaretro

clean-dda-retro:
	-rm -Rf $(INSTALL_RETRO)/ddaretro/src


migrate:
	source $(VIRTUALENV)/bin/activate; \
	cd $(INSTALL_RETRO)/ddaretro && python manage.py migrate --noinput
	chown -R ddr.root $(SQLITE_BASE)
	chmod -R 750 $(SQLITE_BASE)
	chown -R ddr.root $(LOG_BASE)
	chmod -R 755 $(LOG_BASE)

branch:
	cd $(INSTALL_RETRO)/ddaretro; python ./bin/git-checkout-branch.py $(BRANCH)


install-static: get-ddaretro-assets install-ddaretro-assets

clean-static: clean-ddaretro-assets

get-ddaretro-assets:
	@echo ""
	@echo "get assets --------------------------------------------------------------"
	-mkdir -p /tmp/$(ASSETS_VERSION)
	wget -nc -P /tmp http://$(PACKAGE_SERVER)/$(ASSETS_TGZ)

install-ddaretro-assets:
	@echo ""
	@echo "install assets ----------------------------------------------------------"
	rm -Rf $(ASSETS_INSTALL_DIR)
	-mkdir -p $(ASSETS_INSTALL_DIR)
	-mkdir -p /tmp/$(ASSETS_VERSION)
	tar xzf /tmp/$(ASSETS_TGZ) -C /tmp/$(ASSETS_VERSION)
	mv /tmp/$(ASSETS_VERSION)/assets/* $(ASSETS_INSTALL_DIR)

clean-ddaretro-assets:
	@echo ""
	@echo "clean assets ------------------------------------------------------------"
	-rm -Rf $(ASSETS_INSTALL_DIR)
	-mkdir -p /tmp/$(ASSETS_VERSION)


install-configs:
	@echo ""
	@echo "configuring dda-retro -------------------------------------------------"
# base settings file
# /etc/ddr/ddaretro.cfg must be readable by all
# /etc/ddr/ddaretro-local.cfg must be readable by ddr but contains sensitive info
	-mkdir /etc/dda
	cp $(INSTALL_RETRO)/conf/ddaretro.cfg $(CONF_PRODUCTION)
	chown root.root $(CONF_PRODUCTION)
	chmod 644 $(CONF_PRODUCTION)
	touch $(CONF_LOCAL)
	chown ddr.root $(CONF_LOCAL)
	chmod 640 $(CONF_LOCAL)
	python -c 'import random; print "".join([random.choice("abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)") for i in range(50)])' > $(CONF_SECRET)
	chown ddr.root $(CONF_SECRET)
	chmod 640 $(CONF_SECRET)
# web app settings
	cp $(INSTALL_RETRO)/conf/settings.py $(SETTINGS)
	chown root.root $(SETTINGS)
	chmod 644 $(SETTINGS)

uninstall-configs:
	-rm $(SETTINGS)
	-rm $(CONF_PRODUCTION)
	-rm $(CONF_SECRET)


install-daemon-configs:
	@echo ""
	@echo "install-daemon-configs -------------------------------------------------"
# nginx settings
	cp $(INSTALL_RETRO)/conf/ddaretro.conf $(NGINX_CONF)
	chown root.root $(NGINX_CONF)
	chmod 644 $(NGINX_CONF)
	-ln -s $(NGINX_CONF) $(NGINX_CONF_LINK)
	-rm /etc/nginx/sites-enabled/default
# supervisord
	cp $(INSTALL_RETRO)/conf/gunicorn_ddaretro.conf $(SUPERVISOR_GUNICORN_CONF)
	chown root.root $(SUPERVISOR_GUNICORN_CONF)
	chmod 644 $(SUPERVISOR_GUNICORN_CONF)

uninstall-daemon-configs:
	-rm $(NGINX_CONF)
	-rm $(NGINX_CONF_LINK)


reload: reload-nginx reload-supervisor

reload-nginx:
	/etc/init.d/nginx reload

reload-supervisor:
	supervisorctl reload

reload-app: reload-supervisor


stop: stop-redis stop-nginx stop-supervisor

stop-redis:
	/etc/init.d/redis-server stop

stop-nginx:
	/etc/init.d/nginx stop

stop-supervisor:
	/etc/init.d/supervisor stop

stop-app:
	supervisorctl stop ddaretro


restart: restart-redis restart-nginx restart-supervisor

restart-redis:
	/etc/init.d/redis-server restart

restart-nginx:
	/etc/init.d/nginx restart

restart-supervisor:
	/etc/init.d/supervisor restart

restart-app:
	supervisorctl restart ddaretro


# just Redis and Supervisor
restart-minimal: restart-redis stop-nginx restart-supervisor


status:
	@echo "------------------------------------------------------------------------"
	-/etc/init.d/redis-server status
	@echo " - - - - -"
	-/etc/init.d/nginx status
	@echo " - - - - -"
	-supervisorctl status
	@echo ""

git-status:
	@echo "------------------------------------------------------------------------"
	cd $(INSTALL_RETRO) && git status
