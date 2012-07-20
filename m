Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 5BB156B0044
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 17:22:15 -0400 (EDT)
Date: Fri, 20 Jul 2012 14:22:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: +
 memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch added to
 -mm tree
Message-Id: <20120720142213.f4a4a68e.akpm@linux-foundation.org>
In-Reply-To: <20120719235057.GA21012@bbox>
References: <20120717233115.A8E411E005C@wpzn4.hot.corp.google.com>
	<20120718012200.GA27770@bbox>
	<20120718143810.b15564b3.akpm@linux-foundation.org>
	<20120719001002.GA6579@bbox>
	<20120719002102.GN24336@google.com>
	<20120719004845.GA7346@bbox>
	<20120719165750.GP24336@google.com>
	<20120719235057.GA21012@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Ralf Baechle <ralf@linux-mips.org>, aaditya.kumar.30@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Yinghai Lu <yinghai@kernel.org>

On Fri, 20 Jul 2012 08:50:57 +0900
Minchan Kim <minchan@kernel.org> wrote:

> > 
> > But, really, given how the structure is used, I think we're better off
> > just making sure all archs clear them and maybe have a sanity check or
> > two just in case.  It's not like breakage on that front is gonna be
> > subtle.
> 
> Of course, it seems all archs seems to zero-out already as I mentioned
> (Not sure, MIPS) but Andrew doesn't want it. Andrew?

My point is that having to ensure that each arch zeroes out this
structure is difficult/costly/unreliable/fragile.  It would be better
if we can reliably clear it at some well-known place in core MM.

That might mean that the memory gets cleared twice on some
architectures, but I doubt if that matters - it's a once-off thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
