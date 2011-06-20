Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 147936B0113
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 12:00:09 -0400 (EDT)
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: [PATCH] oom: add uid to "Killed process" message
Date: Mon, 20 Jun 2011 12:16:09 +0200
Message-Id: <1308564969-20888-1-git-send-email-fhrbata@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, CAI Qian <caiqian@redhat.com>, lwoodman@redhat.com

Add user id to the oom killer's "Killed process" message, so the user of the
killed process can be identified.

Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>
---
 mm/oom_kill.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index e4b0991..249a15a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -427,8 +427,9 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 	/* mm cannot be safely dereferenced after task_unlock(p) */
 	mm = p->mm;
 
-	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
-		task_pid_nr(p), p->comm, K(p->mm->total_vm),
+	pr_err("Killed process %d (%s) uid: %d, total-vm:%lukB, "
+		"anon-rss:%lukB, file-rss:%lukB\n",
+		task_pid_nr(p), p->comm, task_uid(p), K(p->mm->total_vm),
 		K(get_mm_counter(p->mm, MM_ANONPAGES)),
 		K(get_mm_counter(p->mm, MM_FILEPAGES)));
 	task_unlock(p);
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
