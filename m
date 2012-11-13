Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id B2F446B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:37:44 -0500 (EST)
Date: Tue, 13 Nov 2012 11:37:39 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 06/19] mm: numa: teach gup_fast about pmd_numa
Message-ID: <20121113113739.GX8218@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-7-git-send-email-mgorman@suse.de>
 <20121113100735.GC21522@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121113100735.GC21522@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 13, 2012 at 11:07:36AM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > When scanning pmds, the pmd may be of numa type (_PAGE_PRESENT not set),
> > however the pte might be present. Therefore, gup_pmd_range() must return
> > 0 in this case to avoid losing a NUMA hinting page fault during gup_fast.
> > 
> > Note: gup_fast will skip over non present ptes (like numa 
> > types), so no explicit check is needed for the pte_numa case. 
> > [...]
> 
> So, why not fix all architectures that choose to expose 
> pte_numa() and pmd_numa() methods - via the patch below?
> 

I'll pick it up. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
