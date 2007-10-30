Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9U60oxU021734
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 02:00:50 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9U60oFw482084
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 02:00:50 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9U60nr6023815
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 02:00:50 -0400
Message-ID: <4726C88B.1030109@linux.vnet.ibm.com>
Date: Tue, 30 Oct 2007 11:30:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][BUGFIX][for -mm] Misc fix for memory cgroup [4/5] skip
 !PageLRU page in mem_cgroup_isolate_pages
References: <20071011135345.5d9a4c06.kamezawa.hiroyu@jp.fujitsu.com> <20071011140115.173d1a9d.kamezawa.hiroyu@jp.fujitsu.com> <20071030144745.1af1cbde.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071030144745.1af1cbde.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> I'm sorry that this patch needs following fix..
> Andrew, could you apply this ?
> (All version I sent has this bug....Sigh)
> 
> Thanks,
> -Kame
> ==
> Bugfix for memory cgroup skip !PageLRU page in mem_cgroup_isolate_pages
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Index: devel-2.6.23-mm1/mm/memcontrol.c
> ===================================================================
> --- devel-2.6.23-mm1.orig/mm/memcontrol.c
> +++ devel-2.6.23-mm1/mm/memcontrol.c
> @@ -260,7 +260,7 @@ unsigned long mem_cgroup_isolate_pages(u
>  	spin_lock(&mem_cont->lru_lock);
>  	scan = 0;
>  	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
> -		if (scan++ > nr_taken)
> +		if (scan++ > nr_to_scan)
>  			break;
>  		page = pc->page;
>  		VM_BUG_ON(!pc);
> 

Good catch! Sorry, I missed it in the review

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
