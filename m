Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id ADE636B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 04:32:47 -0400 (EDT)
Subject: Re: [patch] mm: vmap area cache
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <20100626083122.GE29809@laptop>
References: <20100531080757.GE9453@laptop>
	 <20100602144905.aa613dec.akpm@linux-foundation.org>
	 <20100603135533.GO6822@laptop>
	 <1277470817.3158.386.camel@localhost.localdomain>
	 <20100626083122.GE29809@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Jun 2010 09:37:42 +0100
Message-ID: <1277714262.2461.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 2010-06-26 at 18:31 +1000, Nick Piggin wrote:
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
> 
> Thanks,
> Nick
> 

Yes, thats what I have heard from Barry. He said that it was pretty
close to the expected performance but did not give any figures. The fact
that his test actually completes shows that most of the problem has been
solved,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
