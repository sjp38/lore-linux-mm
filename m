Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id C8B456B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 22:38:13 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [Trivial PATCH 00/33] Remove uses of typedef ctl_table
Date: Thu, 13 Jun 2013 19:37:25 -0700
Message-Id: <cover.1371177118.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <trivial@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, openipmi-developer@lists.sourceforge.net, linux-rdma@vger.kernel.org, linux-raid@vger.kernel.org, linux-scsi@vger.kernel.org, codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org, linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, xfs@oss.sgi.com, keyrings@linux-nfs.org, netdev@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org

It's clearer to use struct ctl_table instead

Joe Perches (33):
  arm: kernel: isa: Convert use of typedef ctl_table to struct ctl_table
  frv: Convert use of typedef ctl_table to struct ctl_table
  ia64: crash: Convert use of typedef ctl_table to struct ctl_table
  mips: lasat: sysctl: Convert use of typedef ctl_table to struct ctl_table
  powerpc: idle: Convert use of typedef ctl_table to struct ctl_table
  s390: Convert use of typedef ctl_table to struct ctl_table
  tile: proc: Convert use of typedef ctl_table to struct ctl_table
  x86: vdso: Convert use of typedef ctl_table to struct ctl_table
  cdrom: Convert use of typedef ctl_table to struct ctl_table
  char: Convert use of typedef ctl_table to struct ctl_table
  infiniband: Convert use of typedef ctl_table to struct ctl_table
  macintosh: Convert use of typedef ctl_table to struct ctl_table
  md: Convert use of typedef ctl_table to struct ctl_table
  sgi: xpc: Convert use of typedef ctl_table to struct ctl_table
  parport: Convert use of typedef ctl_table to struct ctl_table
  scsi_sysctl: Convert use of typedef ctl_table to struct ctl_table
  coda: Convert use of typedef ctl_table to struct ctl_table
  fscache: Convert use of typedef ctl_table to struct ctl_table
  lockd: Convert use of typedef ctl_table to struct ctl_table
  nfs: Convert use of typedef ctl_table to struct ctl_table
  inotify: Convert use of typedef ctl_table to struct ctl_table
  ntfs: Convert use of typedef ctl_table to struct ctl_table
  ocfs2: Convert use of typedef ctl_table to struct ctl_table
  quota: Convert use of typedef ctl_table to struct ctl_table
  xfs: Convert use of typedef ctl_table to struct ctl_table
  fs: Convert use of typedef ctl_table to struct ctl_table
  key: Convert use of typedef ctl_table to struct ctl_table
  ipv6: Convert use of typedef ctl_table to struct ctl_table
  ndisc: Convert use of typedef ctl_table to struct ctl_table
  ipc: Convert use of typedef ctl_table to struct ctl_table
  sysctl: Convert use of typedef ctl_table to struct ctl_table
  mm: Convert use of typedef ctl_table to struct ctl_table
  security: keys: Convert use of typedef ctl_table to struct ctl_table

 arch/arm/kernel/isa.c              |  6 ++--
 arch/frv/kernel/pm.c               |  8 +++---
 arch/frv/kernel/sysctl.c           |  4 +--
 arch/ia64/kernel/crash.c           |  4 +--
 arch/ia64/kernel/perfmon.c         |  6 ++--
 arch/mips/lasat/sysctl.c           | 14 ++++-----
 arch/powerpc/kernel/idle.c         |  4 +--
 arch/s390/appldata/appldata_base.c | 16 +++++------
 arch/s390/kernel/debug.c           |  4 +--
 arch/s390/mm/cmm.c                 |  6 ++--
 arch/tile/kernel/proc.c            |  4 +--
 arch/x86/vdso/vdso32-setup.c       |  4 +--
 drivers/cdrom/cdrom.c              | 10 +++----
 drivers/char/hpet.c                |  6 ++--
 drivers/char/ipmi/ipmi_poweroff.c  |  6 ++--
 drivers/char/random.c              |  8 +++---
 drivers/char/rtc.c                 |  6 ++--
 drivers/infiniband/core/ucma.c     |  2 +-
 drivers/macintosh/mac_hid.c        |  8 +++---
 drivers/md/md.c                    |  6 ++--
 drivers/misc/sgi-xp/xpc_main.c     |  6 ++--
 drivers/parport/procfs.c           | 58 +++++++++++++++++++-------------------
 drivers/scsi/scsi_sysctl.c         |  6 ++--
 fs/coda/sysctl.c                   |  4 +--
 fs/dcache.c                        |  2 +-
 fs/drop_caches.c                   |  2 +-
 fs/eventpoll.c                     |  2 +-
 fs/file_table.c                    |  4 +--
 fs/fscache/main.c                  |  4 +--
 fs/inode.c                         |  2 +-
 fs/lockd/svc.c                     |  6 ++--
 fs/nfs/nfs4sysctl.c                |  6 ++--
 fs/nfs/sysctl.c                    |  6 ++--
 fs/notify/inotify/inotify_user.c   |  2 +-
 fs/ntfs/sysctl.c                   |  4 +--
 fs/ocfs2/stackglue.c               |  8 +++---
 fs/quota/dquot.c                   |  6 ++--
 fs/xfs/xfs_sysctl.c                | 26 ++++++++---------
 include/linux/key.h                |  2 +-
 include/net/ipv6.h                 |  4 +--
 include/net/ndisc.h                |  2 +-
 ipc/ipc_sysctl.c                   | 14 ++++-----
 ipc/mq_sysctl.c                    | 10 +++----
 kernel/sysctl.c                    |  2 +-
 kernel/utsname_sysctl.c            |  6 ++--
 mm/page-writeback.c                |  2 +-
 mm/page_alloc.c                    | 15 +++++-----
 security/keys/sysctl.c             |  2 +-
 48 files changed, 174 insertions(+), 171 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
