Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAC55igS016510
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 00:05:44 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAC55hGS466874
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 00:05:43 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAC55hfc020462
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 00:05:43 -0500
Message-ID: <4737DF1E.1020701@linux.vnet.ibm.com>
Date: Mon, 12 Nov 2007 10:35:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 3/6 mm] memcgroup: fix try_to_free order
References: <Pine.LNX.4.64.0711090700530.21638@blonde.wat.veritas.com> <Pine.LNX.4.64.0711090710310.21663@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0711090710310.21663@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Why does try_to_free_mem_cgroup_pages try for order 1 pages?  It's called
> when mem_cgroup_charge_common would go over the limit, and that's adding
> an order 0 page.  I see no reason: it has to be a typo: fix it.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> Insert just after memory-controller-add-per-container-lru-and-reclaim-v7.patch
> 
>  mm/vmscan.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- patch2/mm/vmscan.c	2007-11-08 15:46:21.000000000 +0000
> +++ patch3/mm/vmscan.c	2007-11-08 15:48:08.000000000 +0000
> @@ -1354,7 +1354,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  		.may_swap = 1,
>  		.swap_cluster_max = SWAP_CLUSTER_MAX,
>  		.swappiness = vm_swappiness,
> -		.order = 1,
> +		.order = 0,
>  		.mem_cgroup = mem_cont,
>  		.isolate_pages = mem_cgroup_isolate_pages,
>  	};

Thanks for catching this, it is a typo

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
