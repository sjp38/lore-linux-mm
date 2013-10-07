Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id AB7B36B0036
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 14:40:25 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so7483036pbc.17
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 11:40:25 -0700 (PDT)
Message-ID: <5252FFFD.4070002@redhat.com>
Date: Mon, 07 Oct 2013 14:39:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 22/63] sched: Favour moving tasks towards the preferred
 node
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-23-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-23-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> This patch favours moving tasks towards NUMA node that recorded a higher
> number of NUMA faults during active load balancing.  Ideally this is
> self-reinforcing as the longer the task runs on that node, the more faults
> it should incur causing task_numa_placement to keep the task running on that
> node. In reality a big weakness is that the nodes CPUs can be overloaded
> and it would be more efficient to queue tasks on an idle node and migrate
> to the new node. This would require additional smarts in the balancer so
> for now the balancer will simply prefer to place the task on the preferred
> node for a PTE scans which is controlled by the numa_balancing_settle_count
> sysctl. Once the settle_count number of scans has complete the schedule
> is free to place the task on an alternative node if the load is imbalanced.
> 
> [srikar@linux.vnet.ibm.com: Fixed statistics]
> [peterz@infradead.org: Tunable and use higher faults instead of preferred]
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
