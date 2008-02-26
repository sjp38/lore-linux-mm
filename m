Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1Q2l9jx001566
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 13:47:09 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1Q2lK0j3641402
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 13:47:21 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1Q2lKdN022431
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 13:47:20 +1100
Message-ID: <47C37C74.4020909@linux.vnet.ibm.com>
Date: Tue, 26 Feb 2008 08:11:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 01/15] memcg: mm_match_cgroup not vm_match_cgroup
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site> <Pine.LNX.4.64.0802252334190.27067@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0802252334190.27067@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> vm_match_cgroup is a perverse name for a macro to match mm with cgroup:
> rename it mm_match_cgroup, matching mm_init_cgroup and mm_free_cgroup.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Agreed

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
