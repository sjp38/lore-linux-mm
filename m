From: Thomas Weber <swirl-EOsNSARiLbg@public.gmane.org>
Subject: [PATCH 0/4] Some typo fixing
Date: Mon, 15 Mar 2010 21:55:43 +0100
Message-ID: <1268686558-28171-1-git-send-email-swirl@gmx.li>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>, Lin Ming <ming.m.lin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>, Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>, Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>, David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>, Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>, "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Steve Conklin <sconklin-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Ralph Campbell <infinipath-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, Anton Vorontsov <avorontsov-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>, cbe-oss-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, Liam Girdwood <lrg-kDsPt+C1G03kYMGBc/C6ZA@public.gmane.org>, Anthony Liguori <aliguori-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>, Tejun Heo <tj@kernel>
List-Id: linux-mm.kvack.org

I have fixed some typos.

Thomas Weber (4):
  Fix typo: [Ss]ytem => [Ss]ystem
  Fix typo: udpate => update
  Fix typo: paramters => parameters
  Fix typo: orginal => original

 Documentation/cgroups/cgroups.txt               |    2 +-
 Documentation/kbuild/kconfig.txt                |    2 +-
 Documentation/sysfs-rules.txt                   |    2 +-
 Documentation/trace/events.txt                  |    8 ++++----
 drivers/acpi/osl.c                              |    4 ++--
 drivers/ata/ata_piix.c                          |    2 +-
 drivers/firewire/ohci.c                         |    2 +-
 drivers/gpu/drm/drm_bufs.c                      |    2 +-
 drivers/infiniband/hw/ipath/ipath_iba6110.c     |    2 +-
 drivers/infiniband/hw/ipath/ipath_iba6120.c     |    4 ++--
 drivers/infiniband/hw/ipath/ipath_iba7220.c     |    2 +-
 drivers/isdn/hisax/hfc4s8s_l1.c                 |    2 +-
 drivers/macintosh/windfarm_pm81.c               |    2 +-
 drivers/media/dvb/dvb-usb/friio-fe.c            |    2 +-
 drivers/net/smsc911x.c                          |    4 ++--
 drivers/pci/hotplug/cpqphp_core.c               |    2 +-
 drivers/pci/pci.c                               |    2 +-
 drivers/ps3/ps3-sys-manager.c                   |    2 +-
 drivers/regulator/core.c                        |    2 +-
 drivers/s390/char/sclp_cpi_sys.c                |    2 +-
 drivers/scsi/bfa/include/defs/bfa_defs_cee.h    |    2 +-
 drivers/scsi/bfa/include/defs/bfa_defs_status.h |    4 ++--
 drivers/spi/spi_mpc8xxx.c                       |    2 +-
 drivers/staging/iio/Documentation/overview.txt  |    2 +-
 drivers/staging/rt2860/rtmp.h                   |    2 +-
 drivers/staging/rtl8187se/r8180_core.c          |    4 ++--
 drivers/staging/rtl8187se/r8180_dm.c            |    2 +-
 drivers/staging/rtl8187se/r8185b_init.c         |    2 +-
 drivers/virtio/virtio_pci.c                     |    2 +-
 fs/jfs/jfs_dmap.c                               |    2 +-
 kernel/cgroup.c                                 |    2 +-
 mm/page_alloc.c                                 |    2 +-
 net/wimax/op-rfkill.c                           |    2 +-
 sound/pci/emu10k1/emu10k1_main.c                |    2 +-
 34 files changed, 42 insertions(+), 42 deletions(-)
