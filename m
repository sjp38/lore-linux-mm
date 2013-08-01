Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id E538B6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 01:18:59 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 1 Aug 2013 01:18:58 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 14B1D38C8027
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 01:18:55 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r715GmNS129170
	for <linux-mm@kvack.org>; Thu, 1 Aug 2013 01:18:56 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r715DV5v015576
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 23:13:32 -0600
Date: Thu, 1 Aug 2013 10:43:27 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 17/18] sched: Retry migration of tasks to CPU on a
 preferred node
Message-ID: <20130801051327.GF4880@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-18-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1373901620-2021-18-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Mel Gorman <mgorman@suse.de> [2013-07-15 16:20:19]:

> When a preferred node is selected for a tasks there is an attempt to migrate
> the task to a CPU there. This may fail in which case the task will only
> migrate if the active load balancer takes action. This may never happen if

Apart from load imbalance or heavily loaded cpus on the preferred node,
what could be the other reasons for migration failure with
migrate_task_to()? I see it almost similar to active load balance except
for pushing instead of pulling tasks.

If load imbalance is the only reason, do we need to retry? If the task
is really so attached to memory on that node, shouldn't we getting
task_numa_placement hit before the next 5 seconds? 

> the conditions are not right. This patch will check at NUMA hinting fault
> time if another attempt should be made to migrate the task. It will only
> make an attempt once every five seconds.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
