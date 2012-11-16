Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 8A6596B005A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 09:09:23 -0500 (EST)
Message-ID: <50A648FF.2040707@redhat.com>
Date: Fri, 16 Nov 2012 09:09:03 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/43] mm: numa: Make pte_numa() and pmd_numa() a generic
 implementation
References: <1353064973-26082-1-git-send-email-mgorman@suse.de> <1353064973-26082-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1353064973-26082-7-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/16/2012 06:22 AM, Mel Gorman wrote:
> It was pointed out by Ingo Molnar that the per-architecture definition of
> the NUMA PTE helper functions means that each supporting architecture
> will have to cut and paste it which is unfortunate. He suggested instead
> that the helpers should be weak functions that can be overridden by the
> architecture.
>
> This patch moves the helpers to mm/pgtable-generic.c and makes them weak
> functions. Architectures wishing to use this will still be required to
> define _PAGE_NUMA and potentially update their p[te|md]_present and
> pmd_bad helpers if they choose to make PAGE_NUMA similar to PROT_NONE.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Is uninlining these simple tests really the right thing to do,
or would they be better off as inlines in asm-generic/pgtable.h ?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
