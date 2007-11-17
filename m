Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAHG7bGf008869
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 11:07:37 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAHG7VlO082684
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 09:07:37 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAHG7Vv3018523
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 09:07:31 -0700
Message-ID: <473F11B5.5050009@linux.vnet.ibm.com>
Date: Sat, 17 Nov 2007 21:37:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [3/10]
 add per zone active/inactive counter to mem_cgroup
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com> <20071116191744.d8e2b3a5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071116191744.d8e2b3a5.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Counting active/inactive per-zone in memory controller.
> 
> This patch adds per-zone status in memory cgroup.
> These values are often read (as per-zone value) by page reclaiming.
> 
> In current design, per-zone stat is just a unsigned long value and 
> not an atomic value because they are modified only under lru_lock.
> (for avoiding atomic_t ops.)
> 
> This patch adds ACTIVE and INACTIVE per-zone status values.
> 
> For handling per-zone status, this patch adds
>   struct mem_cgroup_per_zone {
> 		...
>   }
> and some helper functions. This will be useful to add per-zone objects
> in mem_cgroup.
> 
> This patch turns memory controller's early_init to be 0 for calling 
> kmalloc().
> 
> Changelog V1 -> V2
>   - added mem_cgroup_per_zone struct.
>       This will help following patches to implement per-zone objects and
>       pack them into a struct.
>   - added __mem_cgroup_add_list() and __mem_cgroup_remove_list()
>   - fixed page migration handling.
>   - renamed zstat to info (per-zone-info)
>     This will be place for per-zone information(lru, lock, ..)
>   - use page_cgroup_nid()/zid() funcs.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

The code looks OK to me, pending test on a real NUMA box

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
