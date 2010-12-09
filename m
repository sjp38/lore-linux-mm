Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 728A46B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 15:04:12 -0500 (EST)
From: Joe Perches <joe@perches.com>
Subject: [trivial PATCH 00/15] remove duplicate unlikely from IS_ERR
Date: Thu,  9 Dec 2010 12:03:53 -0800
Message-Id: <cover.1291923888.git.joe@perches.com>
In-Reply-To: <1291906801-1389-2-git-send-email-tklauser@distanz.ch>
References: <1291906801-1389-2-git-send-email-tklauser@distanz.ch>
Sender: owner-linux-mm@kvack.org
To: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, rtc-linux@googlegroups.com, linux-s390@vger.kernel.org, osd-dev@open-osd.org, linux-arm-msm@vger.kernel.org, linux-usb@vger.kernel.org, linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org
Cc: Jiri Kosina <trivial@kernel.org>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-wireless@vger.kernel.org, devel@driverdev.osuosl.org
List-ID: <linux-mm.kvack.org>

Tobias Klauser <tklauser@distanz.ch> sent a patch to remove
an unnecessary unlikely from drivers/misc/c2port/core.c,
https://lkml.org/lkml/2010/12/9/199

Here are the other instances treewide.

I think it'd be good if people would, when noticing defects in a
specific subsystem, look for and correct the same defect treewide.

IS_ERR already has an unlikely test so remove unnecessary
unlikelys from the call sites.

from: include/linux/err.h
#define IS_ERR_VALUE(x) unlikely((x) >= (unsigned long)-MAX_ERRNO)
[...]
static inline long __must_check IS_ERR(const void *ptr)
{
	return IS_ERR_VALUE((unsigned long)ptr);
}

Sending directly to maintainers for now, will resend in a month
or so only to trivial if not picked up.
 
Joe Perches (15):
  drm: Remove duplicate unlikely from IS_ERR
  stmmac: Remove duplicate unlikely from IS_ERR
  rtc: Remove duplicate unlikely from IS_ERR
  s390: Remove duplicate unlikely from IS_ERR
  osd: Remove duplicate unlikely from IS_ERR
  serial: Remove duplicate unlikely from IS_ERR
  brcm80211: Remove duplicate unlikely from IS_ERR
  gadget: Remove duplicate unlikely from IS_ERR
  exofs: Remove duplicate unlikely from IS_ERR
  ext2: Remove duplicate unlikely from IS_ERR
  ext3: Remove duplicate unlikely from IS_ERR
  ext4: Remove duplicate unlikely from IS_ERR
  nfs: Remove duplicate unlikely from IS_ERR
  mm: Remove duplicate unlikely from IS_ERR
  ipv6: Remove duplicate unlikely from IS_ERR

 drivers/gpu/drm/ttm/ttm_tt.c                     |    4 ++--
 drivers/net/stmmac/stmmac_main.c                 |    2 +-
 drivers/rtc/rtc-bfin.c                           |    2 +-
 drivers/s390/scsi/zfcp_fsf.c                     |    4 ++--
 drivers/scsi/osd/osd_initiator.c                 |    2 +-
 drivers/serial/msm_serial.c                      |    2 +-
 drivers/staging/brcm80211/brcmfmac/wl_cfg80211.c |    2 +-
 drivers/usb/gadget/f_fs.c                        |    4 ++--
 fs/exofs/super.c                                 |    2 +-
 fs/ext2/namei.c                                  |    2 +-
 fs/ext3/namei.c                                  |    2 +-
 fs/ext4/namei.c                                  |    2 +-
 fs/nfs/mount_clnt.c                              |    2 +-
 mm/vmalloc.c                                     |    2 +-
 net/ipv6/af_inet6.c                              |    2 +-
 15 files changed, 18 insertions(+), 18 deletions(-)

-- 
1.7.3.3.464.gf80b6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
