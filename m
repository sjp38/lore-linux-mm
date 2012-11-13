Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id AEBED6B0075
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 08:51:13 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so3481888eaa.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 05:51:12 -0800 (PST)
Date: Tue, 13 Nov 2012 14:51:08 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 06/19] mm: numa: teach gup_fast about pmd_numa
Message-ID: <20121113135107.GC17782@gmail.com>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-7-git-send-email-mgorman@suse.de>
 <20121113100735.GC21522@gmail.com>
 <20121113113739.GX8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121113113739.GX8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Nov 13, 2012 at 11:07:36AM +0100, Ingo Molnar wrote:
> > 
> > * Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > 
> > > When scanning pmds, the pmd may be of numa type (_PAGE_PRESENT not set),
> > > however the pte might be present. Therefore, gup_pmd_range() must return
> > > 0 in this case to avoid losing a NUMA hinting page fault during gup_fast.
> > > 
> > > Note: gup_fast will skip over non present ptes (like numa 
> > > types), so no explicit check is needed for the pte_numa case. 
> > > [...]
> > 
> > So, why not fix all architectures that choose to expose 
> > pte_numa() and pmd_numa() methods - via the patch below?
> > 
> 
> I'll pick it up. Thanks.

FYI, before you do too much restructuring work, that patch is 
already part of tip:numa/core, I'll push out our updated version 
of the tree later today.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
