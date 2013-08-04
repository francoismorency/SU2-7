########################################################################
# Pointwise - Proprietary software product of Pointwise, Inc.
#             Copyright (c) 1995-2012 Pointwise, Inc.
#             All rights reserved.
#
# module.mk for src\plugins\CaeXxxxx plugin
########################################################################

########################################################################
########################################################################
#
#                   DO NOT EDIT THIS FILE
#
# To simplify SDK upgrades, the standard module.mk file should NOT be edited.
#
# If you want to modify a plugin's build process, you should rename
# modulelocal-sample.mk to modulelocal.mk and edit its settings.
#
# See the comments in modulelocal-sample.mk for more information.
#
#                   DO NOT EDIT THIS FILE
#
########################################################################
########################################################################

CaeXxxxx_LOC := $(PLUGINS_LOC)/CaeXxxxx
CaeXxxxx_LIB := CaeXxxxx$(DBG_SUFFIX)
CaeXxxxx_CXX_LOC := $(CaeXxxxx_LOC)
CaeXxxxx_OBJ_LOC := $(PLUGINS_OBJ_LOC)/CaeXxxxx

CaeXxxxx_FULLNAME := lib$(CaeXxxxx_LIB).$(SHLIB_SUFFIX)
CaeXxxxx_FULLLIB := $(PLUGINS_DIST_DIR)/$(CaeXxxxx_FULLNAME)

CaeXxxxx_DEPS = \
	$(NULL)

MODCXXFILES := \
	runtimeWrite.c \
	$(NULL)

# IMPORTANT:
# Must recompile the shared/XXX/.c files for each plugin. These .c files
# include the plugin specific settings defined in the ./CaeXxxxx/*.h
# files.
CaeXxxxx_SRC := \
	$(PLUGINS_RT_PWPSRC) \
	$(PLUGINS_RT_PWGMSRC) \
	$(PLUGINS_RT_CAEPSRC) \
	$(patsubst %,$(CaeXxxxx_CXX_LOC)/%,$(MODCXXFILES))

CaeXxxxx_SRC_C := $(filter %.c,$(MODCXXFILES))
CaeXxxxx_SRC_CXX := $(filter %.cxx,$(MODCXXFILES))

# place the .o files generated from shared sources in the plugin's
# OBJ folder.
CaeXxxxx_OBJ := \
	$(patsubst %.c,$(CaeXxxxx_OBJ_LOC)/%.o,$(PLUGINS_RT_PWPFILES)) \
	$(patsubst %.c,$(CaeXxxxx_OBJ_LOC)/%.o,$(PLUGINS_RT_PWGMFILES)) \
	$(patsubst %.c,$(CaeXxxxx_OBJ_LOC)/%.o,$(PLUGINS_RT_CAEPFILES)) \
    $(patsubst %.c,$(CaeXxxxx_OBJ_LOC)/%.o,$(CaeXxxxx_SRC_C)) \
    $(patsubst %.cxx,$(CaeXxxxx_OBJ_LOC)/%.o,$(CaeXxxxx_SRC_CXX)) \
	$(NULL)

# To allow over-rides, search FIRST for headers in the local module's folder.
# For example, a site.h file in the local module's folder will preempt the
# file .../src/plugins/site.h
CaeXxxxx_INCL = \
	-I$(CaeXxxxx_LOC) \
	$(PLUGINS_RT_INCL) \
	$(NULL)

CaeXxxxx_LIBS = \
	$(NULL)

CaeXxxxx_MAINT_TARGETS := \
    CaeXxxxx_info \
    CaeXxxxx_install \
    CaeXxxxx_installnow \
    CaeXxxxx_uninstall


########################################################################
# Get (OPTIONAL) locally defined make targets. If a plugin developer wants
# to extend a plugin's make scheme, they should create a modulelocal.mk file
# in the plugin's base folder. To provide for future SDK upgrades, the standard
# module.mk file should NOT be directly edited.
#
ifneq ($(wildcard $(CaeXxxxx_LOC)/modulelocal.mk),)
    CaeXxxxx_DEPS += $(CaeXxxxx_LOC)/modulelocal.mk
    include $(CaeXxxxx_LOC)/modulelocal.mk
