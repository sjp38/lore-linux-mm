Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED0CC6B02AD
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:12 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id y205so16169984qkb.4
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g67si1909055qkd.264.2016.11.02.12.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 23/33] userfaultfd: shmem: add tlbflush.h header for microblaze
Date: Wed,  2 Nov 2016 20:33:55 +0100
Message-Id: <1478115245-32090-24-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

It resolves this build error:

All errors (new ones prefixed by >>):

   mm/shmem.c: In function 'shmem_mcopy_atomic_pte':
   >> mm/shmem.c:2228:2: error: implicit declaration of function
   'update_mmu_cache' [-Werror=implicit-function-declaration]
        update_mmu_cache(dst_vma, dst_addr, dst_pte);

microblaze may have to be also updated to define it in asm/pgtable.h
like the other archs, then this header inclusion can be removed.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/shmem.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 66deb90..acf80c2 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -34,6 +34,8 @@
 #include <linux/uio.h>
 #include <linux/khugepaged.h>
 
+#include <asm/tlbflush.h> /* for arch/microblaze update_mmu_cache() */
+
 static struct vfsmount *shm_mnt;
 
 #ifdef CONFIG_SHMEM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
