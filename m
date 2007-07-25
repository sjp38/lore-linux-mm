Message-ID: <46A72EC9.4030706@yahoo.com.au>
Date: Wed, 25 Jul 2007 21:06:49 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
References: <46A57068.3070701@yahoo.com.au>	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>	 <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>	 <46A6DFFD.9030202@gmail.com>	 <30701.1185347660@turing-police.cc.vt.edu> <46A7074B.50608@gmail.com>	 <20070725082822.GA13098@elte.hu> <46A70D37.3060005@gmail.com> <5c77e14b0707250353r48458316x5e6adde6dbce1fbd@mail.gmail.com>
In-Reply-To: <5c77e14b0707250353r48458316x5e6adde6dbce1fbd@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jos Poortvliet <jos@mijnkamer.nl>
Cc: Rene Herman <rene.herman@gmail.com>, Ingo Molnar <mingo@elte.hu>, david@lang.hm, Valdis.Kletnieks@vt.edu, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Jos Poortvliet wrote:

> Nick
> has been talking about 'fixing the updatedb thing' for years now, no patch
> yet.

Wrong Nick, I think.

First I heard about the updatedb problem was a few months ago with people
saying updatedb was causing their system to swap (that is, swap prefetching
helped after updatedb). I haven't been able to even try to fix it because I
can't reproduce it (I'm sitting on a machine with 256MB RAM), and nobody
has wanted to help me.


> Besides, he won't fix OO.o nor all other userspace stuff - so 
> actually,
> he does NOT even promise an alternative. Not that I think fixing updatedb
> would be cool, btw - it sure would, but it's no reason not to include swap
> prefetch - it's mostly unrelated.
> 
> I think everyone with >1 gb ram should stop saying 'I don't need it' 
> because
> that's obvious for that hardware. Just like ppl having a dual- or quadcore
> shouldn't even talk about scheduler interactivity stuff...

Actually there are people with >1GB of ram who are saying it helps. Why do
you want to shut people out of the discussion?


> Desktop users want it, tests show it works, there is no alternative and the
> maybe-promised-one won't even fix all cornercases. It's small, mostly
> selfcontained. There is a maintainer. It's been stable for a long time. 
> It's
> been in MM for a long time.
> 
> Yet it doesn't make it. Andrew says 'some ppl have objections' (he means
> Nick) and he doesn't see an advantage in it (at least 4 gig ram, right,
> Andrew?).
> 
> Do I miss things?

You could try constructively contributing?


> Apparently, it didn't get in yet - and I find it hard to believe Andrew
> holds swapprefetch for reasons like the above. So it must be something 
> else.
> 
> 
> Nick is saying tests have already proven swap prefetch to be helpfull,
> that's not the problem. He calls the requirements to get in 'fuzzy'. OK.

The test I have seen is the one that forces a huge amount of memory to
swap out, waits, then touches it. That speeds up, and that's fine. That's
a good sanity test to ensure it is working. Beyond that there are other
considerations to getting something merged.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
