Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 33D006B006E
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:09:06 -0500 (EST)
Message-ID: <50A66513.3010900@redhat.com>
Date: Fri, 16 Nov 2012 11:08:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/43] mm: mempolicy: Use _PAGE_NUMA to migrate pages
References: <1353064973-26082-1-git-send-email-mgorman@suse.de> <1353064973-26082-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1353064973-26082-15-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/16/2012 06:22 AM, Mel Gorman wrote:
> Note: Based on "mm/mpol: Use special PROT_NONE to migrate pages" but
> 	sufficiently different that the signed-off-bys were dropped
>
> Combine our previous _PAGE_NUMA, mpol_misplaced and migrate_misplaced_page()
> pieces into an effective migrate on fault scheme.
>
> Note that (on x86) we rely on PROT_NONE pages being !present and avoid
> the TLB flush from try_to_unmap(TTU_MIGRATION). This greatly improves the
> page-migration performance.
>
> Based-on-work-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

(this is getting easier, I must have reviewed this code 4x now)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
