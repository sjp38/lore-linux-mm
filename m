Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7637F6B01B7
	for <linux-mm@kvack.org>; Tue, 25 May 2010 04:03:52 -0400 (EDT)
Received: by fxm11 with SMTP id 11so2476975fxm.14
        for <linux-mm@kvack.org>; Tue, 25 May 2010 01:03:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100525070734.GC5087@laptop>
References: <20100521211452.659982351@quilx.com>
	<20100524070309.GU2516@laptop>
	<alpine.DEB.2.00.1005240852580.5045@router.home>
	<20100525020629.GA5087@laptop>
	<AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com>
	<20100525070734.GC5087@laptop>
Date: Tue, 25 May 2010 11:03:49 +0300
Message-ID: <AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Tue, May 25, 2010 at 10:07 AM, Nick Piggin <npiggin@suse.de> wrote:
> There is nothing to stop incremental changes or tweaks on top of that
> allocator, even to the point of completely changing the allocation
> scheme. It is inevitable that with changes in workloads, SMP/NUMA, and
> cache/memory costs and hierarchies, the best slab allocation schemes
> will change over time.

Agreed.

On Tue, May 25, 2010 at 10:07 AM, Nick Piggin <npiggin@suse.de> wrote:
> I think it is more important to have one allocator than trying to get
> the absolute most perfect one for everybody. That way changes are
> carefully and slowly reviewed and merged, with results to justify the
> change. This way everybody is testing the same thing, and bisection will
> work. The situation with SLUB is already a nightmare because now each
> allocator has half the testing and half the work put into it.

I wouldn't say it's a nightmare, but yes, it could be better. From my
point of view SLUB is the base of whatever the future will be because
the code is much cleaner and simpler than SLAB. That's why I find
Christoph's work on SLEB more interesting than SLQB, for example,
because it's building on top of something that's mature and stable.

That said, are you proposing that even without further improvements to
SLUB, we should go ahead and, for example, remove SLAB from Kconfig
for v2.6.36 and see if we can just delete the whole thing from, say,
v2.6.38?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
