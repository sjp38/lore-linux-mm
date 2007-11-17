Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAHHpPBj031525
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 12:51:25 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAHHpPY9089536
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 12:51:25 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAHHpPnS024945
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 12:51:25 -0500
Message-ID: <473F2A1A.8000703@linux.vnet.ibm.com>
Date: Sat, 17 Nov 2007 23:21:22 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [9/10]
 per-zone-lru for memory cgroup
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com> <20071116192642.8c7f07c9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071116192642.8c7f07c9.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This patch implements per-zone lru for memory cgroup.
> This patch makes use of mem_cgroup_per_zone struct for per zone lru.
> 
> LRU can be accessed by
> 
>    mz = mem_cgroup_zoneinfo(mem_cgroup, node, zone);
>    &mz->active_list
>    &mz->inactive_list
> 
>    or
>    mz = page_cgroup_zoneinfo(page_cgroup, node, zone);
>    &mz->active_list
>    &mz->inactive_list
> 
> 
> Changelog v1->v2
>   - merged to mem_cgroup_per_zone struct.
>   - handle page migraiton.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Thanks, this has been a long pending TODO. What is pending now on my
plate is re-organizing res_counter to become aware of the filesystem
hierarchy. I want to split out the LRU lists from the memory controller
and resource counters.

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
