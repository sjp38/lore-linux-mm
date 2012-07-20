Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 6296D6B0044
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 17:36:46 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8424043pbb.14
        for <linux-mm@kvack.org>; Fri, 20 Jul 2012 14:36:45 -0700 (PDT)
Date: Fri, 20 Jul 2012 14:36:41 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: +
 memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch added to
 -mm tree
Message-ID: <20120720213641.GA6823@google.com>
References: <20120717233115.A8E411E005C@wpzn4.hot.corp.google.com>
 <20120718012200.GA27770@bbox>
 <20120718143810.b15564b3.akpm@linux-foundation.org>
 <20120719001002.GA6579@bbox>
 <20120719002102.GN24336@google.com>
 <20120719004845.GA7346@bbox>
 <20120719165750.GP24336@google.com>
 <20120719235057.GA21012@bbox>
 <20120720142213.f4a4a68e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120720142213.f4a4a68e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Ralf Baechle <ralf@linux-mips.org>, aaditya.kumar.30@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Yinghai Lu <yinghai@kernel.org>

Hello, Andrew.

On Fri, Jul 20, 2012 at 02:22:13PM -0700, Andrew Morton wrote:
> My point is that having to ensure that each arch zeroes out this
> structure is difficult/costly/unreliable/fragile.  It would be better
> if we can reliably clear it at some well-known place in core MM.
> 
> That might mean that the memory gets cleared twice on some
> architectures, but I doubt if that matters - it's a once-off thing.

Clearing twice isn't the problem here.  The problem is the risk of
zapping fields which are already in use.  That would be way more
unexpected and difficult to track down than garbage value in whatever
field.

It might not be ideal but I think nudging all archs to clear all
static global structures they allocate is the better way here.  It's
at least better than having to worry about this type of partial
re-initialization.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
