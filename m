Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m3B4xNlZ009960
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 10:29:23 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3B4xLv51310888
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 10:29:21 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m3B4xUmh017888
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 04:59:31 GMT
Message-ID: <47FEEFC1.4080509@linux.vnet.ibm.com>
Date: Fri, 11 Apr 2008 10:27:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/3] memcg: remove refcnt
References: <20080408190734.70ab55b0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080408190734.70ab55b0.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This patch is based on 2.6.25-rc8-mm1 + mem_cgroup_per_zone() fix.
> (already in -mm) 
> 
> This patch is a set for removing refcnt from memory resource controller's
> page_cgroup. Instead of ref_cnt, this patch uses page_mapped().
> By this, we can avoid unnecesary locks and calls to some extent.
> 
> Brief Patch Desc.
>  [1/3] change migration handling .... charge new-page before migration.
>  [2/3] remove refcnt             .... remove refcnt from page_cgroup.
>  [3/3] handle swapcache          .... handle swapcache again.
> 
> [1/3] works for better page migration handling.
> [2/3] works for better speed. (depends on [1/3])
> [3/3] works for swap-cache.   (depends on [2/3])
> 
> 
> 
> Unix bench execl result(ia64):
> No controller   :           43.0     2654.7      617.4
> with controller :           43.0     2461.3      572.4
> after this patch:           43.0     2553.6      593.9
> 
> If page_cgroup->ref_cnt is necessary (for some purpose), please tell me.
> 
> Plan:
> I'd like to push this set before complicated radix-tree page_cgroup set.
> But this should be reviewd before going ahead.
> 

I think this makes a lot of sense. We can push the optimizations independent of
the radix tree, so that it is easy to debug and develop.

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
