Subject: Re: [patch] not to disturb page LRU state when unmapping memory
	range
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070131140450.09f174e9.akpm@osdl.org>
References: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>
	 <Pine.LNX.4.64.0701311746230.6135@blonde.wat.veritas.com>
	 <1170279811.10924.32.camel@lappy>  <20070131140450.09f174e9.akpm@osdl.org>
Content-Type: text/plain
Date: Wed, 31 Jan 2007 23:25:00 +0100
Message-Id: <1170282300.10924.50.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-01-31 at 14:04 -0800, Andrew Morton wrote:

> > Andrew, any strong opinions?
> 
> Not really.  If we change something in there, some workloads will get
> better, some will get worse and most will be unaffected and any regressions
> we cause won't be known until six months later.  The usual deal.
> 
> Remember that all this info is supposed to be estimating what is likely to
> happen to this page in the future - we're not interested in what happened
> in the past, per-se.
> 
> I'd have thought that if multiple processes are touching the same
> page, this is a reason to think that the page will be required again in the
> immediate future.  But you seem to think otherwise?

Yes, why would unmapping a range make the pages more likely to be used
in the immediate future than otherwise indicated by their individual
young bits?

Even the opposite was suggested, that unmapping a range makes it less
likely to be used again.

> > If only I could come up with a proper set of tests that covers all
> > this...
> 
> Well yes, that's rather a sore point.  It's tough.  I wonder what $OTHER_OS
> developers have done.  Probably their tests are priority ordered by
> $market_share of their user's applications :(

Still requires them to set up and run said programs. If we could get a
suite of programs that we consider interesting....

Just hoping, I seem to be stuck with quite a lot of code without means
of evaluation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
