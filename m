Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id A9E4D6B0036
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 15:09:29 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so7492137pbb.19
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 12:09:29 -0700 (PDT)
Message-ID: <525306DE.4090102@redhat.com>
Date: Mon, 07 Oct 2013 15:09:18 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 43/63] sched: numa: Use {cpu, pid} to create task groups
 for shared faults
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-44-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-44-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> While parallel applications tend to align their data on the cache
> boundary, they tend not to align on the page or THP boundary.
> Consequently tasks that partition their data can still "false-share"
> pages presenting a problem for optimal NUMA placement.
> 
> This patch uses NUMA hinting faults to chain tasks together into
> numa_groups. As well as storing the NID a task was running on when
> accessing a page a truncated representation of the faulting PID is
> stored. If subsequent faults are from different PIDs it is reasonable
> to assume that those two tasks share a page and are candidates for
> being grouped together. Note that this patch makes no scheduling
> decisions based on the grouping information.
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
