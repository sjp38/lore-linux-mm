Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF178D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:38:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 014013EE0BB
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:38:31 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB28B45DE5B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:38:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AF9CC45DE58
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:38:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 98AEBE78002
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:38:30 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BF7C1DB8043
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:38:30 +0900 (JST)
Date: Fri, 22 Apr 2011 13:31:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V7 1/9] Add kswapd descriptor
Message-Id: <20110422133117.614f8735.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1303446260-21333-2-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-2-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 21 Apr 2011 21:24:12 -0700
Ying Han <yinghan@google.com> wrote:

> There is a kswapd kernel thread for each numa node. We will add a different
> kswapd for each memcg. The kswapd is sleeping in the wait queue headed at
> kswapd_wait field of a kswapd descriptor. The kswapd descriptor stores
> information of node and memcgs, and it allows the global and per-memcg
> background reclaim to share common reclaim algorithms.
> 
> This patch adds the kswapd descriptor and moves the per-node kswapd to use the
> new structure.
> 
> changelog v7..v6:
> 1. revert wait_queue_head change in pgdat. Keep the wait_queue_head in pgdat
> 
> changelog v6..v5:
> 1. rename kswapd_thr to kswapd_tsk
> 2. revert the api change on sleeping_prematurely since memcg doesn't support it.
> 
> changelog v5..v4:
> 1. add comment on kswapds_spinlock
> 2. remove the kswapds_spinlock. we don't need it here since the kswapd and pgdat
> have 1:1 mapping.
> 
> changelog v3..v2:
> 1. move the struct mem_cgroup *kswapd_mem in kswapd sruct to later patch.
> 2. rename thr in kswapd_run to something else.
> 
> changelog v2..v1:
> 1. dynamic allocate kswapd descriptor and initialize the wait_queue_head of pgdat
> at kswapd_run.
> 2. add helper macro is_node_kswapd to distinguish per-node/per-cgroup kswapd
> descriptor.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Seems ok to me. Thank you for merging my dirty patch.

If I add comments to this patch, this patch is just for sharing codes in kswapd
and memory cgroup's background reclaim. By this, it's easy to compare memcg
bacground reclaim and kswapd and will be good for maintainance.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
