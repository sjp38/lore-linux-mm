Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 845066B0034
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 11:46:08 -0400 (EDT)
Date: Thu, 1 Aug 2013 16:46:04 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 17/18] sched: Retry migration of tasks to CPU on a
 preferred node
Message-ID: <20130801154604.GF2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-18-git-send-email-mgorman@suse.de>
 <20130801051327.GF4880@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130801051327.GF4880@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 01, 2013 at 10:43:27AM +0530, Srikar Dronamraju wrote:
> * Mel Gorman <mgorman@suse.de> [2013-07-15 16:20:19]:
> 
> > When a preferred node is selected for a tasks there is an attempt to migrate
> > the task to a CPU there. This may fail in which case the task will only
> > migrate if the active load balancer takes action. This may never happen if
> 
> Apart from load imbalance or heavily loaded cpus on the preferred node,
> what could be the other reasons for migration failure with
> migrate_task_to()?

These were the reasons I expected that migration might fail.

> I see it almost similar to active load balance except
> for pushing instead of pulling tasks.
> 
> If load imbalance is the only reason, do we need to retry? If the task
> is really so attached to memory on that node, shouldn't we getting
> task_numa_placement hit before the next 5 seconds? 
> 

Depends on the PTE scanning rate.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
