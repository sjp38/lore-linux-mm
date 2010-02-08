Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2B63E6B0047
	for <linux-mm@kvack.org>; Mon,  8 Feb 2010 05:11:02 -0500 (EST)
Date: Mon, 8 Feb 2010 10:10:46 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 15214] New: Oops at __rmqueue+0x51/0x2b3
Message-ID: <20100208101045.GA23680@csn.ul.ie>
References: <bug-15214-10286@http.bugzilla.kernel.org/> <20100203143921.f2c96e8c.akpm@linux-foundation.org> <20100205112000.GD20412@csn.ul.ie> <201002071335.03984.ajlill@ajlc.waterloo.on.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201002071335.03984.ajlill@ajlc.waterloo.on.ca>
Sender: owner-linux-mm@kvack.org
To: Tony Lill <ajlill@ajlc.waterloo.on.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Sun, Feb 07, 2010 at 01:34:58PM -0500, Tony Lill wrote:
> On Friday 05 February 2010 06:20:00 Mel Gorman wrote:
> > On Wed, Feb 03, 2010 at 02:39:21PM -0800, Andrew Morton wrote:
> > > > gcc (GCC) 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)
> > 
> > This is a bit of a reach, but how confident are you that this version of
> > gcc is building kernels correctly?
> >
> > There are a few disconnected reports of kernel problems with this
> > particular version of gcc although none that I can connect with this
> > problem or on x86 for that matter. One example is
> > 
> > http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=536354
> > 
> > which reported problems building kernels on the s390 with that compiler.
> > Moving to 4.2 helped them and it *should* have been fixed according to
> > this bug
> > 
> > http://bugzilla.kernel.org/show_bug.cgi?id=13012
> > 
> > It might be a red herring, but just to be sure, would you mind trying
> > gcc 4.2 or 4.3 just to be sure please?
> 
> Well, it was producing working kernels up until 2.6.30, but I recompiled with
> gcc (Debian 4.3.2-1.1) 4.3.2
> and the box has been running nearly 48 hour without incident. My previous 
> record was 2. So I guess we can put this down to a new compiler bug.
> 

Well, it's great the problem source is known but pinning down compiler bugs
is a bit of a pain. Andrew, I don't recall an easy-as-in-bisection-easy
means of identifying which part of the compile unit went wrong and why so
it can be marked with #error for known broken compilers. Is there one or is
it a case of asking for two objdumps of __rmqueue and making a stab at it?

> I probably should have checked this before reporting a bug. Mea culpa

Not at all. Miscompiles like this are rare and usually caught a lot quicker
than this. If you hadn't reported the problem with  two different machines,
I would have blamed hardware and asked for a memtest. The only reason I
spotted this might be a compiler was because the type of error you reported
"couldn't happen".

Thanks for reporting and testing.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
