Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 13E676B004F
	for <linux-mm@kvack.org>; Sat, 14 Jan 2012 19:09:38 -0500 (EST)
Received: by iafj26 with SMTP id j26so8431380iaf.14
        for <linux-mm@kvack.org>; Sat, 14 Jan 2012 16:09:37 -0800 (PST)
Date: Sat, 14 Jan 2012 16:09:30 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/5] memcg: replace MEM_CONT by MEM_RES_CTLR
In-Reply-To: <alpine.LSU.2.00.1201141550170.1261@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1201141608040.1261@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils> <20120109130259.GD3588@cmpxchg.org> <alpine.LSU.2.00.1201141550170.1261@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org

Correct an #endif comment in memcontrol.h from MEM_CONT to MEM_RES_CTLR.

Signed-off-by: Hugh Dickins <hughd@google.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
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
