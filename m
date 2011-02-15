Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3013F8D0039
	for <linux-mm@kvack.org>; Mon, 14 Feb 2011 21:43:49 -0500 (EST)
Date: Tue, 15 Feb 2011 11:39:34 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: +
 memcg-add-memcg-sanity-checks-at-allocating-and-freeing-pages-update.patch
 added to -mm tree
Message-Id: <20110215113934.46d057ae.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <201102042108.p14L8doV019035@imap1.linux-foundation.org>
References: <201102042108.p14L8doV019035@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: balbir@linux.vnet.ibm.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>

This is a aditional patch for:

  memcg-add-memcg-sanity-checks-at-allocating-and-freeing-pages.patch

and can be applied after:

  memcg-add-memcg-sanity-checks-at-allocating-and-freeing-pages-update.patch

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

- print pc->flags in hex.
- print the path of the cgroup in the same line as pc->mem_cgroup.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 686f1ce..7e5cc5c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3040,7 +3040,7 @@ void mem_cgroup_print_bad_page(struct page *page)
 		int ret = -1;
 		char *path;
 
-		printk(KERN_ALERT "pc:%p pc->flags:%ld pc->mem_cgroup:%p",
+		printk(KERN_ALERT "pc:%p pc->flags:%lx pc->mem_cgroup:%p",
 		       pc, pc->flags, pc->mem_cgroup);
 
 		path = kmalloc(PATH_MAX, GFP_KERNEL);
@@ -3051,7 +3051,7 @@ void mem_cgroup_print_bad_page(struct page *page)
 			rcu_read_unlock();
 		}
 
-		printk(KERN_ALERT "(%s)\n",
+		printk(KERN_CONT "(%s)\n",
 				(ret < 0) ? "cannot get the path" : path);
 		kfree(path);
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
