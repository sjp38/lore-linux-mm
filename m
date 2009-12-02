From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 20/24] memcg: add accessor to mem_cgroup.css
Date: Wed, 02 Dec 2009 11:12:51 +0800
Message-ID: <20091202043046.264611775@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 133AC6007C0
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:38 -0500 (EST)
Content-Disposition: inline; filename=memcg-mem_cgroup_css.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

So that an outside user can free the reference count grabbed by
try_get_mem_cgroup_from_page().

CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/memcontrol.h |    7 +++++++
 mm/memcontrol.c            |    5 +++++
 2 files changed, 12 insertions(+)

--- linux-mm.orig/include/linux/memcontrol.h	2009-11-02 10:26:21.000000000 +0800
+++ linux-mm/include/linux/memcontrol.h	2009-11-02 10:26:21.000000000 +0800
@@ -81,6 +81,8 @@ int mm_match_cgroup(const struct mm_stru
 	return cgroup == mem;
 }
 
+extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem);
+
 extern int
 mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr);
 extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
@@ -206,6 +208,11 @@ static inline int task_in_mem_cgroup(str
 	return 1;
 }
 
+static inline struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
+{
+	return NULL;
+}
+
 static inline int
 mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
 {
--- linux-mm.orig/mm/memcontrol.c	2009-11-02 10:26:21.000000000 +0800
+++ linux-mm/mm/memcontrol.c	2009-11-02 10:26:21.000000000 +0800
@@ -282,6 +282,11 @@ mem_cgroup_zoneinfo(struct mem_cgroup *m
 	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
 }
 
+struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
+{
+	return &mem->css;
+}
+
 static struct mem_cgroup_per_zone *
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
