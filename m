Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F364D6B0071
	for <linux-mm@kvack.org>; Sun, 24 Jan 2010 11:06:08 -0500 (EST)
Received: by qyk40 with SMTP id 40so1491113qyk.22
        for <linux-mm@kvack.org>; Sun, 24 Jan 2010 08:06:07 -0800 (PST)
From: Thiago Farina <tfransosi@gmail.com>
Subject: [PATCH 4/4] mm/memcontrol.c: fix "integer as NULL pointer" warning.
Date: Sun, 24 Jan 2010 11:03:51 -0500
Message-Id: <1264349038-1766-4-git-send-email-tfransosi@gmail.com>
In-Reply-To: <1264349038-1766-1-git-send-email-tfransosi@gmail.com>
References: <1264349038-1766-1-git-send-email-tfransosi@gmail.com>
Sender: owner-linux-mm@kvack.org
To: tfransosi@gmail.com
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

mm/memcontrol.c:2548:32: warning: Using plain integer as NULL pointer

Signed-off-by: Thiago Farina <tfransosi@gmail.com>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 954032b..d813823 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2545,7 +2545,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 		pc = list_entry(list->prev, struct page_cgroup, lru);
 		if (busy == pc) {
 			list_move(&pc->lru, list);
-			busy = 0;
+			busy = NULL;
 			spin_unlock_irqrestore(&zone->lru_lock, flags);
 			continue;
 		}
-- 
1.6.6.1.383.g5a9f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
