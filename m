Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C04AF6B0012
	for <linux-mm@kvack.org>; Sat, 28 May 2011 13:36:55 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [TRIVIAL PATCH next 00/15] treewide: Convert vmalloc/memset to vzalloc
Date: Sat, 28 May 2011 10:36:20 -0700
Message-Id: <cover.1306603968.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, drbd-user@lists.linbit.com, dm-devel@redhat.com, linux-raid@vger.kernel.org, linux-mtd@lists.infradead.org, linux-scsi@vger.kernel.org, linux-fbdev@vger.kernel.org, xen-devel@lists.xensource.com, virtualization@lists.linux-foundation.org, codalist@coda.cs.cmu.edu, reiserfs-devel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, rds-devel@oss.oracle.com
Cc: linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, devel@driverdev.osuosl.org, xfs@oss.sgi.com

Resubmittal of patches from November 2010 and a few new ones.

Joe Perches (15):
  s390: Convert vmalloc/memset to vzalloc
  x86: Convert vmalloc/memset to vzalloc
  atm: Convert vmalloc/memset to vzalloc
  drbd: Convert vmalloc/memset to vzalloc
  char: Convert vmalloc/memset to vzalloc
  isdn: Convert vmalloc/memset to vzalloc
  md: Convert vmalloc/memset to vzalloc
  media: Convert vmalloc/memset to vzalloc
  mtd: Convert vmalloc/memset to vzalloc
  scsi: Convert vmalloc/memset to vzalloc
  staging: Convert vmalloc/memset to vzalloc
  video: Convert vmalloc/memset to vzalloc
  fs: Convert vmalloc/memset to vzalloc
  mm: Convert vmalloc/memset to vzalloc
  net: Convert vmalloc/memset to vzalloc

 arch/s390/hypfs/hypfs_diag.c           |    3 +--
 arch/x86/mm/pageattr-test.c            |    3 +--
 drivers/atm/idt77252.c                 |   11 ++++++-----
 drivers/atm/lanai.c                    |    3 +--
 drivers/block/drbd/drbd_bitmap.c       |    5 ++---
 drivers/char/agp/backend.c             |    3 +--
 drivers/char/raw.c                     |    3 +--
 drivers/isdn/i4l/isdn_common.c         |    4 ++--
 drivers/isdn/mISDN/dsp_core.c          |    3 +--
 drivers/isdn/mISDN/l1oip_codec.c       |    6 ++----
 drivers/md/dm-log.c                    |    3 +--
 drivers/md/dm-snap-persistent.c        |    3 +--
 drivers/md/dm-table.c                  |    4 +---
 drivers/media/video/videobuf2-dma-sg.c |    8 ++------
 drivers/mtd/mtdswap.c                  |    3 +--
 drivers/s390/cio/blacklist.c           |    3 +--
 drivers/scsi/bfa/bfad.c                |    3 +--
 drivers/scsi/bfa/bfad_debugfs.c        |    8 ++------
 drivers/scsi/cxgbi/libcxgbi.h          |    6 ++----
 drivers/scsi/qla2xxx/qla_attr.c        |    6 ++----
 drivers/scsi/qla2xxx/qla_bsg.c         |    3 +--
 drivers/scsi/scsi_debug.c              |    7 ++-----
 drivers/staging/rts_pstor/ms.c         |    3 +--
 drivers/staging/rts_pstor/rtsx_chip.c  |    6 ++----
 drivers/video/arcfb.c                  |    5 ++---
 drivers/video/broadsheetfb.c           |    4 +---
 drivers/video/hecubafb.c               |    5 ++---
 drivers/video/metronomefb.c            |    4 +---
 drivers/video/xen-fbfront.c            |    3 +--
 fs/coda/coda_linux.h                   |    5 ++---
 fs/reiserfs/journal.c                  |    9 +++------
 fs/reiserfs/resize.c                   |    4 +---
 fs/xfs/linux-2.6/kmem.h                |    7 +------
 mm/page_cgroup.c                       |    3 +--
 net/netfilter/x_tables.c               |    5 ++---
 net/rds/ib_cm.c                        |    6 ++----
 36 files changed, 57 insertions(+), 113 deletions(-)

-- 
1.7.5.rc3.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
