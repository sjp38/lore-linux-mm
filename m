Message-ID: <464B2745.8080204@yahoo.com.au>
Date: Thu, 17 May 2007 01:46:13 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
References: <20070514182456.GA9006@skynet.ie> <1179218576.25205.1.camel@rousalka.dyndns.org> <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie> <464AC00E.10704@yahoo.com.au> <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie> <464ACA68.2040707@yahoo.com.au> <Pine.LNX.4.64.0705161011400.7139@skynet.skynet.ie> <464AF8DB.9030000@yahoo.com.au> <20070516135039.GA7467@skynet.ie> <464B0F81.2090103@yahoo.com.au> <20070516153215.GB10225@skynet.ie>
In-Reply-To: <20070516153215.GB10225@skynet.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Nicolas Mailhot <nicolas.mailhot@laposte.net>, Christoph Lameter <clameter@sgi.com>, Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

> Ultimately, the allocations are done kmalloc() but with jumbo frames, the
> kmalloc() is for 32K. As it happens, this means that if jumbo frames are in
> use, then that kmalloc slab is opened and the minimum kswapd order is raised
> so that min_free_kbytes is kept contiguous for those atomic allocations.

Oh, and I didn't realise Christoph's patch raised the max order if a higher
order kmalloc slab is used. Still, that complaint was basically the least
of my troubles...

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
