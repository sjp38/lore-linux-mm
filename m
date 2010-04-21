Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4794E6B01EE
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 04:40:12 -0400 (EDT)
Date: Wed, 21 Apr 2010 18:40:04 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/2] mm: add context argument to shrinker callback
Message-ID: <20100421084004.GS5683@laptop>
References: <1271118255-21070-1-git-send-email-david@fromorbit.com>
 <1271118255-21070-2-git-send-email-david@fromorbit.com>
 <20100418001514.GA26575@infradead.org>
 <20100419140039.GQ5683@laptop>
 <20100420004149.GA14744@dastard>
 <20100420083840.GR5683@laptop>
 <20100420103216.GK15130@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100420103216.GK15130@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 08:32:16PM +1000, Dave Chinner wrote:
> On Tue, Apr 20, 2010 at 06:38:40PM +1000, Nick Piggin wrote:
> > On Tue, Apr 20, 2010 at 10:41:49AM +1000, Dave Chinner wrote:
> > > And if this is enough of a problem to disallow context based cache
> > > shrinkers, then lets fix the interface so that we encode the
> > > dependencies explicitly in the registration interface rather than
> > > doing it implicitly.
> > > 
> > > IOWs, I don't think this is a valid reason for not allowing a
> > > context to be passed with a shrinker because it is easily fixed.
> > 
> > Well yeah you could do all that maybe. I think it would definitely be
> > required if we were to do context shrinkers like this. But AFAIKS there
> > is simply no need at all. Definitely it is not preventing XFS from
> > following more like the existing shrinker implementations.
> 
> So you're basically saying that we shouldn't improve the shrinker
> interface because you don't think that anyone should be doing
> anything different to what is already there.

I'm saying that dynamic registration is no good, if we don't have a
way to order the shrinkers.

 
> If a change of interface means that we end up with shorter call
> chains, less global state, more flexibilty, better batching and IO
> patterns, less duplication of code and algorithms and it doesn't
> cause any regressions, then where's the problem?

Yep that would all be great but I don't see how the interface change
enables any of that at all. It seems to me that the advantage goes
the other way because it doesn't put as much crap into your mount
structure and you end up with an useful traversable list of mounts as
a side-effect.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
