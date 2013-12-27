Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id A096E6B0035
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 17:40:35 -0500 (EST)
Received: by mail-ie0-f172.google.com with SMTP id qd12so10266881ieb.31
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 14:40:35 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d4si19173995igr.0.2013.12.27.14.40.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Dec 2013 14:40:34 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: dump page when hitting a VM_BUG_ON using VM_BUG_ON_PAGE fix
Date: Fri, 27 Dec 2013 17:40:18 -0500
Message-Id: <1388184018-11396-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>

I messed up and forgot to commit this fix before sending out the original
patch.

It fixes build issues in various files using VM_BUG_ON_PAGE.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/mmdebug.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index e522734..8bb6490 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -2,6 +2,7 @@
 #define LINUX_MM_DEBUG_H 1
 
 #ifdef CONFIG_DEBUG_VM
+extern void dump_page(struct page *page);
 #define VM_BUG_ON(cond) BUG_ON(cond)
 #define VM_BUG_ON_PAGE(cond, page) \
 	do { if (unlikely(cond)) { dump_page(page); BUG(); } } while(0)
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
