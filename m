Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 430056B0078
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 15:02:20 -0500 (EST)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/10] treewide: Fix format strings that misuse continuations
Date: Sun, 31 Jan 2010 12:02:02 -0800
Message-Id: <cover.1264967493.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "David S. Miller" <davem@davemloft.net>, "James E.J. Bottomley" <James.Bottomley@suse.de>, Sonic Zhang <sonic.zhang@analog.com>, Greg Kroah-Hartman <gregkh@suse.de>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Liam Girdwood <lrg@slimlogic.co.uk>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@ozlabs.org, linux-ide@vger.kernel.org, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org, linux-mm@kvack.org, alsa-devel@alsa-project.org
List-ID: <linux-mm.kvack.org>

Format strings that are continued with \ are frequently misused.
Change them to use mostly single line formats, some longer than 80 chars.
Fix a few miscellaneous typos at the same time.

Joe Perches (10):
  arch/powerpc: Fix continuation line formats
  arch/blackfin: Fix continuation line formats
  drivers/ide: Fix continuation line formats
  drivers/serial/bfin_5xx.c: Fix continuation line formats
  drivers/scsi/arcmsr: Fix continuation line formats
  drivers/staging: Fix continuation line formats
  drivers/net/amd8111e.c: Fix continuation line formats
  fs/proc/array.c: Fix continuation line formats
  mm/slab.c: Fix continuation line formats
  sound/soc/blackfin: Fix continuation line formats

 arch/blackfin/mach-common/smp.c                    |    4 +-
 arch/powerpc/kernel/nvram_64.c                     |    6 +-
 arch/powerpc/platforms/pseries/hotplug-cpu.c       |    8 ++--
 arch/powerpc/platforms/pseries/smp.c               |    4 +-
 drivers/ide/au1xxx-ide.c                           |    4 +-
 drivers/ide/pmac.c                                 |    4 +-
 drivers/net/amd8111e.c                             |    3 +-
 drivers/scsi/arcmsr/arcmsr_hba.c                   |   49 +++++++++----------
 drivers/serial/bfin_5xx.c                          |    6 +--
 drivers/staging/dream/qdsp5/audio_mp3.c            |    3 +-
 .../rtl8187se/ieee80211/ieee80211_softmac_wx.c     |    3 +-
 drivers/staging/rtl8187se/r8180_core.c             |    3 +-
 drivers/staging/sep/sep_driver.c                   |    3 +-
 fs/proc/array.c                                    |    7 ++-
 mm/slab.c                                          |    4 +-
 sound/soc/blackfin/bf5xx-ac97-pcm.c                |    8 +--
 sound/soc/blackfin/bf5xx-i2s-pcm.c                 |    3 +-
 sound/soc/blackfin/bf5xx-tdm-pcm.c                 |    3 +-
 18 files changed, 55 insertions(+), 70 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
