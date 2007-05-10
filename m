Date: Thu, 10 May 2007 00:20:51 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
Message-ID: <20070510072051.GK19966@holomorphy.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705100928.34056.kernel@kolivas.org> <464261B5.6030809@yahoo.com.au> <200705101134.34350.kernel@kolivas.org> <46427BDB.30004@yahoo.com.au> <2c0942db0705092048m38b36e7fo3a7c2c59fe1612b2@mail.gmail.com> <46429801.8030202@yahoo.com.au> <2c0942db0705092252n13a6a79aq39f13fcfae534de2@mail.gmail.com> <4642C416.3000205@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4642C416.3000205@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ray Lee <ray-lk@madrabbit.org>, Con Kolivas <kernel@kolivas.org>, Ingo Molnar <mingo@elte.hu>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ray Lee wrote:
>> Huh? You already stated one version of it above, namely updatedb. But

On Thu, May 10, 2007 at 05:04:54PM +1000, Nick Piggin wrote:
> So a swapping problem with updatedb should be unusual and we'd like to see
> if we can fix it without resorting to prefetching.
> I know the theory behind swap prefetching, and I'm not saying it doesn't
> work, so I'll snip the rest of that.

I've not run updatedb in years, so I have no idea what it does to a
modern kernel. It used to be an unholy terror of slab fragmentation
and displacing user memory. The case of streaming kernel metadata IO
is probably not quite as easy as streaming file IO.


Ray Lee wrote:
>> You said, effectively: "Use-once could be improved to deal with
>> updatedb". I said I've been reading emails from Rik and others talking
>> about that for four years now, and we're still talking about it. Were
>> it merely updatedb, I'd say us userspace folk should step up and
>> rewrite the damn thing to amortize its work. However, I and others
>> feel it's only an example -- glaring, obviously -- of a more pervasive
>> issue. A small issue, to be sure!, but an issue nevertheless.

On Thu, May 10, 2007 at 05:04:54PM +1000, Nick Piggin wrote:
> It isn't going to get fixed unless people complain about it. If you
> cover the use-once problem with swap prefetching, then it will never
> get fixed.

The policy people need to clean this up once and for all at some point.
clameter's targeted reclaim bits for slub look like a plausible tactic,
but are by no means comprehensive. Things need to attempt to eat their
own tails before eating everyone else alive. Maybe we need to take hits
on things such as badari's dd's to resolve the pathologies.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
