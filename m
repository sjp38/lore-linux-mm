Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2DCCE6B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 12:22:48 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id d4so1339479plr.8
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 09:22:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f33sor1278124plf.76.2017.12.06.09.22.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Dec 2017 09:22:47 -0800 (PST)
From: Pravin Shedge <pravin.shedge4linux@gmail.com>
Subject: [PATCH 26/45] mm: remove duplicate includes
Date: Wed,  6 Dec 2017 22:52:37 +0530
Message-Id: <1512580957-6071-1-git-send-email-pravin.shedge4linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, rppt@linux.vnet.ibm.com, mhocko@suse.com
Cc: linux-kernel@vger.kernel.org, pravin.shedge4linux@gmail.com

These duplicate includes have been found with scripts/checkincludes.pl but
they have been removed manually to avoid removing false positives.

Signed-off-by: Pravin Shedge <pravin.shedge4linux@gmail.com>
---
 mm/userfaultfd.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 8119270..39791b8 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -16,7 +16,6 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/mmu_notifier.h>
 #include <linux/hugetlb.h>
-#include <linux/pagemap.h>
 #include <linux/shmem_fs.h>
 #include <asm/tlbflush.h>
 #include "internal.h"
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
