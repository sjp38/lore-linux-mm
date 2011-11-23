Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A769D6B00CE
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 10:43:04 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 6/8] mm: memcg: remove unneeded checks from uncharge_page()
Date: Wed, 23 Nov 2011 16:42:29 +0100
Message-Id: <1322062951-1756-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <jweiner@redhat.com>

mem_cgroup_uncharge_page() is only called on either freshly allocated
pages without page->mapping or on rmapped PageAnon() pages.  There is
no need to check for a page->mapping that is not an anon_vma.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/memcontrol.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0d10be4..b9a3b94 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2989,8 +2989,6 @@ void mem_cgroup_uncharge_page(struct page *page)
 	/* early check. */
 	if (page_mapped(page))
 		return;
-	if (page->mapping && !PageAnon(page))
-		return;
 	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED);
 }
 
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
