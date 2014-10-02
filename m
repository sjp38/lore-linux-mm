Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2E87B6B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 11:34:25 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so3464371wgh.22
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:34:24 -0700 (PDT)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id i7si1530479wix.66.2014.10.02.08.34.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 08:34:24 -0700 (PDT)
Received: by mail-wg0-f45.google.com with SMTP id m15so3530565wgh.4
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:34:24 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH] mm: fremap use linux header
Date: Thu,  2 Oct 2014 16:34:17 +0100
Message-Id: <1412264057-3146-1-git-send-email-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: akpm@linux-foundation.org, hughd@google.com, gorcunov@openvz.org, kirill.shutemov@linux.intel.com, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use #include <linux/mmu_context.h> instead of <asm/mmu_context.h>

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/fremap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/fremap.c b/mm/fremap.c
index 72b8fa3..d614f1c 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -1,6 +1,6 @@
 /*
  *   linux/mm/fremap.c
- * 
+ *
  * Explicit pagetable population and nonlinear (random) mappings support.
  *
  * started by Ingo Molnar, Copyright (C) 2002, 2003
@@ -16,8 +16,8 @@
 #include <linux/rmap.h>
 #include <linux/syscalls.h>
 #include <linux/mmu_notifier.h>
+#include <linux/mmu_context.h>
 
-#include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
