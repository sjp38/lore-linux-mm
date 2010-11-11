Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B89616B009B
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 00:21:24 -0500 (EST)
Date: Thu, 11 Nov 2010 16:21:18 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
Message-ID: <20101111052118.GA6484@amd>
References: <20101109123246.GA11477@amd>
 <20101110051813.GS2715@dastard>
 <20101110063229.GA5700@amd>
 <20101110110549.GV2715@dastard>
 <20101111002339.GA3372@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101111002339.GA3372@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2010 at 11:23:39AM +1100, Nick Piggin wrote:
> On Wed, Nov 10, 2010 at 10:05:49PM +1100, Dave Chinner wrote:
> > I've previously stated that reducing/controlling the level of
> > parallelism can be just as effective at providing serious
> > scalability improvements as fine grained locking. So you don't
> > simply scoff and mock me for suggesting it like you did last time,
> 
> I didn't mock you. On the contrary I agreed that there are 2 problems
> here, and that lots of threads in reclaim is one of them. I know this

Here, this is the second time I wrote _exactly_ the same reply to your
_exact_ same question (the first time I wrote _exactly_ the same reply
to your exact same question was IIRC a few months before but I couldn't
find the archive.

http://archives.free.net.ph/message/20101015.033017.65c46426.ca.html

So at this point, shut up. You had ample time to put up, and didn't.
Now you're just obstructing and being unreasonable. To quote Christoph,
you don't have carte blance power to delay progress. So stop being an
arsehole, and don't fucking accuse me of scoffing and mocking you.

Because I've been bending over backwards to answer _exactly_ the same
questions multiple times from you and trying to show how either your
assumptions are wrong, or reasonable ways we can mitigate potential
regressions, and trying to be polite and civil the whole time. (which I
might add is much more courtesy than you showed me when you tried to
railroad your inode changes through without bothering to answer or even
read half my comments about them). And what you have done is just ignore
totally my replies to your concerns, stay quiet about them for a month,
and then come back with exactly the same thing again. Like 3 or 4 times.

Really. At this point, if you have already posted a particular comment
more than 50 times, do everybody a favour and redirect the next verbatim
copy /dev/null, OK? I'm sick of it. *Constructive* criticism only, from
now on. Thanks.

I need a zone input to the shinker API, I have demonstrated what for
and why, with good justification, and so I am going to get that API
change merged. It is a simple superset of the current API's
functionality and not some big scary monster (except by somebody who
fundmantally doesn't understand it). 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
