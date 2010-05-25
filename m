Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 713956008F9
	for <linux-mm@kvack.org>; Tue, 25 May 2010 07:07:06 -0400 (EDT)
Date: Tue, 25 May 2010 21:06:58 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100525110658.GL5087@laptop>
References: <20100525020629.GA5087@laptop>
 <AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com>
 <20100525070734.GC5087@laptop>
 <AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
 <20100525081634.GE5087@laptop>
 <AANLkTilJBY0sinB365lIZFUaMgMCZ1xyhMdXRTJTVDSV@mail.gmail.com>
 <20100525093410.GH5087@laptop>
 <AANLkTikXp5LlKLK1deKOQpciUFNugjlQah5QpNcImf39@mail.gmail.com>
 <20100525101924.GJ5087@laptop>
 <AANLkTimazVL8G-XQURiQ1s0M3NKa2ndXNceSaw9sADRQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTimazVL8G-XQURiQ1s0M3NKa2ndXNceSaw9sADRQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 01:45:07PM +0300, Pekka Enberg wrote:
> Hi Nick,
> 
> On Tue, May 25, 2010 at 1:19 PM, Nick Piggin <npiggin@suse.de> wrote:
> >> Like I said, as a maintainer I'm happy to merge patches to modernize
> >> SLAB
> >
> > I think that would be most productive at this point. I will volunteer
> > to do it.
> 
> OK, great!
> 
> > As much as I would like to see SLQB be merged :) I think the best
> > option is to go with SLAB because it is very well tested and very
> > very well performing.
> 
> I would have liked to see SLQB merged as well but it just didn't happen.

It seemed a bit counter productive if the goal is to have one allocator.
I think it still has merit but I should really practice what I preach
and propose incremental improvements to SLAB.

 
> > If Christoph or you or I or anyone have genuine improvements to make
> > to the core algorithms, then the best thing to do will just be do
> > make incremental changes to SLAB.
> 
> I don't see the problem in improving SLUB even if we start modernizing
> SLAB. Do you? I'm obviously biased towards SLUB still for the reasons
> I already mentioned. I don't want to be a blocker for progress so if I
> turn out to be a problem, we should consider changing the
> maintainer(s). ;-)

I think it just has not proven itself at this point, we have most
production kernels (at least, the performance sensitive ones that
I'm aware of) running on SLAB, and if it is conceded that lack of
queueing and reliance on higher order allocations is a problem then
I think it is far better just to bite the bullet now, drop it so
we can have a single allocator. Rather than adding SLAB-like queueing
to it and other big changes. Then make incremental improvements to SLAB.

I have no problems at all with trying new ideas, but really, they
should be done in SLAB as incremental improvements. Everywhere we
take that approach, things seem to work better than when we do
wholesale rip and replacements.

I don't want Christoph (or myself, or you) to stop testing new ideas,
but really there are almost no good reasons as to why they can be done
as incremental patches.

With SLAB code cleaned up, there will be even fewer reasons.


> > There are several aspects to this. I think the first one will be to
> > actually modernize the code style, simplify the bootstrap process and
> > static memory allocations (SLQB goes even further than SLUB in this
> > regard), and to pull in debug features from SLUB.
> >
> > These steps should be made without any changes to core algorithms.
> > Alien caches can easily be disabled and at present they are really
> > only a problem for big Altixes where it is a known parameter to tune.
> >
> > From that point, I think we should concede that SLUB has not fulfilled
> > performance promises, and make SLAB the default.
> 
> Sure. I don't care which allocator "wins" if we actually are able to get there.

SLUB is already behind the 8 ball here. So is SLQB I don't mind saying
because it has had much much less testing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
