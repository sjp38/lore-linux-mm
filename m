Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A95086B0233
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 08:00:00 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58BxwOW014941
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:59:58 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 57FC945DE4E
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:59:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D6ED45DD71
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:59:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 27B361DB8018
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:59:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D5B231DB8015
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:59:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 07/10] oom: kill useless debug print
In-Reply-To: <20100608204621.767A.A69D9226@jp.fujitsu.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com>
Message-Id: <20100608205909.768F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:59:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, all of oom developers usually are using sysctl_oom_dump_tasks.
Redundunt useless debug print can be removed.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8376ad1..e7d3a5d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -33,7 +33,6 @@ int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 static DEFINE_SPINLOCK(zone_scan_lock);
-/* #define DEBUG */
 
 /*
  * Is all threads of the target process nodes overlap ours?
@@ -201,10 +200,6 @@ unsigned long oom_badness(struct task_struct *p, unsigned long uptime)
 			points >>= -(oom_adj);
 	}
 
-#ifdef DEBUG
-	printk(KERN_DEBUG "OOMkill: task %d (%s) got %lu points\n",
-	p->pid, p->comm, points);
-#endif
 	return points;
 }
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
