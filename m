Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB4FtbJV029253
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 10:55:37 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB4FtW2L075794
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 08:55:33 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB4FtVcQ009356
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 08:55:31 -0700
Message-ID: <47557867.4020304@linux.vnet.ibm.com>
Date: Tue, 04 Dec 2007 21:25:19 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [1/8] clean up : remove unused variable
References: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com> <20071203183537.059262e9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071203183537.059262e9.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This check is not necessary now.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
> Index: linux-2.6.24-rc3-mm2/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.24-rc3-mm2.orig/mm/memcontrol.c
> +++ linux-2.6.24-rc3-mm2/mm/memcontrol.c
> @@ -860,9 +860,7 @@ retry:
>  		/* Avoid race with charge */
>  		atomic_set(&pc->ref_cnt, 0);
>  		if (clear_page_cgroup(page, pc) == pc) {
> -			int active;
>  			css_put(&mem->css);
> -			active = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;

Good Catch, __mem_cgroup_remove_list() takes care of this.

>  			res_counter_uncharge(&mem->res, PAGE_SIZE);
>  			__mem_cgroup_remove_list(pc);
>  			kfree(pc);
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
