Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 108C38D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:44:59 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8A2343EE0BB
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:44:57 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 73D2C45DE58
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:44:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BDB845DE54
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:44:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DF2EE08001
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:44:57 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 18ACD1DB803C
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:44:57 +0900 (JST)
Date: Fri, 22 Apr 2011 13:38:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V7 5/9] Infrastructure to support per-memcg reclaim.
Message-Id: <20110422133816.60a70c65.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1303446260-21333-6-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-6-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 21 Apr 2011 21:24:16 -0700
Ying Han <yinghan@google.com> wrote:

> Add the kswapd_mem field in kswapd descriptor which links the kswapd
> kernel thread to a memcg. The per-memcg kswapd is sleeping in the wait
> queue headed at kswapd_wait field of the kswapd descriptor.
> 
> The kswapd() function is now shared between global and per-memcg kswapd. It
> is passed in with the kswapd descriptor which contains the information of
> either node or memcg. Then the new function balance_mem_cgroup_pgdat is
> invoked if it is per-mem kswapd thread, and the implementation of the function
> is on the following patch.
> 
> change v7..v6:
> 1. change the threading model of memcg from per-memcg-per-thread to thread-pool.
> this is based on the patch from KAMAZAWA.
> 
> change v6..v5:
> 1. rename is_node_kswapd to is_global_kswapd to match the scanning_global_lru.
> 2. revert the sleeping_prematurely change, but keep the kswapd_try_to_sleep()
> for memcg.
> 
> changelog v4..v3:
> 1. fix up the kswapd_run and kswapd_stop for online_pages() and offline_pages.
> 2. drop the PF_MEMALLOC flag for memcg kswapd for now per KAMAZAWA's request.
> 
> changelog v3..v2:
> 1. split off from the initial patch which includes all changes of the following
> three patches.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Ack. Seems ok to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
