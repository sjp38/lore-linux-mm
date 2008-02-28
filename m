Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1SIMhkR006325
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 05:22:43 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1SIQ8ar163072
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 05:26:09 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1SIMZad005280
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 05:22:35 +1100
Date: Thu, 28 Feb 2008 23:52:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 08/15] memcg: remove mem_cgroup_uncharge
Message-ID: <20080228181853.GE2317@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site> <Pine.LNX.4.64.0802252341250.27067@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802252341250.27067@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh@veritas.com> [2008-02-25 23:42:05]:

> Nothing uses mem_cgroup_uncharge apart from mem_cgroup_uncharge_page,
> (a trivial wrapper around it) and mem_cgroup_end_migration (which does
> the same as mem_cgroup_uncharge_page).  And it often ends up having to
> lock just to let its caller unlock.  Remove it (but leave the silly
> locking until a later patch).
> 
> Moved mem_cgroup_cache_charge next to mem_cgroup_charge in memcontrol.h.
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
