Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 460416B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 00:29:09 -0500 (EST)
Received: by dald2 with SMTP id d2so1510625dal.9
        for <linux-mm@kvack.org>; Tue, 28 Feb 2012 21:29:08 -0800 (PST)
Date: Tue, 28 Feb 2012 21:28:40 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH next] memcg: remove PCG_FILE_MAPPED fix cosmetic fix
In-Reply-To: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202282127110.4875@eggly.anvils>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

mem_cgroup_move_account() begins with "anon = PageAnon(page)", and
then anon is used thereafter: testing PageAnon(page) in the middle
makes the reader wonder if there's some race to guard against - no.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 3.3-rc5-next/mm/memcontrol.c	2012-02-27 09:56:59.072001463 -0800
+++ linux/mm/memcontrol.c	2012-02-28 20:45:43.488100423 -0800
@@ -2560,7 +2560,7 @@ static int mem_cgroup_move_account(struc
 
 	move_lock_mem_cgroup(from, &flags);
 
-	if (!PageAnon(page) && page_mapped(page)) {
+	if (!anon && page_mapped(page)) {
 		/* Update mapped_file data for mem_cgroup */
 		preempt_disable();
 		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
