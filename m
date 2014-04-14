Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id A2B6B6B00CA
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 21:56:04 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id hl10so2894166igb.6
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 18:56:04 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0172.hostedemail.com. [216.40.44.172])
        by mx.google.com with ESMTP id ac8si10144112icc.180.2014.04.13.18.56.03
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 18:56:03 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH -next 3.16 00/19] treewide: Convert typedef ctl_table
Date: Sun, 13 Apr 2014 18:55:32 -0700
Message-Id: <cover.1397438826.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-scsi@vger.kernel.org, codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org, linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, keyrings@linux-nfs.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org

Most all of these have been converted in the past, these
are the stragglers.

Original submission:
https://lkml.org/lkml/2013/6/13/650

trivial was cc'd previously,
\
Joe Perches (19):
  arm: Convert use of typedef ctl_table to struct ctl_table
  ia64: Convert use of typedef ctl_table to struct ctl_table
  tile: Convert use of typedef ctl_table to struct ctl_table
  cdrom: Convert use of typedef ctl_table to struct ctl_table
  random: Convert use of typedef ctl_table to struct ctl_table
  parport: Convert use of typedef ctl_table to struct ctl_table
  scsi: Convert use of typedef ctl_table to struct ctl_table
  coda: Convert use of typedef ctl_table to struct ctl_table
  fscache: Convert use of typedef ctl_table to struct ctl_table
  lockd: Convert use of typedef ctl_table to struct ctl_table
  nfs: Convert use of typedef ctl_table to struct ctl_table
  inotify: Convert use of typedef ctl_table to struct ctl_table
  ntfs: Convert use of typedef ctl_table to struct ctl_table
  fs: Convert use of typedef ctl_table to struct ctl_table
  key: Convert use of typedef ctl_table to struct ctl_table
  ipc: Convert use of typedef ctl_table to struct ctl_table
  sysctl: Convert use of typedef ctl_table to struct ctl_table
  mm: Convert use of typedef ctl_table to struct ctl_table
  security: Convert use of typedef ctl_table to struct ctl_table

 arch/arm/kernel/isa.c            |  6 ++---
 arch/ia64/kernel/crash.c         |  4 +--
 arch/ia64/kernel/perfmon.c       |  6 ++---
 arch/tile/kernel/proc.c          |  4 +--
 drivers/cdrom/cdrom.c            | 10 +++----
 drivers/char/random.c            |  4 +--
 drivers/parport/procfs.c         | 58 ++++++++++++++++++++--------------------
 drivers/scsi/scsi_sysctl.c       |  6 ++---
 fs/coda/sysctl.c                 |  4 +--
 fs/dcache.c                      |  2 +-
 fs/drop_caches.c                 |  2 +-
 fs/eventpoll.c                   |  2 +-
 fs/file_table.c                  |  4 +--
 fs/fscache/main.c                |  4 +--
 fs/inode.c                       |  2 +-
 fs/lockd/svc.c                   |  6 ++---
 fs/nfs/nfs4sysctl.c              |  6 ++---
 fs/nfs/sysctl.c                  |  6 ++---
 fs/notify/inotify/inotify_user.c |  2 +-
 fs/ntfs/sysctl.c                 |  4 +--
 include/linux/key.h              |  2 +-
 ipc/ipc_sysctl.c                 | 14 +++++-----
 ipc/mq_sysctl.c                  | 12 ++++-----
 kernel/sysctl.c                  |  2 +-
 kernel/utsname_sysctl.c          |  6 ++---
 mm/page-writeback.c              |  2 +-
 mm/page_alloc.c                  | 12 ++++-----
 security/keys/sysctl.c           |  2 +-
 28 files changed, 97 insertions(+), 97 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