endif


# merge in plugin private settings

CaeXxxxx_OBJ += \
    $(patsubst %.c,$(CaeXxxxx_OBJ_LOC)/%.o,$(filter %.c,$(CaeXxxxx_CXXFILES_PRIVATE))) \
    $(patsubst %.cxx,$(CaeXxxxx_OBJ_LOC)/%.o,$(filter %.cxx,$(CaeXxxxx_CXXFILES_PRIVATE))) \
	$(NULL)

CaeXxxxx_SRC += \
	$(patsubst %,$(CaeXxxxx_CXX_LOC)/%,$(CaeXxxxx_CXXFILES_PRIVATE)) \
	$(NULL)

CaeXxxxx_INCL += $(CaeXxxxx_INCL_PRIVATE)
CaeXxxxx_LIBS += $(CaeXxxxx_LIBS_PRIVATE)
CaeXxxxx_CXXFLAGS += $(CaeXxxxx_CXXFLAGS_PRIVATE)
CaeXxxxx_LDFLAGS += $(CaeXxxxx_LDFLAGS_PRIVATE)
CaeXxxxx_MAINT_TARGETS += $(CaeXxxxx_MAINT_TARGETS_PRIVATE)
CaeXxxxx_DEPS += $(CaeXxxxx_DEPS_PRIVATE)

PLUGIN_MAINT_TARGETS += $(CaeXxxxx_MAINT_TARGETS)
PLUGIN_OBJ += $(CaeXxxxx_OBJ)

# add to plugin maint targets to the global .PHONY target
.PHONY: \
	$(CaeXxxxx_MAINT_TARGETS) \
	$(NULL)


########################################################################
# Set the final build macros
CaeXxxxx_CXXFLAGS := $(CXXFLAGS) $(PLUGINS_STDDEFS) $(CaeXxxxx_INCL) -DPWGM_HIDE_NOTPLUGINTYPE_API

ifeq ($(machine),macosx)
CaeXxxxx_LDFLAGS = -install_name "$(REL_BIN_TO_PW_LIB_DIR)/$(CaeXxxxx_FULLNAME)"
else
CaeXxxxx_LDFLAGS =
endif


########################################################################
# list of plugin's build targets
#
CaeXxxxx: $(CaeXxxxx_FULLLIB)

$(CaeXxxxx_FULLLIB): $(CaeXxxxx_OBJ) $(CaeXxxxx_DEPS)
	@echo "***"
	@echo "*** $@"
	@echo "***"
	@mkdir -p $(PLUGINS_DIST_DIR)
	$(SHLIB_LD) $(ARCH_FLAGS) $(CaeXxxxx_LDFLAGS) -o $(CaeXxxxx_FULLLIB) $(CaeXxxxx_OBJ) $(CaeXxxxx_LIBS) $(SYS_LIBS)

CaeXxxxx_info:
	@echo ""
	@echo "--------------------------------------------------------------"
ifeq ($(machine),macosx)
	otool -L -arch all $(CaeXxxxx_FULLLIB)
	@echo ""
endif
	file $(CaeXxxxx_FULLLIB)
	@echo "--------------------------------------------------------------"
	@echo ""


########################################################################
# list of plugin's intermediate targets
#
$(CaeXxxxx_OBJ_LOC):
	mkdir -p $(CaeXxxxx_OBJ_LOC)

#.......................................................................
# build .d files for the plugin and each of the shared runtime sources
# the .d files will be placed in the plugins OBJ folder CaeXxxxx_OBJ_LOC
$(CaeXxxxx_OBJ_LOC)/%.d: $(CaeXxxxx_CXX_LOC)/%.c
	@echo "Updating dependencies $(CaeXxxxx_OBJ_LOC)/$*.d"
	@mkdir -p $(CaeXxxxx_OBJ_LOC)
	@./depend.sh $(CaeXxxxx_OBJ_LOC) $(CaeXxxxx_CXXFLAGS) $< > $@

