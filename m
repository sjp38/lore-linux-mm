Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 6A2A56B0068
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 09:09:51 -0500 (EST)
Message-ID: <50A64921.5020702@redhat.com>
Date: Fri, 16 Nov 2012 09:09:37 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/43] mm: numa: Support NUMA hinting page faults from
 gup/gup_fast
References: <1353064973-26082-1-git-send-email-mgorman@suse.de> <1353064973-26082-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1353064973-26082-8-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/16/2012 06:22 AM, Mel Gorman wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
>
> Introduce FOLL_NUMA to tell follow_page to check
> pte/pmd_numa. get_user_pages must use FOLL_NUMA, and it's safe to do
> so because it always invokes handle_mm_fault and retries the
> follow_page later.
>
> KVM secondary MMU page faults will trigger the NUMA hinting page
> faults through gup_fast -> get_user_pages -> follow_page ->
> handle_mm_fault.
>
> Other follow_page callers like KSM should not use FOLL_NUMA, or they
> would fail to get the pages if they use follow_page instead of
> get_user_pages.
>
> [ This patch was picked up from the AutoNUMA tree. ]
>
> Originally-by: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> [ ported to this tree. ]
> Signed-off-by: Ingo Molnar <mingo@kernel.org>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
