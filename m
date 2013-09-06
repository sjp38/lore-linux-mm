Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id B17776B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 23:32:28 -0400 (EDT)
Message-ID: <52294C9D.1080808@cn.fujitsu.com>
Date: Fri, 06 Sep 2013 11:31:41 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] mm/mmap.c: Remove unnecessary pgoff assignment
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

We never access variable pgoff later, so the assignment is
redundant. Remove it. 

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/mmap.c |    1 - 
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f9c97d1..db44f6a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1570,7 +1570,6 @@ munmap_back:
                WARN_ON_ONCE(addr != vma->vm_start);
 
                addr = vma->vm_start;
-               pgoff = vma->vm_pgoff;
                vm_flags = vma->vm_flags;
        } else if (vm_flags & VM_SHARED) {
                if (unlikely(vm_flags & (VM_GROWSDOWN|VM_GROWSUP)))
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
