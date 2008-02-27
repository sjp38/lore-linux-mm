Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1R8hsOC020247
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 14:13:54 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1R8hsT4962808
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 14:13:54 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1R8hrFw008969
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 08:43:53 GMT
Date: Wed, 27 Feb 2008 14:08:21 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 06/15] memcg: bad page if page_cgroup when free
Message-ID: <20080227083646.GC2317@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site> <Pine.LNX.4.64.0802252339310.27067@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802252339310.27067@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh@veritas.com> [2008-02-25 23:40:14]:

> Replace free_hot_cold_page's VM_BUG_ON(page_get_page_cgroup(page)) by a
> "Bad page state" and clear: most users don't have CONFIG_DEBUG_VM on, and
> if it were set here, it'd likely cause corruption when the page is reused.
> 
> Don't use page_assign_page_cgroup to clear it: that should be private to
> memcontrol.c, and always called with the lock taken; and memmap_init_zone
> doesn't need it either - like page->mapping and other pointers throughout
> the kernel, Linux assumes pointers in zeroed structures are NULL pointers.
> 
> Instead use page_reset_bad_cgroup, added to memcontrol.h for this only.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Looks good to me

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
