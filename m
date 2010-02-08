Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 32BF06B0047
	for <linux-mm@kvack.org>; Mon,  8 Feb 2010 14:20:56 -0500 (EST)
Date: Mon, 8 Feb 2010 11:18:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15214] New: Oops at __rmqueue+0x51/0x2b3
Message-Id: <20100208111852.a0ada2b4.akpm@linux-foundation.org>
In-Reply-To: <20100208101045.GA23680@csn.ul.ie>
References: <bug-15214-10286@http.bugzilla.kernel.org/>
	<20100203143921.f2c96e8c.akpm@linux-foundation.org>
	<20100205112000.GD20412@csn.ul.ie>
	<201002071335.03984.ajlill@ajlc.waterloo.on.ca>
	<20100208101045.GA23680@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Tony Lill <ajlill@ajlc.waterloo.on.ca>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Feb 2010 10:10:46 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> On Sun, Feb 07, 2010 at 01:34:58PM -0500, Tony Lill wrote:
> > On Friday 05 February 2010 06:20:00 Mel Gorman wrote:
> > > On Wed, Feb 03, 2010 at 02:39:21PM -0800, Andrew Morton wrote:
> > > > > gcc (GCC) 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)
> > > 
> > > This is a bit of a reach, but how confident are you that this version of
> > > gcc is building kernels correctly?
> > >
> > > There are a few disconnected reports of kernel problems with this
> > > particular version of gcc although none that I can connect with this
> > > problem or on x86 for that matter. One example is
> > > 
> > > http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=536354
> > > 
> > > which reported problems building kernels on the s390 with that compiler.
> > > Moving to 4.2 helped them and it *should* have been fixed according to
> > > this bug
> > > 
> > > http://bugzilla.kernel.org/show_bug.cgi?id=13012
> > > 
> > > It might be a red herring, but just to be sure, would you mind trying
> > > gcc 4.2 or 4.3 just to be sure please?
> > 
> > Well, it was producing working kernels up until 2.6.30, but I recompiled with
> > gcc (Debian 4.3.2-1.1) 4.3.2
> > and the box has been running nearly 48 hour without incident. My previous 
> > record was 2. So I guess we can put this down to a new compiler bug.
> > 
> 
> Well, it's great the problem source is known but pinning down compiler bugs
> is a bit of a pain. Andrew, I don't recall an easy-as-in-bisection-easy
> means of identifying which part of the compile unit went wrong and why so
> it can be marked with #error for known broken compilers. Is there one or is
> it a case of asking for two objdumps of __rmqueue and making a stab at it?

ugh.  This is pretty rare.

Probably the best strategy is to generate the two page_alloc.s files,
fish out the __rmqueue part and then try to compare them.  The key
part is to Cc Linus then thrash around stupidly for long enough for him
to take pity and find the bug for you.

> > I probably should have checked this before reporting a bug. Mea culpa
> 
> Not at all. Miscompiles like this are rare and usually caught a lot quicker
> than this. If you hadn't reported the problem with  two different machines,
> I would have blamed hardware and asked for a memtest. The only reason I
> spotted this might be a compiler was because the type of error you reported
> "couldn't happen".
> 
> Thanks for reporting and testing.

Yup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
