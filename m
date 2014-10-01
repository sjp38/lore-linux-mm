Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF1A6B006E
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 10:29:51 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id b13so645309wgh.0
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 07:29:50 -0700 (PDT)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id gw5si2430892wib.44.2014.10.01.07.29.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 07:29:50 -0700 (PDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so611547wgh.35
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 07:29:49 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH] MM: mremap use linux headers
Date: Wed,  1 Oct 2014 15:29:30 +0100
Message-Id: <1412173770-4420-1-git-send-email-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, walken@google.com, kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org

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
