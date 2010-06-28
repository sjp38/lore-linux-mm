Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BB19B6B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 04:45:10 -0400 (EDT)
Date: Mon, 28 Jun 2010 18:45:04 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: vmap area cache
Message-ID: <20100628084504.GC28364@laptop>
References: <20100531080757.GE9453@laptop>
 <20100602144905.aa613dec.akpm@linux-foundation.org>
 <20100603135533.GO6822@laptop>
 <1277470817.3158.386.camel@localhost.localdomain>
 <20100626083122.GE29809@laptop>
 <1277714262.2461.2.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1277714262.2461.2.camel@localhost>
Sender: owner-linux-mm@kvack.org
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 28, 2010 at 09:37:42AM +0100, Steven Whitehouse wrote:
> Hi,
> 
> On Sat, 2010-06-26 at 18:31 +1000, Nick Piggin wrote:
> > On Fri, Jun 25, 2010 at 02:00:17PM +0100, Steven Whitehouse wrote:
> > > Hi,
> > > 
> > > Barry Marson has now tested your patch and it seems to work just fine.
> > > Sorry for the delay,
> > > 
> > > Steve.
> > 
> > Hi Steve,
> > 
> > Thanks for that, do you mean that it has solved thee regression?
> > 
> > Thanks,
> > Nick
> > 
> 
> Yes, thats what I have heard from Barry. He said that it was pretty
> close to the expected performance but did not give any figures. The fact
> that his test actually completes shows that most of the problem has been
> solved,

Thanks, so I think it's good to go.

It is interesting that it is just "close" to expected performance.
The lazy vunmap patch is preventing a global IPI and TLB flush on
all CPUs for every vfree() (amortizing it down to basically nothing
if you are doing just small vmaps).

Unless you are testing on a UP machine, I would have expected
improved performance if you are doing a lot of vmalloc/vfree activity.
It could be that the search is still taking some time, and is
outweighing the gains.

We have a few options for being cleverer, so if you're ever interested
to get more detailed results and find a bit more performance here,
let me know.

And thanks for all the reporting and testing so far.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
