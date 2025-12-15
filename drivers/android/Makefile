ccflags-y += -I$(src)			# needed for trace events

obj-$(CONFIG_ANDROID)			+= rom_notifier.o psi.o
obj-$(CONFIG_ANDROID_BINDER_IPC)	+= binder_linux.o
binder_linux-y := binder.o binder_alloc.o
binder_linux-$(CONFIG_ANDROID_BINDERFS)	+= binderfs.o
binder_linux-$(CONFIG_ANDROID_BINDER_IPC_SELFTEST) += binder_alloc_selftest.o
obj-$(CONFIG_ANDROID_VENDOR_HOOKS) += vendor_hooks.o
obj-$(CONFIG_ANDROID_SIMPLE_LMK)	+= simple_lmk.o
