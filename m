Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9DEF66B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 14:39:39 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so7526140pbb.0
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 11:39:39 -0700 (PDT)
Message-ID: <5252FFD8.2020800@redhat.com>
Date: Mon, 07 Oct 2013 14:39:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 21/63] sched: Update NUMA hinting faults once per scan
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-22-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-22-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> NUMA hinting fault counts and placement decisions are both recorded in the
> same array which distorts the samples in an unpredictable fashion. The values
> linearly accumulate during the scan and then decay creating a sawtooth-like
> pattern in the per-node counts. It also means that placement decisions are
> time sensitive. At best it means that it is very difficult to state that
> the buffer holds a decaying average of past faulting behaviour. At worst,
> it can confuse the load balancer if it sees one node with an artifically high
> count due to very recent faulting activity and may create a bouncing effect.
> 
> This patch adds a second array. numa_faults stores the historical data
> which is used for placement decisions. numa_faults_buffer holds the
> fault activity during the current scan window. When the scan completes,
> numa_faults decays and the values from numa_faults_buffer are copied
> across.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
