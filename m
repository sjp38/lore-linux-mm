Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C18A56B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 13:15:51 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8058368pbb.14
        for <linux-mm@kvack.org>; Fri, 20 Jul 2012 10:15:51 -0700 (PDT)
Date: Fri, 20 Jul 2012 10:15:46 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: +
 memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch added to
 -mm tree
Message-ID: <20120720171546.GG32763@google.com>
References: <20120717233115.A8E411E005C@wpzn4.hot.corp.google.com>
 <20120718012200.GA27770@bbox>
 <20120718143810.b15564b3.akpm@linux-foundation.org>
 <20120719001002.GA6579@bbox>
 <20120719002102.GN24336@google.com>
 <20120719004845.GA7346@bbox>
 <20120719165750.GP24336@google.com>
 <20120719235057.GA21012@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120719235057.GA21012@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ralf Baechle <ralf@linux-mips.org>, aaditya.kumar.30@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Yinghai Lu <yinghai@kernel.org>

Hello,

On Fri, Jul 20, 2012 at 08:50:57AM +0900, Minchan Kim wrote:
> > But, really, given how the structure is used, I think we're better off
> > just making sure all archs clear them and maybe have a sanity check or
> > two just in case.  It's not like breakage on that front is gonna be
> > subtle.
> 
> Of course, it seems all archs seems to zero-out already as I mentioned
> (Not sure, MIPS) but Andrew doesn't want it. Andrew?

So, to be more direct.  Either 1. remove the spurious initializations
(and hunt down archs which don't zero them if there's any) or 2. leave
it alone.  It's one of the data structures which are allocated and
used way before any generic code kicks in.  I mean, even how it's
deferenced is arch-dependent - it's wrapped in NODE_DATA macro for a
reason.

I would vote for #1 as it's simply brain-damaged to not zero any
global data structure and partial initialization of a data structure
already in use is silly and dangerous.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
