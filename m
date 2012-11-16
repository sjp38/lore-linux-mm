Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 9B6D16B004D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 09:41:14 -0500 (EST)
Date: Fri, 16 Nov 2012 14:41:09 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 06/43] mm: numa: Make pte_numa() and pmd_numa() a generic
 implementation
Message-ID: <20121116144109.GA8218@suse.de>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
 <1353064973-26082-7-git-send-email-mgorman@suse.de>
 <50A648FF.2040707@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50A648FF.2040707@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 16, 2012 at 09:09:03AM -0500, Rik van Riel wrote:
> On 11/16/2012 06:22 AM, Mel Gorman wrote:
> >It was pointed out by Ingo Molnar that the per-architecture definition of
> >the NUMA PTE helper functions means that each supporting architecture
> >will have to cut and paste it which is unfortunate. He suggested instead
> >that the helpers should be weak functions that can be overridden by the
> >architecture.
> >
> >This patch moves the helpers to mm/pgtable-generic.c and makes them weak
> >functions. Architectures wishing to use this will still be required to
> >define _PAGE_NUMA and potentially update their p[te|md]_present and
> >pmd_bad helpers if they choose to make PAGE_NUMA similar to PROT_NONE.
> >
> >Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Is uninlining these simple tests really the right thing to do,
> or would they be better off as inlines in asm-generic/pgtable.h ?
> 

I would have preferred asm-generic/pgtable.h myself and use
__HAVE_ARCH_whatever tricks to keep the inlining but Ingo's suggestion
was to use __weak (https://lkml.org/lkml/2012/11/13/134) and I did not
have a strong reason to disagree. Is there a compelling choice either
way or a preference?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
