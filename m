Date: Fri, 11 Nov 2005 09:43:22 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC, PATCH] Slab counter troubles with swap prefetch?
In-Reply-To: <200511111450.07396.kernel@kolivas.org>
Message-ID: <Pine.LNX.4.62.0511110941050.20360@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511101351120.16380@schroedinger.engr.sgi.com>
 <200511111007.12872.kernel@kolivas.org> <Pine.LNX.4.62.0511101510240.16588@schroedinger.engr.sgi.com>
 <200511111450.07396.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Fri, 11 Nov 2005, Con Kolivas wrote:

> One last thing. Swap prefetch works off the accounting of total memory and is 
> only a single kernel thread rather than a thread per cpu or per pgdat unlike 
> kswapd. Currently it just cares about total slab data and total ram. 
> Depending on where this thread is scheduled (which node) your accounting 
> change will alter the behaviour of it. Does this affect the relevance of this 
> patch to you?

Yes, if its a truly global value then we would not need the patch. 
But then the prefetch code would have to add up all the nr_slab field for 
all processors and use that result for comparison. If you do this in a 
node specific fashion then the problem comes up again.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
