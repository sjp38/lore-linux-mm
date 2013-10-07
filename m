Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 540BF6B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 13:44:37 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so7389874pbc.30
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 10:44:36 -0700 (PDT)
Message-ID: <5252F2FA.1020201@redhat.com>
Date: Mon, 07 Oct 2013 13:44:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 17/63] sched: Set the scan rate proportional to the memory
 usage of the task being scanned
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-18-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> The NUMA PTE scan rate is controlled with a combination of the
> numa_balancing_scan_period_min, numa_balancing_scan_period_max and
> numa_balancing_scan_size. This scan rate is independent of the size
> of the task and as an aside it is further complicated by the fact that
> numa_balancing_scan_size controls how many pages are marked pte_numa and
> not how much virtual memory is scanned.
> 
> In combination, it is almost impossible to meaningfully tune the min and
> max scan periods and reasoning about performance is complex when the time
> to complete a full scan is is partially a function of the tasks memory
> size. This patch alters the semantic of the min and max tunables to be
> about tuning the length time it takes to complete a scan of a tasks occupied
> virtual address space. Conceptually this is a lot easier to understand. There
> is a "sanity" check to ensure the scan rate is never extremely fast based on
> the amount of virtual memory that should be scanned in a second. The default
> of 2.5G seems arbitrary but it is to have the maximum scan rate after the
> patch roughly match the maximum scan rate before the patch was applied.
> 
> On a similar note, numa_scan_period is in milliseconds and not
> jiffies. Properly placed pages slow the scanning rate but adding 10 jiffies
> to numa_scan_period means that the rate scanning slows depends on HZ which
> is confusing. Get rid of the jiffies_to_msec conversion and treat it as ms.
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
