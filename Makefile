
SHELL = /bin/sh

# ------------------------------------------------
#   DEFINITIONS
# ------------------------------------------------

#   installation tools
SHTOOL          = ./shtool
MKDIR           = $(SHTOOL) mkdir -p -f -m 755
VERSION_TOOL    = $(SHTOOL) version

# ------------------------------------------------
#   THE CONFIGURATION SUPPORT
# ------------------------------------------------

shtool:
	@shtoolize echo version install fixperm mkdir path

# ------------------------------------------------
#   THE RELEASE STUFF
# ------------------------------------------------

TAR    = tar       # where to find GNU Tar
FIND   = find      # where to find a good Find tool
GZIP   = gzip      # where to find GNU Zip
NAME   = child     # name of maintainer who rolls the tarball

NEWVERS = \
    $(VERSION_TOOL) -l perl -p Account $$OPT version.pl; \
    V=`$(VERSION_TOOL) -l perl -d long version.pl`;\
    sed -e "s/version .*(.*)/version $$V/g" < README.pod > README.n && mv README.n README.pod

UPDATEVERS = \
    V=`$(VERSION_TOOL) -l perl -d short version.pl`; \
    $(VERSION_TOOL) -l perl -p Account -s $$V version.pl; \
    V=`$(VERSION_TOOL) -l perl -d long version.pl`; \
    sed -e "s/version .*(.*)/version $$V/g" <README.pod >README.n && mv README.n README.pod;

_GETDISTINFO = \
    _version=`$(VERSION_TOOL) -l perl -d short version.pl`; \
    _date=`date '+%Y%m%d'`;

_BUILDDIST = \
    echo "Creating tarball..."; \
    awk '{print $$1}'  MANIFEST | xargs $(TAR) cvf - |\
    tarcust --user-name=$(NAME) \
              --group-name=account \
              --prefix="$${_distname}" |\
    $(GZIP) --best - >$${_tarball}; \
    ls -l $${_tarball}; \
    echo "Done"

release: fixperm
	set -e; $(_GETDISTINFO) \
    _distname="account-$${_version}"; \
    _tarball="$${_distname}.tar.gz"; \
    echo "Release Distribution: Account Version $$_version"; \
	echo "Building docs";\
	pod2text README.pod > README;\
	pod2text doc/Database.pod > doc/Database.txt;\
	pod2text doc/Install.pod > doc/Install.txt;\
	pod2text doc/Usage.pod > doc/Usage.txt;\
    $(_BUILDDIST)

snap: fixperm
	set -e; $(_GETDISTINFO) \
    _distname="account-$${_date}"; \
    _tarball="$${_distname}.tar.gz"; \
    echo "Snap of whole source tree: Account Version $$_version as of $$_date"; \
    $(_BUILDDIST)

manifest:
	find . -print | sed -e "s%^./%%" | egrep -v -f .exclude > MANIFEST

new-version:
	OPT=-iv; $(NEWVERS)

new-revision:
	OPT=-ir; $(NEWVERS)

new-patchlevel:
	OPT=-iP; $(NEWVERS)

new-release:
	OPT=-s$(R); $(NEWVERS)

update-version:
	$(UPDATEVERS)

fixperm:
	$(SHTOOL) fixperm *

##EOF##
