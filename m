Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 13F1B900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 03:43:17 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4ACD03EE0BD
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 16:43:14 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2904645DE51
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 16:43:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 10D7C45DE4F
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 16:43:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 004221DB8041
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 16:43:14 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B36CE1DB8040
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 16:43:13 +0900 (JST)
Date: Tue, 30 Aug 2011 16:35:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-Id: <20110830163545.487dc57f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110808124333.GA31739@redhat.com>
	<20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
	<20110829155113.GA21661@redhat.com>
	<20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830070424.GA13061@redhat.com>
	<20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 30 Aug 2011 16:20:50 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Hmm...removing hierarchy part completely seems fine to me.
> 
Another idea here.

==
Revert hierarchy support in vmscan_stat.

It turns out to be further study/use-case is required.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   27 ++-------------------------
 include/linux/memcontrol.h       |    1 -
 mm/memcontrol.c                  |   25 -------------------------
 3 files changed, 2 insertions(+), 51 deletions(-)

Index: mmotm-Aug29/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-Aug29.orig/Documentation/cgroups/memory.txt
+++ mmotm-Aug29/Documentation/cgroups/memory.txt
@@ -448,8 +448,8 @@ memory cgroup creation and can be reset 
 
 This file contains following statistics.
 
-[param]_[file_or_anon]_pages_by_[reason]_[under_heararchy]
-[param]_elapsed_ns_by_[reason]_[under_hierarchy]
+[param]_[file_or_anon]_pages_by_[reason]
+[param]_elapsed_ns_by_[reason]
 
 For example,
 
@@ -470,9 +470,6 @@ Now, 2 reason are supported
   system - global memory pressure + softlimit
            (global memory pressure not under softlimit is not handled now)
 
-When under_hierarchy is added in the tail, the number indicates the
-total memcg scan of its children and itself.
-
 elapsed_ns is a elapsed time in nanosecond. This may include sleep time
 and not indicates CPU usage. So, please take this as just showing
 latency.
@@ -500,26 +497,6 @@ freed_pages_by_system 0
 freed_anon_pages_by_system 0
 freed_file_pages_by_system 0
 elapsed_ns_by_system 0
-scanned_pages_by_limit_under_hierarchy 9471864
-scanned_anon_pages_by_limit_under_hierarchy 6640629
-scanned_file_pages_by_limit_under_hierarchy 2831235
-rotated_pages_by_limit_under_hierarchy 4243974
-rotated_anon_pages_by_limit_under_hierarchy 3971968
-rotated_file_pages_by_limit_under_hierarchy 272006
-freed_pages_by_limit_under_hierarchy 2318492
-freed_anon_pages_by_limit_under_hierarchy 962052
-freed_file_pages_by_limit_under_hierarchy 1356440
-elapsed_ns_by_limit_under_hierarchy 351386416101
-scanned_pages_by_system_under_hierarchy 0
-scanned_anon_pages_by_system_under_hierarchy 0
-scanned_file_pages_by_system_under_hierarchy 0
-rotated_pages_by_system_under_hierarchy 0
-rotated_anon_pages_by_system_under_hierarchy 0
-rotated_file_pages_by_system_under_hierarchy 0
-freed_pages_by_system_under_hierarchy 0
-freed_anon_pages_by_system_under_hierarchy 0
-freed_file_pages_by_system_under_hierarchy 0
-elapsed_ns_by_system_under_hierarchy 0
 
 5.3 swappiness
 
Index: mmotm-Aug29/mm/memcontrol.c
===================================================================
--- mmotm-Aug29.orig/mm/memcontrol.c
+++ mmotm-Aug29/mm/memcontrol.c
@@ -229,7 +229,6 @@ enum {
 struct scanstat {
 	spinlock_t	lock;
 	unsigned long	stats[NR_SCAN_CONTEXT][NR_SCANSTATS];
-	unsigned long	rootstats[NR_SCAN_CONTEXT][NR_SCANSTATS];
 };
 
 const char *scanstat_string[NR_SCANSTATS] = {
@@ -246,7 +245,6 @@ const char *scanstat_string[NR_SCANSTATS
 };
 #define SCANSTAT_WORD_LIMIT	"_by_limit"
 #define SCANSTAT_WORD_SYSTEM	"_by_system"
-#define SCANSTAT_WORD_HIERARCHY	"_under_hierarchy"
 
 
 /*
@@ -1710,11 +1708,6 @@ static void mem_cgroup_record_scanstat(s
 	spin_lock(&memcg->scanstat.lock);
 	__mem_cgroup_record_scanstat(memcg->scanstat.stats[context], rec);
 	spin_unlock(&memcg->scanstat.lock);
-
-	memcg = rec->root;
-	spin_lock(&memcg->scanstat.lock);
-	__mem_cgroup_record_scanstat(memcg->scanstat.rootstats[context], rec);
-	spin_unlock(&memcg->scanstat.lock);
 }
 
 /*
@@ -1758,8 +1751,6 @@ static int mem_cgroup_hierarchical_recla
 	else
 		rec.context = SCAN_BY_LIMIT;
 
-	rec.root = root_memcg;
-
 	while (1) {
 		victim = mem_cgroup_select_victim(root_memcg);
 		if (victim == root_memcg) {
@@ -4728,20 +4719,6 @@ static int mem_cgroup_vmscan_stat_read(s
 		cb->fill(cb, string, memcg->scanstat.stats[SCAN_BY_SYSTEM][i]);
 	}
 
-	for (i = 0; i < NR_SCANSTATS; i++) {
-		strcpy(string, scanstat_string[i]);
-		strcat(string, SCANSTAT_WORD_LIMIT);
-		strcat(string, SCANSTAT_WORD_HIERARCHY);
-		cb->fill(cb,
-			string, memcg->scanstat.rootstats[SCAN_BY_LIMIT][i]);
-	}
-	for (i = 0; i < NR_SCANSTATS; i++) {
-		strcpy(string, scanstat_string[i]);
-		strcat(string, SCANSTAT_WORD_SYSTEM);
-		strcat(string, SCANSTAT_WORD_HIERARCHY);
-		cb->fill(cb,
-			string, memcg->scanstat.rootstats[SCAN_BY_SYSTEM][i]);
-	}
 	return 0;
 }
 
@@ -4752,8 +4729,6 @@ static int mem_cgroup_reset_vmscan_stat(
 
 	spin_lock(&memcg->scanstat.lock);
 	memset(&memcg->scanstat.stats, 0, sizeof(memcg->scanstat.stats));
-	memset(&memcg->scanstat.rootstats,
-		0, sizeof(memcg->scanstat.rootstats));
 	spin_unlock(&memcg->scanstat.lock);
 	return 0;
 }
Index: mmotm-Aug29/include/linux/memcontrol.h
===================================================================
--- mmotm-Aug29.orig/include/linux/memcontrol.h
+++ mmotm-Aug29/include/linux/memcontrol.h
@@ -42,7 +42,6 @@ extern unsigned long mem_cgroup_isolate_
 
 struct memcg_scanrecord {
 	struct mem_cgroup *mem; /* scanend memory cgroup */
-	struct mem_cgroup *root; /* scan target hierarchy root */
 	int context;		/* scanning context (see memcontrol.c) */
 	unsigned long nr_scanned[2]; /* the number of scanned pages */
 	unsigned long nr_rotated[2]; /* the number of rotated pages */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
