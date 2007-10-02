Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l924Lhpe018293
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 14:21:43 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l924PGeP252282
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 14:25:16 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l924InKI008553
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 14:18:50 +1000
Message-ID: <4701C737.8070906@linux.vnet.ibm.com>
Date: Tue, 02 Oct 2007 09:51:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Memory controller merge (was Re: -mm merge plans for 2.6.24)
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
In-Reply-To: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> memory-controller-add-documentation.patch
> memory-controller-resource-counters-v7.patch
> memory-controller-resource-counters-v7-fix.patch
> memory-controller-containers-setup-v7.patch
> memory-controller-accounting-setup-v7.patch
> memory-controller-memory-accounting-v7.patch
> memory-controller-memory-accounting-v7-fix.patch
> memory-controller-memory-accounting-v7-fix-swapoff-breakage-however.patch
> memory-controller-task-migration-v7.patch
> memory-controller-add-per-container-lru-and-reclaim-v7.patch
> memory-controller-add-per-container-lru-and-reclaim-v7-fix.patch
> memory-controller-add-per-container-lru-and-reclaim-v7-fix-2.patch
> memory-controller-add-per-container-lru-and-reclaim-v7-cleanup.patch
> memory-controller-improve-user-interface.patch
> memory-controller-oom-handling-v7.patch
> memory-controller-oom-handling-v7-vs-oom-killer-stuff.patch
> memory-controller-add-switch-to-control-what-type-of-pages-to-limit-v7.patch
> memory-controller-add-switch-to-control-what-type-of-pages-to-limit-v7-cleanup.patch
> memory-controller-add-switch-to-control-what-type-of-pages-to-limit-v7-fix-2.patch
> memory-controller-make-page_referenced-container-aware-v7.patch
> memory-controller-make-charging-gfp-mask-aware.patch
> memory-controller-make-charging-gfp-mask-aware-fix.patch
> memory-controller-bug_on.patch
> mem-controller-gfp-mask-fix.patch
> memcontrol-move-mm_cgroup-to-header-file.patch
> memcontrol-move-oom-task-exclusion-to-tasklist.patch
> memcontrol-move-oom-task-exclusion-to-tasklist-fix.patch
> oom-add-sysctl-to-enable-task-memory-dump.patch
> kswapd-should-only-wait-on-io-if-there-is-io.patch
> 
>   Hold.  This needs a serious going-over by page reclaim people.
> 

Hi, Andrew,

I mostly agree with your decision. I am a little concerned however
that as we develop and add more features (a.k.a better statistics/
forced reclaim), which are very important; the code base gets larger,
the review takes longer :)

I was hopeful of getting the bare minimal infrastructure for memory
control in mainline, so that review is easy and additional changes
can be well reviewed as well.

Here are the pros and cons of merging the memory controller

Pros
1. Smaller size, easy to review and merge
2. Incremental development, makes it easier to maintain the
   code

Cons
1. Needs more review like you said
2. Although the UI is stable, it's a good chance to review
   it once more before merging the code into mainline

Having said that, I'll continue testing the patches and make the
solution more complete and usable.


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
