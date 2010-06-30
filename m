Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 289166B01CC
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:31:04 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U9V2PG017072
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 18:31:02 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 03C8345DE52
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:31:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D8DFC45DE4F
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:31:01 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BE0D8E08002
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:31:01 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 75B691DB803F
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:31:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 06/11] oom: kill duplicate OOM_DISABLE check
In-Reply-To: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
Message-Id: <20100630183019.AA59.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Jun 2010 18:31:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


select_bad_process() and badness() have the same OOM_DISABLE check.
This patch kill one.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index fcbd21b..f5d903f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -350,9 +350,6 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 			*ppoints = ULONG_MAX;
 		}
 
-		if (p->signal->oom_adj == OOM_DISABLE)
-			continue;
-
 		points = badness(p, mem, nodemask, uptime.tv_sec);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
