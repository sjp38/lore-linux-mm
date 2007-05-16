Message-ID: <464B131F.6090904@yahoo.com.au>
Date: Thu, 17 May 2007 00:20:15 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
References: <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com> <20070514182456.GA9006@skynet.ie> <1179218576.25205.1.camel@rousalka.dyndns.org> <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie> <464AC00E.10704@yahoo.com.au> <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie> <464ACA68.2040707@yahoo.com.au> <Pine.LNX.4.64.0705161011400.7139@skynet.skynet.ie> <464AF8DB.9030000@yahoo.com.au> <20070516135039.GA7467@skynet.ie>
In-Reply-To: <20070516135039.GA7467@skynet.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Nicolas Mailhot <nicolas.mailhot@laposte.net>, Christoph Lameter <clameter@sgi.com>, Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

> ======
> 
> On third thought: The trouble with this solution is that we will now set
> the order to that used by the largest kmalloc cache. Bad... this could be
> 6 on i386 to 13 if CONFIG_LARGE_ALLOCs is set. The large kmalloc caches are
> rarely used and we are used to OOMing if those are utilized to frequently.
> 
> I guess we should only set this for non kmalloc caches then. 
> So move the call into kmem_cache_create? Would make the min order 3 on
> most of my mm machines.
> ===

Also, I might add that the e1000 page allocations failures usually come
from kmalloc, so doing this means they might just be protected by chance
if someone happens to create a kmem cache of order 3.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
