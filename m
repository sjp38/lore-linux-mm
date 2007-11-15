Date: Thu, 15 Nov 2007 10:16:27 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Page allocator: Get rid of the list of cold pages
In-Reply-To: <20071115104004.GC5128@skynet.ie>
Message-ID: <Pine.LNX.4.64.0711151010530.27140@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711122041320.30747@schroedinger.engr.sgi.com>
 <20071114184111.GE773@skynet.ie> <Pine.LNX.4.64.0711141045090.12606@schroedinger.engr.sgi.com>
 <20071115104004.GC5128@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Nov 2007, Mel Gorman wrote:

> It would improve readahead but if there are active processes looking
> for hot pages, they could be impacted because readahead has used up hot
> pages. Basically, it could go either way but justifying that splitting the
> lists is the right thing to do in all situations is difficult to justify
> too. I think you could justify either approach with about the same amount
> of hand-waving and not be able to prove anything conclusively.

Readahead is a rather slow process so its likely that the competing fast 
allocating process that is faulting in anonymous pages will replenish the 
pcp pages multiple times between accesses of readahead to the pcp pages.

I guess this is some handwaving. However, if there is no conclusive proof 
either way then lets remove it.

> You're welcome. The PPC64 results came through as well. The difference
> between the two kernels is negligible. There are very slight
> improvements with your patch but it's in the noise.
> 
> What I have seen so far is that things are no worse with your patch than
> without which is the important thing.

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
