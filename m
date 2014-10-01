Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id E102D6B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 11:35:31 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id hi2so895777wib.5
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 08:35:31 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id qn9si1769844wjc.37.2014.10.01.08.35.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 08:35:31 -0700 (PDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so1028915wiv.5
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 08:35:31 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH] MM: mremap use linux headers
Date: Wed,  1 Oct 2014 16:35:25 +0100
Message-Id: <1412177725-2715-1-git-send-email-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: akpm@linux-foundation.org, walken@google.com, hughd@google.com, hannes@cmpxchg.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>"

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/mremap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 05f1180..f970f02 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -21,8 +21,8 @@
 #include <linux/syscalls.h>
 #include <linux/mmu_notifier.h>
 #include <linux/sched/sysctl.h>
+#include <linux/uaccess.h>
 
-#include <asm/uaccess.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
