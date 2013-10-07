Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id D1F166B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 14:58:16 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so7500132pbc.4
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 11:58:16 -0700 (PDT)
Message-ID: <52530438.9060104@redhat.com>
Date: Mon, 07 Oct 2013 14:58:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 32/63] sched: Avoid overloading CPUs on a preferred NUMA
 node
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-33-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-33-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> This patch replaces find_idlest_cpu_node with task_numa_find_cpu.
> find_idlest_cpu_node has two critical limitations. It does not take the
> scheduling class into account when calculating the load and it is unsuitable
> for using when comparing loads between NUMA nodes.
> 
> task_numa_find_cpu uses similar load calculations to wake_affine() when
> selecting the least loaded CPU within a scheduling domain common to the
> source and destimation nodes. It avoids causing CPU load imbalances in
> the machine by refusing to migrate if the relative load on the target
> CPU is higher than the source CPU.
> 
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
