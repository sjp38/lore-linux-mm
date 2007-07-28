Date: Sat, 28 Jul 2007 12:21:39 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
Message-ID: <20070728122139.3c7f4290@the-village.bc.nu>
In-Reply-To: <46AB166A.2000300@gmail.com>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	<20070727030040.0ea97ff7.akpm@linux-foundation.org>
	<1185531918.8799.17.camel@Homer.simpson.net>
	<200707271345.55187.dhazelton@enter.net>
	<46AA3680.4010508@gmail.com>
	<Pine.LNX.4.64.0707271239300.26221@asgard.lang.hm>
	<46AAEDEB.7040003@gmail.com>
	<Pine.LNX.4.64.0707280138370.32476@asgard.lang.hm>
	<46AB166A.2000300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: david@lang.hm, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> It is. Prefetched pages can be dropped on the floor without additional I/O.

Which is essentially free for most cases. In addition your disk access
may well have been in idle time (and should be for this sort of stuff)
and if it was in the same chunk as something nearby was effectively free
anyway. 

Actual physical disk ops are precious resource and anything that mostly
reduces the number will be a win - not to stay swap prefetch is the right
answer but accidentally or otherwise there are good reasons it may happen
to help.

Bigger more linear chunks of writeout/readin is much more important I
suspect than swap prefetching. 

> good overview of exactly how broken -mm can be at times. How many -mm users 
> use it anyway? He himself said he's not convinced of usefulness having not 

I've been using it for months with no noticed problem. I turn it on
because it might as well get tested. I've not done comparison tests so I
can't comment on if its worth it.

Lots of -mm testers turn *everything* on because its a test kernel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
