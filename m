Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1QFwM6n023730
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 21:28:22 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1QFwMQO1007846
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 21:28:22 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1QFwMe9026260
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 15:58:22 GMT
Date: Tue, 26 Feb 2008 21:22:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 02/15] memcg: move_lists on page not page_cgroup
Message-ID: <20080226155252.GA25074@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site> <Pine.LNX.4.64.0802252335400.27067@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802252335400.27067@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh@veritas.com> [2008-02-25 23:36:20]:

> Each caller of mem_cgroup_move_lists is having to use page_get_page_cgroup:
> it's more convenient if it acts upon the page itself not the page_cgroup;
> and in a later patch this becomes important to handle within memcontrol.c.
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
