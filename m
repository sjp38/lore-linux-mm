Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 33B396B0036
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 15:20:18 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so7570763pbb.0
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 12:20:17 -0700 (PDT)
Message-ID: <52530013.2000300@redhat.com>
Date: Mon, 07 Oct 2013 14:40:19 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 23/63] sched: Resist moving tasks towards nodes with fewer
 hinting faults
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-24-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-24-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> Just as "sched: Favour moving tasks towards the preferred node" favours
> moving tasks towards nodes with a higher number of recorded NUMA hinting
> faults, this patch resists moving tasks towards nodes with lower faults.
> 
> [mgorman@suse.de: changelog]
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
