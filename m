Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8C3336008F1
	for <linux-mm@kvack.org>; Tue, 25 May 2010 05:53:46 -0400 (EDT)
Received: by fxm11 with SMTP id 11so2590820fxm.14
        for <linux-mm@kvack.org>; Tue, 25 May 2010 02:53:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100525093410.GH5087@laptop>
References: <20100521211452.659982351@quilx.com>
	<20100524070309.GU2516@laptop>
	<alpine.DEB.2.00.1005240852580.5045@router.home>
	<20100525020629.GA5087@laptop>
	<AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com>
	<20100525070734.GC5087@laptop>
	<AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
	<20100525081634.GE5087@laptop>
	<AANLkTilJBY0sinB365lIZFUaMgMCZ1xyhMdXRTJTVDSV@mail.gmail.com>
	<20100525093410.GH5087@laptop>
Date: Tue, 25 May 2010 12:53:43 +0300
Message-ID: <AANLkTikXp5LlKLK1deKOQpciUFNugjlQah5QpNcImf39@mail.gmail.com>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Tue, May 25, 2010 at 12:34 PM, Nick Piggin <npiggin@suse.de> wrote:
>> The main selling point for SLUB was NUMA. Has the situation changed?
>
> Well one problem with SLAB was really just those alien caches. AFAIK
> they were added by Christoph Lameter (maybe wrong), and I didn't ever
> actually see much justification for them in the changelog. noaliencache
> can be and is used on bigger machines, and SLES and RHEL kernels are
> using SLAB on production NUMA systems up to thousands of CPU Altixes,
> and have been looking at working on SGI's UV, and hundreds of cores
> POWER7 etc.

Yes, Christoph and some other people introduced alien caches IIRC for
big iron SGI boxes. As for benchmarks, commit
e498be7dafd72fd68848c1eef1575aa7c5d658df ("Numa-aware slab allocator
V5") mentions AIM.

On Tue, May 25, 2010 at 12:34 PM, Nick Piggin <npiggin@suse.de> wrote:
> I have not seen NUMA benchmarks showing SLUB is significantly better.
> I haven't done much testing myself, mind you. But from indications, we
> could probably quite easily drop the alien caches setup and do like a
> simpler single remote freeing queue per CPU or something like that.

Commit 81819f0fc8285a2a5a921c019e3e3d7b6169d225 ("SLUB core") mentions
kernbench improvements.

Other than these two data points, I unfortunately don't have any as I
wasn't involved with merging of either of the patches. If other NUMA
people know better, please feel free to share the data.

On Tue, May 25, 2010 at 11:16 AM, Nick Piggin <npiggin@suse.de> wrote:
> I think we should: modernise SLAB code, add missing debug features,
> possibly turn off alien caches by default, chuck out SLUB, and then
> require that future changes have some reasonable bar set to justify
> them.
>
> I would not be at all against adding changes that transform SLAB to
> SLUB or SLEB or SLQB. That's how it really should be done in the
> first place.

Like I said, as a maintainer I'm happy to merge patches to modernize
SLAB but I still think you're underestimating the effort especially
considering the fact that we can't afford many performance regressions
there either. I guess trying to get rid of alien caches would be the
first logical step there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
