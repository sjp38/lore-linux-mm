Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1J76ZJH017654
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 02:06:35 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1J76Zst247642
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 02:06:35 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1J76Yn2015316
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 02:06:35 -0500
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 19 Feb 2008 12:32:32 +0530
Message-Id: <20080219070232.25349.21196.sendpatchset@localhost.localdomain>
Subject: [mm][PATCH 0/4] Add soft limits to the memory controller v2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Herbert Poetzl <herbert@13thfloor.at>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patchset implements the basic changes required to implement soft limits
in the memory controller. A soft limit is a variation of the currently
supported hard limit feature. A memory cgroup can exceed it's soft limit
provided there is no contention for memory.

These patches were tested on a PowerPC box, by running a programs in parallel,
and checking their behaviour for various soft limit values.

These patches were developed on top of 2.6.25-rc2-mm1. Comments, suggestions,
criticism are all welcome!

TODOs:

1. Currently there is no ordering of memory cgroups over their limit.
   We use a simple linked list to maintain a list of groups over their
   limit. In the future, we might want to create a heap of objects ordered
   by the amount by which they exceed soft limit.
2. Distribute the excessive (non-contended) resources between groups
   in the ratio of their soft limits
3. Merge with KAMEZAWA's and YAMAMOTO's water mark and background reclaim
   patches in the long-term


series
------
memory-controller-res_counters-soft-limit-setup.patch
memory-controller-add-soft-limit-interface.patch
memory-controller-reclaim-on-contention.patch
memory-controller-add-soft-limit-documentation.patch

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
