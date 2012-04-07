Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id A88226B004A
	for <linux-mm@kvack.org>; Sat,  7 Apr 2012 15:00:59 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3469210bkw.14
        for <linux-mm@kvack.org>; Sat, 07 Apr 2012 12:00:57 -0700 (PDT)
Subject: [PATCH v2 00/10] mm: vma->vm_flags diet
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 07 Apr 2012 23:00:49 +0400
Message-ID: <20120407185546.9726.62260.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

This patch-set moves/kills some VM_* flags in vma->vm_flags bit-field,
as result there appears four free bits.

changes from v1:

* "mm, drm/udl: fixup vma flags on mmap" already merged
* two new x86/PAT cleanup/rework patches from Suresh Siddha
* "mm: kill vma flag VM_EXECUTABLE" splitted into three pieces

---

Konstantin Khlebnikov (8):
      mm, x86, pat: rework linear pfn-mmap tracking
      mm: introduce vma flag VM_ARCH_1
      mm: kill vma flag VM_CAN_NONLINEAR
      mm: kill vma flag VM_INSERTPAGE
      mm: use mm->exe_file instead of first VM_EXECUTABLE vma->vm_file
      mm: kill vma flag VM_EXECUTABLE
      mm: kill mm->num_exe_file_vmas and keep mm->exe_file until final mmput()
      mm: move madvise vma flags to the end

Suresh Siddha (2):
      x86, pat: remove the dependency on 'vm_pgoff' in track/untrack pfn vma routines
      x86, pat: separate the pfn attribute tracking for remap_pfn_range and vm_insert_pfn


 arch/powerpc/oprofile/cell/spu_task_sync.c |   15 +----
 arch/tile/mm/elf.c                         |   19 ++----
 arch/x86/mm/pat.c                          |   89 ++++++++++++++++++++--------
 drivers/oprofile/buffer_sync.c             |   17 +----
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
 include/asm-generic/pgtable.h              |   57 +++++++++++-------
 include/linux/fs.h                         |    2 +
 include/linux/mm.h                         |   69 +++++++++-------------
 include/linux/mm_types.h                   |    1 
 include/linux/mman.h                       |    1 
 kernel/auditsc.c                           |   12 +---
 kernel/fork.c                              |   24 --------
 mm/filemap.c                               |    2 -
 mm/filemap_xip.c                           |    3 +
 mm/fremap.c                                |   14 +++-
 mm/huge_memory.c                           |   10 +--
 mm/ksm.c                                   |    9 ++-
 mm/memory.c                                |   37 +++++++-----
 mm/mmap.c                                  |   32 ++--------
 mm/nommu.c                                 |   19 +++---
 mm/shmem.c                                 |    3 -
 security/tomoyo/util.c                     |    9 +--
 35 files changed, 222 insertions(+), 243 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
