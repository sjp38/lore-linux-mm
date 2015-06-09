Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6EDE06B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 16:01:57 -0400 (EDT)
Received: by yken206 with SMTP id n206so13118363yke.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 13:01:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f61si3093617yhc.190.2015.06.09.13.01.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 13:01:56 -0700 (PDT)
Message-ID: <5577462A.40402@redhat.com>
Date: Tue, 09 Jun 2015 16:01:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: Send one IPI per CPU to TLB flush all entries
 after unmapping pages
References: <1433871118-15207-1-git-send-email-mgorman@suse.de> <1433871118-15207-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1433871118-15207-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2015 01:31 PM, Mel Gorman wrote:
> An IPI is sent to flush remote TLBs when a page is unmapped that was
> potentially accesssed by other CPUs. There are many circumstances where
> this happens but the obvious one is kswapd reclaiming pages belonging to
> a running process as kswapd and the task are likely running on separate CPUs.

> It's still a noticeable improvement with vmstat showing interrupts went
> from roughly 500K per second to 45K per second.
> 
> The patch will have no impact on workloads with no memory pressure or
> have relatively few mapped pages. It will have an unpredictable impact
> on the workload running on the CPU being flushed as it'll depend on how
> many TLB entries need to be refilled and how long that takes. Worst case,
> the TLB will be completely cleared of active entries when the target PFNs
> were not resident at all.
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
