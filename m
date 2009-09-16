Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A45486B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 03:37:37 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id n8G7bYHI025810
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 13:07:34 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8G7bYgf2306140
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 13:07:34 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n8G7bX8B018649
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 17:37:33 +1000
Date: Wed, 16 Sep 2009 13:07:27 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: memcg merge for 2.6.32 (was Re: 2.6.32 -mm merge plans)
Message-ID: <20090916073727.GP4846@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090915161535.db0a6904.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> [2009-09-15 16:15:35]:

> 
> memcg-remove-the-overhead-associated-with-the-root-cgroup.patch
> memcg-remove-the-overhead-associated-with-the-root-cgroup-fix.patch
> memcg-remove-the-overhead-associated-with-the-root-cgroup-fix-2.patch
> #memcg-add-comments-explaining-memory-barriers.patch: needs update (Balbir)
> memcg-add-comments-explaining-memory-barriers.patch
> memcg-add-comments-explaining-memory-barriers-checkpatch-fixes.patch
> memory-controller-soft-limit-documentation-v9.patch
> memory-controller-soft-limit-interface-v9.patch
> memory-controller-soft-limit-organize-cgroups-v9.patch
> memory-controller-soft-limit-organize-cgroups-v9-fix.patch
> memory-controller-soft-limit-refactor-reclaim-flags-v9.patch
> memory-controller-soft-limit-reclaim-on-contention-v9.patch
> memory-controller-soft-limit-reclaim-on-contention-v9-fix.patch
> memory-controller-soft-limit-reclaim-on-contention-v9-fix-softlimit-css-refcnt-handling.patch
> memory-controller-soft-limit-reclaim-on-contention-v9-fix-softlimit-css-refcnt-handling-fix.patch
> memcg-improve-resource-counter-scalability.patch
> memcg-improve-resource-counter-scalability-checkpatch-fixes.patch
> memcg-improve-resource-counter-scalability-v5.patch
> memcg-show-swap-usage-in-stat-file.patch
> memcg-show-swap-usage-in-stat-file-fix.patch
> 
>   Merge after checking with Balbir


I think these are ready for merging, I'll let Kame and Daisuke comment
on it more. The resource counter scalability patch is the most
important patch in the series.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
