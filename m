Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7C7D6B04C0
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 14:57:16 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q66so149625119qki.1
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 11:57:16 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c12si24734451qtd.286.2017.07.31.11.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 11:57:15 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/3] Consolidate system call hugetlb page size encodings 
Date: Mon, 31 Jul 2017 11:56:23 -0700
Message-Id: <1501527386-10736-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

These patches are the result of discussions in this thread [1].  The
following changes are made in the patch set:

1) Put all the log2 encoded huge page size definitions in a common header
   file.  The idea is have a set of definitions that can be use as the
   basis for system call specific definitions such as MAP_HUGE_* and
   SHM_HUGE_*.
2) Remove MAP_HUGE_* definitions in arch specific files.  All these
   definitions are the same.  Consolidate all definitions in the primary
   user header file (uapi/linux/mman.h).
3) Remove SHM_HUGE_* definitions intended for user space from kernel
   header file, and add to user (uapi/linux/shm.h) header file.  Add
   definitions for all known huge page size encodings as in mmap.

[1]https://lkml.org/lkml/2017/3/8/548

Mike Kravetz (3):
  mm:hugetlb: Define system call hugetlb size encodings in single file
  mm: arch: Consolidate mmap hugetlb size encodings
  mm:shm: Use new hugetlb size encoding definitions

 arch/alpha/include/uapi/asm/mman.h        | 11 ----------
 arch/mips/include/uapi/asm/mman.h         | 11 ----------
 arch/parisc/include/uapi/asm/mman.h       | 11 ----------
 arch/powerpc/include/uapi/asm/mman.h      | 16 ---------------
 arch/x86/include/uapi/asm/mman.h          |  3 ---
 arch/xtensa/include/uapi/asm/mman.h       | 11 ----------
 include/linux/shm.h                       | 17 ----------------
 include/uapi/asm-generic/hugetlb_encode.h | 34 +++++++++++++++++++++++++++++++
 include/uapi/asm-generic/mman-common.h    | 11 ----------
 include/uapi/linux/mman.h                 | 22 ++++++++++++++++++++
 include/uapi/linux/shm.h                  | 31 ++++++++++++++++++++++++++--
 11 files changed, 85 insertions(+), 93 deletions(-)
 create mode 100644 include/uapi/asm-generic/hugetlb_encode.h

-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
