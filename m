Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8019F6B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 20:13:18 -0400 (EDT)
Date: Fri, 4 Sep 2009 08:58:26 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: + memcg-show-swap-usage-in-stat-file.patch added to -mm tree
Message-Id: <20090904085826.ba745164.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <200908242004.n7OK4VT8016136@imap1.linux-foundation.org>
References: <200908242004.n7OK4VT8016136@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a bugfix patch for memcg-show-swap-usage-in-stat-file.patch in mmotm.

I'm sorry for bothering you.

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

The usage of swap should be showed in bytes.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae80de0..927e7e6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2712,7 +2712,7 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
 	s->stat[MCS_PGPGOUT] += val;
 	if (do_swap_account) {
 		val = mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_SWAPOUT);
-		s->stat[MCS_SWAP] += val;
+		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
 
 	/* per zone stat */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
