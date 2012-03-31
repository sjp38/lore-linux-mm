Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 549E76B004A
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 05:25:46 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so1492977bkw.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 02:25:44 -0700 (PDT)
Subject: [PATCH 0/7] mm: vma->vm_flags diet
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 31 Mar 2012 13:25:36 +0400
Message-ID: <20120331091049.19373.28994.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

This patch-set moves/kills some VM_* flags in vma->vm_flags bit-field,
as result there appears four free bits.

Also I'm working on VM_RESERVED reorganization, probably it also can be killed.
It lost original swapout-protection sense in 2.6 and now is used for other purposes.

---

Konstantin Khlebnikov (7):
      mm, x86, PAT: rework linear pfn-mmap tracking
      mm: introduce vma flag VM_ARCH_1
      mm: kill vma flag VM_CAN_NONLINEAR
      mm: kill vma flag VM_INSERTPAGE
      mm, drm/udl: fixup vma flags on mmap
      mm: kill vma flag VM_EXECUTABLE
      mm: move madvise vma flags to the end


 arch/powerpc/oprofile/cell/spu_task_sync.c |   15 ++----
 arch/tile/mm/elf.c                         |   12 ++---
 arch/x86/mm/pat.c                          |   25 +++++++---
 drivers/gpu/drm/udl/udl_drv.c              |    2 -
 drivers/gpu/drm/udl/udl_drv.h              |    1 
 drivers/gpu/drm/udl/udl_gem.c              |   14 ++++++
 drivers/oprofile/buffer_sync.c             |   17 +------
 drivers/staging/android/ashmem.c           |    1 
 fs/9p/vfs_file.c                           |    1 
 fs/btrfs/file.c                            |    2 -
 fs/ceph/addr.c                             |    2 -
 fs/cifs/file.c                             |    1 
 fs/ecryptfs/file.c                         |    1 
 fs/ext4/file.c                             |    2 -
 fs/fuse/file.c                             |    1 
 fs/gfs2/file.c                             |    2 -
 fs/nfs/file.c                              |    1 
 fs/nilfs2/file.c                           |    2 -
 fs/ocfs2/mmap.c                            |    2 -
 fs/ubifs/file.c                            |    1 
 fs/xfs/xfs_file.c                          |    2 -
 include/asm-generic/pgtable.h              |    4 +-
 include/linux/fs.h                         |    2 +
 include/linux/mm.h                         |   69 ++++++++++++----------------
 include/linux/mm_types.h                   |    1 
 include/linux/mman.h                       |    1 
 kernel/auditsc.c                           |   17 +------
 kernel/fork.c                              |   29 ++----------
 mm/filemap.c                               |    2 -
 mm/filemap_xip.c                           |    3 +
 mm/fremap.c                                |   14 +++---
 mm/huge_memory.c                           |   10 ++--
 mm/ksm.c                                   |    9 +++-
 mm/memory.c                                |   29 ++++++++----
 mm/mmap.c                                  |   32 +++----------
 mm/nommu.c                                 |   19 ++++----
 mm/shmem.c                                 |    3 -
 security/tomoyo/util.c                     |   14 +-----
 38 files changed, 158 insertions(+), 207 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
