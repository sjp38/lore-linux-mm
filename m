Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3872D6B01AC
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 19:26:32 -0400 (EDT)
Date: Wed, 30 Jun 2010 16:26:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: vmap area cache
Message-Id: <20100630162602.874ebd2a.akpm@linux-foundation.org>
In-Reply-To: <20100626083122.GE29809@laptop>
References: <20100531080757.GE9453@laptop>
	<20100602144905.aa613dec.akpm@linux-foundation.org>
	<20100603135533.GO6822@laptop>
	<1277470817.3158.386.camel@localhost.localdomain>
	<20100626083122.GE29809@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 26 Jun 2010 18:31:22 +1000
Nick Piggin <npiggin@suse.de> wrote:

> On Fri, Jun 25, 2010 at 02:00:17PM +0100, Steven Whitehouse wrote:
> > Hi,
> > 
> > Barry Marson has now tested your patch and it seems to work just fine.
> > Sorry for the delay,
> > 
> > Steve.
> 
> Hi Steve,
> 
> Thanks for that, do you mean that it has solved thee regression?

Nick, can we please have an updated changelog for this patch?  I didn't
even know it fixed a regression (what regression?).  Barry's tested-by:
would be nice too, along with any quantitative results from that.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