$(CaeXxxxx_OBJ_LOC)/%.d: $(PLUGINS_RT_PWPLOC)/%.c
	@echo "Updating dependencies $(CaeXxxxx_OBJ_LOC)/$*.d"
	@mkdir -p $(CaeXxxxx_OBJ_LOC)
	@./depend.sh $(CaeXxxxx_OBJ_LOC) $(CaeXxxxx_CXXFLAGS) $< > $@

$(CaeXxxxx_OBJ_LOC)/%.d: $(PLUGINS_RT_PWGMLOC)/%.c
	@echo "Updating dependencies $(CaeXxxxx_OBJ_LOC)/$*.d"
	@mkdir -p $(CaeXxxxx_OBJ_LOC)
	@./depend.sh $(CaeXxxxx_OBJ_LOC) $(CaeXxxxx_CXXFLAGS) $< > $@

$(CaeXxxxx_OBJ_LOC)/%.d: $(PLUGINS_RT_CAEPLOC)/%.c
	@echo "Updating dependencies $(CaeXxxxx_OBJ_LOC)/$*.d"
	@mkdir -p $(CaeXxxxx_OBJ_LOC)
	@./depend.sh $(CaeXxxxx_OBJ_LOC) $(CaeXxxxx_CXXFLAGS) $< > $@

#.......................................................................
# build .o files for the plugin and each of the shared runtime sources.
# the .o files will be placed in the plugins OBJ folder CaeXxxxx_OBJ_LOC
$(CaeXxxxx_OBJ_LOC)/%.o: $(CaeXxxxx_CXX_LOC)/%.c
	@echo "***"
	@echo "*** $*"
	@echo "***"
	@mkdir -p $(CaeXxxxx_OBJ_LOC)
	$(CXX) $(CaeXxxxx_CXXFLAGS) $(ARCH_FLAGS) -o $@ -c $<

$(CaeXxxxx_OBJ_LOC)/%.o: $(PLUGINS_RT_PWPLOC)/%.c
	@echo "***"
	@echo "*** $*"
	@echo "***"
	@mkdir -p $(CaeXxxxx_OBJ_LOC)
	$(CXX) $(CaeXxxxx_CXXFLAGS) $(ARCH_FLAGS) -o $@ -c $<

$(CaeXxxxx_OBJ_LOC)/%.o: $(PLUGINS_RT_PWGMLOC)/%.c
	@echo "***"
	@echo "*** $*"
	@echo "***"
	@mkdir -p $(CaeXxxxx_OBJ_LOC)
	$(CXX) $(CaeXxxxx_CXXFLAGS) $(ARCH_FLAGS) -o $@ -c $<

$(CaeXxxxx_OBJ_LOC)/%.o: $(PLUGINS_RT_CAEPLOC)/%.c
	@echo "***"
	@echo "*** $*"
	@echo "***"
	@mkdir -p $(CaeXxxxx_OBJ_LOC)
	$(CXX) $(CaeXxxxx_CXXFLAGS) $(ARCH_FLAGS) -o $@ -c $<


########################################################################
# list of plugin's clean targets
#
CaeXxxxx_cleandep:
	-$(RMR) $(CaeXxxxx_OBJ_LOC)/*.d

CaeXxxxx_clean:
	-$(RMR) $(CaeXxxxx_OBJ_LOC)/*.{d,o}

CaeXxxxx_distclean: CaeXxxxx_clean
	-$(RMF) $(CaeXxxxx_FULLLIB) > /dev/null 2>&1

########################################################################
# list of plugin's clean targets
#
CaeXxxxx_install: install_validate CaeXxxxx_installnow
	@echo "CaeXxxxx Installed to '$(PLUGIN_INSTALL_FULLPATH)'"

CaeXxxxx_installnow:
	-@$(CP) $(CaeXxxxx_FULLLIB) "$(PLUGIN_INSTALL_FULLPATH)/libCaeXxxxx.$(SHLIB_SUFFIX)"

CaeXxxxx_uninstall:
	@echo "CaeXxxxx Uninstalled from '$(PLUGIN_INSTALL_FULLPATH)'"
	-@$(RMF) "$(PLUGIN_INSTALL_FULLPATH)/libCaeXxxxx.$(SHLIB_SUFFIX)"