Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id BEA946B0035
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 17:08:07 -0400 (EDT)
Received: by mail-ob0-f179.google.com with SMTP id uz6so2288335obc.10
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 14:08:07 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id r7si44171902oed.40.2014.07.04.14.08.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 04 Jul 2014 14:08:06 -0700 (PDT)
Message-ID: <1404508083.2457.15.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH] mm,vmacache: inline vmacache_valid_mm()
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 04 Jul 2014 14:08:03 -0700
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: davidlohr@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Davidlohr Bueso <davidlohr@hp.com>

No brainer for this little function.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 mm/vmacache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmacache.c b/mm/vmacache.c
index 9f25af8..e72b8ee 100644
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -50,7 +50,7 @@ void vmacache_flush_all(struct mm_struct *mm)
  * Also handle the case where a kernel thread has adopted this mm via use_mm().
  * That kernel thread's vmacache is not applicable to this mm.
  */
-static bool vmacache_valid_mm(struct mm_struct *mm)
+static inline bool vmacache_valid_mm(struct mm_struct *mm)
 {
 	return current->mm == mm && !(current->flags & PF_KTHREAD);
 }
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
