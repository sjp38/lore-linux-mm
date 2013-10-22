Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id CFFD06B00DC
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 18:30:24 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb12so28012pbc.36
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 15:30:24 -0700 (PDT)
Received: from psmtp.com ([74.125.245.148])
        by mx.google.com with SMTP id u9si46092pbf.113.2013.10.22.15.30.22
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 15:30:23 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/24] treewide: Convert use of typedef ctl_table to struct ctl_table
Date: Tue, 22 Oct 2013 15:29:43 -0700
Message-Id: <cover.1382480758.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-rdma@vger.kernel.org, linux-raid@vger.kernel.org, linux-scsi@vger.kernel.org, codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org, linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, keyrings@linux-nfs.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org

Joe Perches (24):
  arm: Convert use of typedef ctl_table to struct ctl_table
  ia64: Convert use of typedef ctl_table to struct ctl_table
  s390: Convert use of typedef ctl_table to struct ctl_table
  tile: Convert use of typedef ctl_table to struct ctl_table
  cdrom: Convert use of typedef ctl_table to struct ctl_table
  random: Convert use of typedef ctl_table to struct ctl_table
  infiniband: Convert use of typedef ctl_table to struct ctl_table
  md: Convert use of typedef ctl_table to struct ctl_table
  parport: Convert use of typedef ctl_table to struct ctl_table
  scsi: Convert use of typedef ctl_table to struct ctl_table
  coda: Convert use of typedef ctl_table to struct ctl_table
  fscache: Convert use of typedef ctl_table to struct ctl_table
  lockd: Convert use of typedef ctl_table to struct ctl_table
  nfs: Convert use of typedef ctl_table to struct ctl_table
  inotify: Convert use of typedef ctl_table to struct ctl_table
  ntfs: Convert use of typedef ctl_table to struct ctl_table
  ocfs2: Convert use of typedef ctl_table to struct ctl_table
  proc: Convert use of typedef ctl_table to struct ctl_table
  fs: Convert use of typedef ctl_table to struct ctl_table
  key: Convert use of typedef ctl_table to struct ctl_table
  ipc: Convert use of typedef ctl_table to struct ctl_table
  kernel: Convert use of typedef ctl_table to struct ctl_table
  mm: Convert use of typedef ctl_table to struct ctl_table
  security:keys: Convert use of typedef ctl_table to struct ctl_table

 arch/arm/kernel/isa.c              |  6 ++---
 arch/ia64/kernel/crash.c           |  4 +--
 arch/ia64/kernel/perfmon.c         |  6 ++---
 arch/s390/appldata/appldata_base.c | 10 ++++----
 arch/s390/kernel/debug.c           |  2 +-
 arch/s390/mm/cmm.c                 |  8 +++---
 arch/tile/kernel/proc.c            |  4 +--
 drivers/cdrom/cdrom.c              | 10 ++++----
 drivers/char/random.c              |  4 +--
 drivers/infiniband/core/ucma.c     |  2 +-
 drivers/md/md.c                    |  6 ++---
 drivers/parport/procfs.c           | 52 ++++++++++++++++++--------------------
 drivers/scsi/scsi_sysctl.c         |  6 ++---
 fs/coda/sysctl.c                   |  4 +--
 fs/dcache.c                        |  2 +-
 fs/drop_caches.c                   |  2 +-
 fs/eventpoll.c                     |  2 +-
 fs/file_table.c                    |  4 +--
 fs/fscache/main.c                  |  4 +--
 fs/inode.c                         |  2 +-
 fs/lockd/svc.c                     |  6 ++---
 fs/nfs/nfs4sysctl.c                |  6 ++---
 fs/nfs/sysctl.c                    |  6 ++---
 fs/notify/inotify/inotify_user.c   |  2 +-
 fs/ntfs/sysctl.c                   |  4 +--
 fs/ocfs2/stackglue.c               |  8 +++---
 fs/proc/proc_sysctl.c              |  2 +-
 include/linux/key.h                |  2 +-
 ipc/ipc_sysctl.c                   | 14 +++++-----
 ipc/mq_sysctl.c                    | 10 ++++----
 kernel/sysctl.c                    |  2 +-
 kernel/utsname_sysctl.c            |  6 ++---
 mm/page-writeback.c                |  2 +-
 mm/page_alloc.c                    | 12 ++++-----
 security/keys/sysctl.c             |  2 +-
 35 files changed, 111 insertions(+), 113 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
