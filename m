Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1R8mNbH011128
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 14:18:23 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1R8mNR6950370
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 14:18:23 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1R8mNcB008766
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 08:48:23 GMT
Date: Wed, 27 Feb 2008 14:12:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 07/15] memcg: mem_cgroup_charge never NULL
Message-ID: <20080227084250.GD2317@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site> <Pine.LNX.4.64.0802252340210.27067@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802252340210.27067@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh@veritas.com> [2008-02-25 23:41:17]:

> My memcgroup patch to fix hang with shmem/tmpfs added NULL page handling
> to mem_cgroup_charge_common.  It seemed convenient at the time, but hard
> to justify now: there's a perfectly appropriate swappage to charge and
> uncharge instead, this is not on any hot path through shmem_getpage,
> and no performance hit was observed from the slight extra overhead.
> 
> So revert that NULL page handling from mem_cgroup_charge_common; and
> make it clearer by bringing page_cgroup_assign_new_page_cgroup into its
> body - that was a helper I found more of a hindrance to understanding.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

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
