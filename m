Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 257166B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 09:43:26 -0400 (EDT)
Received: by oibg201 with SMTP id g201so29260676oib.10
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 06:43:25 -0700 (PDT)
Received: from m12-15.163.com (m12-15.163.com. [220.181.12.15])
        by mx.google.com with ESMTP id 70si11399916oic.2.2015.03.09.06.42.36
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 06:43:25 -0700 (PDT)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH] mm/oom_kill.c: fix a typo
Date: Mon,  9 Mar 2015 21:37:03 +0800
Message-Id: <1425908223-6509-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, hannes@cmpxchg.org, riel@redhat.com, iamjoonsoo.kim@lge.com, rientjes@google.com, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Alter 'taks' -> 'task'

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 mm/oom_kill.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 642f38c..5d6a458 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -408,7 +408,7 @@ bool oom_killer_disabled __read_mostly;
 static DECLARE_RWSEM(oom_sem);
 
 /**
- * mark_tsk_oom_victim - marks the given taks as OOM victim.
+ * mark_tsk_oom_victim - marks the given task as OOM victim.
  * @tsk: task to mark
  *
  * Has to be called with oom_sem taken for read and never after
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
