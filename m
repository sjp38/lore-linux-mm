Message-ID: <464ACA68.2040707@yahoo.com.au>
Date: Wed, 16 May 2007 19:10:00 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>  <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>  <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>  <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>  <20070514182456.GA9006@skynet.ie> <1179218576.25205.1.camel@rousalka.dyndns.org> <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie> <464AC00E.10704@yahoo.com.au> <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nicolas Mailhot <nicolas.mailhot@laposte.net>, Christoph Lameter <clameter@sgi.com>, Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Wed, 16 May 2007, Nick Piggin wrote:

>> Hmm, so we require higher order pages be kept free even if nothing is
>> using them? That's not very nice :(
>>
> 
> Not quite. We are already required to keep a minimum number of pages 
> free even though nothing is using them. The difference is that if it is 
> known high-order allocations are frequently required, the freed pages 
> will be contiguous. If no one calls raise_kswapd_order(), kswapd will 
> continue reclaiming at order-0.

And after they are stopped being used, it falls back to order-0? Why
can't this use the infrastructure that is already in place for that?


> Arguably, e1000 should also be calling 
> raise_kswapd_order() when it is using jumbo frames.

It should be able to handle higher order page allocation failures
gracefully. kswapd will be notified of the attempts and go on and try
to free up some higher order pages for it for next time. What is wrong
with this process? Are the higher order watermarks insufficient?

(I would also add that non-arguably, e1000 should also be able to do
scatter gather with jumbo frames too.)

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
