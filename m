Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id B7DD46B005D
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:28:03 -0500 (EST)
Received: by iacb35 with SMTP id b35so33317561iac.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:28:03 -0800 (PST)
Date: Sat, 31 Dec 2011 23:27:59 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/5] memcg: replace MEM_CONT by MEM_RES_CTLR
In-Reply-To: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112312326540.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

Correct an #endif comment in memcontrol.h from MEM_CONT to MEM_RES_CTLR.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/memcontrol.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm.orig/include/linux/memcontrol.h	2011-12-30 21:21:34.923338593 -0800
+++ mmotm/include/linux/memcontrol.h	2011-12-30 21:21:51.939338993 -0800
@@ -396,7 +396,7 @@ static inline void mem_cgroup_replace_pa
 static inline void mem_cgroup_reset_owner(struct page *page)
 {
 }
-#endif /* CONFIG_CGROUP_MEM_CONT */
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
 static inline bool

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
