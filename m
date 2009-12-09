Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E990F60021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 10:49:17 -0500 (EST)
Received: by fxm9 with SMTP id 9so6721892fxm.10
        for <linux-mm@kvack.org>; Wed, 09 Dec 2009 07:49:16 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH] [TRIVIAL] memcg: fix memory.memsw.usage_in_bytes for root cgroup
Date: Wed,  9 Dec 2009 17:48:58 +0200
Message-Id: <1260373738-17179-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

We really want to take MEM_CGROUP_STAT_SWAPOUT into account.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
Cc: stable@kernel.org
---
 mm/memcontrol.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f99f599..6314015 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2541,6 +2541,7 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 			val += idx_val;
 			mem_cgroup_get_recursive_idx_stat(mem,
 				MEM_CGROUP_STAT_SWAPOUT, &idx_val);
+			val += idx_val;
 			val <<= PAGE_SHIFT;
 		} else
 			val = res_counter_read_u64(&mem->memsw, name);
-- 
1.6.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
