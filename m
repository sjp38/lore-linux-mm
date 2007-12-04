Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB4G1maQ017493
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 11:01:48 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB4G1lis125478
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 11:01:47 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB4G1lX2017192
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 11:01:47 -0500
Message-ID: <475579DC.6020006@linux.vnet.ibm.com>
Date: Tue, 04 Dec 2007 21:31:32 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [2/8] add BUG_ON() in mem_cgroup_zoneinfo
References: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com> <20071203183639.48a4b1f3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071203183639.48a4b1f3.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This should be BUG_ON(). I misunderstood initialization path.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  mm/memcontrol.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> Index: linux-2.6.24-rc3-mm2/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.24-rc3-mm2.orig/mm/memcontrol.c
> +++ linux-2.6.24-rc3-mm2/mm/memcontrol.c
> @@ -206,8 +206,7 @@ static void mem_cgroup_charge_statistics
>  static inline struct mem_cgroup_per_zone *
>  mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
>  {
> -	if (!mem->info.nodeinfo[nid])
> -		return NULL;
> +	BUG_ON(!mem->info.nodeinfo[nid]);
>  	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
>  }
> 
> 

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
