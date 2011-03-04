Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id ADEAF8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 16:30:45 -0500 (EST)
From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH rh6] mm: skip zombie in OOM-killer
Date: Sat,  5 Mar 2011 00:30:56 +0300
Message-Id: <1299274256-2122-1-git-send-email-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, avagin@openvz.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A parent may wait a memory and zombie will prevent killing another task.

Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 mm/oom_kill.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7dcca55..2fc554e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -311,7 +311,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		 * blocked waiting for another task which itself is waiting
 		 * for memory. Is there a better alternative?
 		 */
-		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+		if (test_tsk_thread_flag(p, TIF_MEMDIE) && p->mm)
 			return ERR_PTR(-1UL);
 
 		/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
