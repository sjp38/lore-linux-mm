Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A8A968D005B
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 17:09:20 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/39] Cleanup WARN #defines
Date: Sat, 30 Oct 2010 14:08:17 -0700
Message-Id: <cover.1288471897.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: Jiri Kosina <trivial@kernel.org>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org, linux-tegra@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-pm@lists.linux-foundation.org, discuss@x86-64.org, linux-acpi@vger.kernel.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-media@vger.kernel.org, socketcan-core@lists.berlios.de, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org, devel@open-fcoe.org, linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org
List-ID: <linux-mm.kvack.org>

WARN uses sometimes use KERN_<level> but mostly don't
have any prefix.

Change the WARN macros and the warn_slowpath function to preface
KERN_WARNING and remove all the KERN_<level> uses from WARN sites.

Neatening clean up of include/asm-generic/bug.h

Update WARN macros
Add KERN_WARNING to WARN output
Remove any KERN_<level> from WARN uses
Coalesce formats
Align WARN arguments
Add some missing newlines to WARN uses
Add some missing first test argument (1, fmt, args) to WARN uses

Joe Perches (39):
  include/asm-generic/bug.h: Update WARN macros
  arch/alpha: Update WARN uses
  arch/arm: Update WARN uses
  arch/powerpc: Update WARN uses
  arch/x86: Update WARN uses
  drivers/acpi: Update WARN uses
  drivers/base: Update WARN uses
  drivers/block: Update WARN uses
  drivers/cpuidle: Update WARN uses
  drivers/firewire: Update WARN uses
  drivers/firmware: Update WARN uses
  drivers/gpio: Update WARN uses
  drivers/gpu/drm: Update WARN uses
  drivers/media/video: Update WARN uses
  drivers/mfd: Update WARN uses
  drivers/net/can: Update WARN uses
  drivers/net/usb: Update WARN uses
  drivers/net/wireless/iwlwifi: Update WARN uses
  drivers/regulator: Update WARN uses
  drivers/scsi/fcoe: Update WARN uses
  drivers/staging: Update WARN uses
  drivers/usb/musb: Update WARN uses
  drivers/video/omap2/dss: Update WARN uses
  fs/nfsd: Update WARN uses
  fs/notify/inotify: Update WARN uses
  fs/sysfs: Update WARN uses
  fs/proc: Update WARN uses
  fs: Update WARN uses
  include/linux/device.h: Update WARN uses
  kernel/irq: Update WARN uses
  kernel/panic.c: Update warn_slowpath to use %pV
  kernel: Update WARN uses
  lib: Update WARN uses
  mm: Update WARN uses
  net/core/dev.c: Update WARN uses
  net/ipv4/tcp.c: Update WARN uses
  net/mac80211: Update WARN uses
  net/rfkill/input.c: Update WARN uses
  sound/soc/codecs/wm_hubs.c: Update WARN uses

 arch/alpha/kernel/pci-sysfs.c                |   14 ++--
 arch/arm/mach-davinci/clock.c                |    4 +-
 arch/arm/mach-davinci/da830.c                |    2 +-
 arch/arm/mach-davinci/da850.c                |   12 ++--
 arch/arm/mach-omap2/clkt_clksel.c            |   12 ++--
 arch/arm/mach-omap2/clock.c                  |   16 ++--
 arch/arm/mach-omap2/devices.c                |    4 +-
 arch/arm/mach-omap2/omap_hwmod.c             |   47 +++++++-----
 arch/arm/mach-omap2/pm34xx.c                 |    7 +-
 arch/arm/mach-omap2/serial.c                 |    2 +-
 arch/arm/mach-omap2/timer-gp.c               |    3 +-
 arch/arm/mach-tegra/clock.c                  |    3 +-
 arch/arm/mach-tegra/timer.c                  |    2 +-
 arch/arm/mach-u300/padmux.c                  |   14 +---
 arch/arm/plat-omap/omap-pm-noop.c            |   10 ++--
 arch/powerpc/kernel/hw_breakpoint.c          |    4 +-
 arch/x86/kernel/acpi/boot.c                  |    2 +-
 arch/x86/kernel/apic/apic.c                  |    2 +-
 arch/x86/kernel/apic/es7000_32.c             |    2 +-
 arch/x86/kernel/cpu/perf_event.c             |    4 +-
 arch/x86/kernel/pci-calgary_64.c             |    4 +-
 arch/x86/kernel/tsc_sync.c                   |    4 +-
 arch/x86/kernel/xsave.c                      |    2 +-
 arch/x86/mm/ioremap.c                        |    5 +-
 arch/x86/mm/pageattr-test.c                  |    2 +-
 arch/x86/mm/pageattr.c                       |    5 +-
 arch/x86/platform/sfi/sfi.c                  |    4 +-
 drivers/acpi/ec.c                            |    4 +-
 drivers/base/class.c                         |    4 +-
 drivers/base/core.c                          |    5 +-
 drivers/base/memory.c                        |    4 +-
 drivers/base/sys.c                           |   10 +--
 drivers/block/floppy.c                       |    2 +-
 drivers/cpuidle/driver.c                     |    2 +-
 drivers/firewire/core-transaction.c          |    6 +-
 drivers/firmware/dmi_scan.c                  |    2 +-
 drivers/gpio/gpiolib.c                       |    4 +-
 drivers/gpio/it8761e_gpio.c                  |    2 +-
 drivers/gpu/drm/drm_crtc_helper.c            |    2 +-
 drivers/gpu/drm/i915/i915_gem.c              |    3 +-
 drivers/gpu/drm/radeon/evergreen.c           |    2 +-
 drivers/gpu/drm/radeon/r100.c                |    4 +-
 drivers/gpu/drm/radeon/r300.c                |    2 +-
 drivers/gpu/drm/radeon/r600.c                |    4 +-
 drivers/gpu/drm/radeon/radeon_fence.c        |    3 +-
 drivers/gpu/drm/radeon/radeon_ttm.c          |    3 +-
 drivers/gpu/drm/radeon/rs400.c               |    2 +-
 drivers/gpu/drm/radeon/rs600.c               |    4 +-
 drivers/media/video/s5p-fimc/fimc-core.c     |    2 +-
 drivers/media/video/sr030pc30.c              |    2 +-
 drivers/mfd/ezx-pcap.c                       |    5 +-
 drivers/net/can/mscan/mscan.c                |    2 +-
 drivers/net/usb/ipheth.c                     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c   |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c   |    6 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c        |    6 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |    2 +-
 drivers/regulator/core.c                     |    3 +-
 drivers/scsi/fcoe/libfcoe.c                  |    2 +-
 drivers/staging/memrar/memrar_allocator.c    |    2 +-
 drivers/staging/solo6x10/solo6010-v4l2-enc.c |    2 +-
 drivers/usb/musb/musb_host.c                 |    6 +-
 drivers/video/omap2/dss/core.c               |    3 +-
 fs/bio.c                                     |    2 +-
 fs/buffer.c                                  |    2 +-
 fs/nfsd/nfs4state.c                          |    3 +-
 fs/notify/inotify/inotify_fsnotify.c         |    4 +-
 fs/proc/generic.c                            |    9 +--
 fs/super.c                                   |    5 +-
 fs/sysfs/dir.c                               |    3 +-
 fs/sysfs/file.c                              |    4 +-
 fs/sysfs/group.c                             |    4 +-
 fs/sysfs/symlink.c                           |   10 +--
 include/asm-generic/bug.h                    |  101 ++++++++++++++++----------
 include/linux/device.h                       |    2 +-
 kernel/irq/chip.c                            |    2 +-
 kernel/irq/manage.c                          |    2 +-
 kernel/notifier.c                            |    2 +-
 kernel/panic.c                               |   40 +++++------
 kernel/pm_qos_params.c                       |    6 +-
 lib/debugobjects.c                           |   21 +++---
 lib/iomap.c                                  |    2 +-
 lib/kobject.c                                |    9 +--
 lib/kobject_uevent.c                         |    4 +-
 lib/list_debug.c                             |   24 +++----
 lib/plist.c                                  |   12 ++--
 mm/percpu.c                                  |    4 +-
 mm/vmalloc.c                                 |    5 +-
 net/core/dev.c                               |    3 +-
 net/ipv4/tcp.c                               |   16 ++---
 net/mac80211/agg-tx.c                        |    5 +-
 net/mac80211/iface.c                         |    4 +-
 net/mac80211/mlme.c                          |    2 +-
 net/mac80211/rx.c                            |    4 +-
 net/mac80211/tx.c                            |    4 +-
 net/mac80211/util.c                          |    4 +-
 net/mac80211/work.c                          |    4 +-
 net/rfkill/input.c                           |    5 +-
 sound/soc/codecs/wm_hubs.c                   |    2 +-
 99 files changed, 319 insertions(+), 330 deletions(-)

-- 
1.7.3.1.g432b3.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
