Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 70ECF6B0036
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 15:14:20 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so7689346pdi.33
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 12:14:20 -0700 (PDT)
Message-ID: <52530800.1070902@redhat.com>
Date: Mon, 07 Oct 2013 15:14:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 55/63] sched: numa: Avoid migrating tasks that are placed
 on their preferred node
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-56-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-56-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> This patch classifies scheduler domains and runqueues into types depending
> the number of tasks that are about their NUMA placement and the number
> that are currently running on their preferred node. The types are
> 
> regular: There are tasks running that do not care about their NUMA
> 	placement.
> 
> remote: There are tasks running that care about their placement but are
> 	currently running on a node remote to their ideal placement
> 
> all: No distinction
> 
> To implement this the patch tracks the number of tasks that are optimally
> NUMA placed (rq->nr_preferred_running) and the number of tasks running
> that care about their placement (nr_numa_running). The load balancer
> uses this information to avoid migrating idea placed NUMA tasks as long
> as better options for load balancing exists. For example, it will not
> consider balancing between a group whose tasks are all perfectly placed
> and a group with remote tasks.
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
