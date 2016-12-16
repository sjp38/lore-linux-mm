Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B39F66B0270
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:28 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id 3so48736699ioc.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e19si6161261ioj.160.2016.12.16.06.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 30/42] userfaultfd: shmem: add tlbflush.h header for microblaze
Date: Fri, 16 Dec 2016 15:48:09 +0100
Message-Id: <20161216144821.5183-31-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

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
index 58e20ff..5cc1cb2 100644
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
