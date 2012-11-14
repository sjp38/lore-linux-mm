Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 32AFF6B0089
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:50:25 -0500 (EST)
Date: Wed, 14 Nov 2012 18:50:17 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 26/31] sched: numa: Make mempolicy home-node aware
Message-ID: <20121114185017.GQ8218@suse.de>
References: <1352805180-1607-1-git-send-email-mgorman@suse.de>
 <1352805180-1607-27-git-send-email-mgorman@suse.de>
 <50A3E169.4010402@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50A3E169.4010402@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 14, 2012 at 01:22:33PM -0500, Rik van Riel wrote:
> On 11/13/2012 06:12 AM, Mel Gorman wrote:
> >From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> >
> >Add another layer of fallback policy to make the home node concept
> >useful from a memory allocation PoV.
> >
> >This changes the mpol order to:
> >
> >  - vma->vm_ops->get_policy	[if applicable]
> >  - vma->vm_policy		[if applicable]
> >  - task->mempolicy
> >  - tsk_home_node() preferred	[NEW]
> >  - default_policy
> 
> Why is the home node policy not the default policy?
> 

hmm, it effectively is if there is no other policy set. The changelog is
a bit misleading. In V3, this will be dropped entirely. It was not clear
that doing a remote alloc for home nodes was a good idea. Instead memory
is always allocated locally to the faulting process as normal and
migrated later if necessary.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
