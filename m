Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id E78416B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 15:05:10 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so7391565pbc.7
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 12:05:10 -0700 (PDT)
Message-ID: <525305D6.2020205@redhat.com>
Date: Mon, 07 Oct 2013 15:04:54 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 35/63] sched: numa: Do not trap hinting faults for shared
 libraries
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-36-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-36-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> NUMA hinting faults will not migrate a shared executable page mapped by
> multiple processes on the grounds that the data is probably in the CPU
> cache already and the page may just bounce between tasks running on multipl
> nodes. Even if the migration is avoided, there is still the overhead of
> trapping the fault, updating the statistics, making scheduler placement
> decisions based on the information etc. If we are never going to migrate
> the page, it is overhead for no gain and worse a process may be placed on
> a sub-optimal node for shared executable pages. This patch avoids trapping
> faults for shared libraries entirely.
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
