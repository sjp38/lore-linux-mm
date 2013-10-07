Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2419D6B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 13:24:42 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so7511283pdi.28
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 10:24:41 -0700 (PDT)
Message-ID: <5252EE4A.1060904@redhat.com>
Date: Mon, 07 Oct 2013 13:24:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/63] sched: numa: Mitigate chance that same task always
 updates PTEs
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-14-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> With a trace_printk("working\n"); right after the cmpxchg in
> task_numa_work() we can see that of a 4 thread process, its always the
> same task winning the race and doing the protection change.
> 
> This is a problem since the task doing the protection change has a
> penalty for taking faults -- it is busy when marking the PTEs. If its
> always the same task the ->numa_faults[] get severely skewed.
> 
> Avoid this by delaying the task doing the protection change such that
> it is unlikely to win the privilege again.

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
