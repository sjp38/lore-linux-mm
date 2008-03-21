Subject: Re: [patch 5/9] slub: Fallback to minimal order during slab page
	allocation
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <Pine.LNX.4.64.0803201128001.10474@schroedinger.engr.sgi.com>
References: <20080317230516.078358225@sgi.com>
	 <20080317230528.939792410@sgi.com> <1205989839.14496.32.camel@ymzhang>
	 <Pine.LNX.4.64.0803201128001.10474@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=utf-8
Date: Fri, 21 Mar 2008 08:52:18 +0800
Message-Id: <1206060738.14496.66.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-03-20 at 11:29 -0700, Christoph Lameter wrote:
> On Thu, 20 Mar 2008, Zhang, Yanmin wrote:
> 
> > page->objects = (PAGE_SIZE << get_order(s->size)) / s->size;
> > 
> > 
> > It'll look more readable and be simplified.
> 
> The earlier version of the fallback had that.
> 
> However, its a division in a potentially hot codepath.
No as long as there is no allocation failure because of fragmentation.

> And some architectures have slow division logic.
That's ok. I just want it to be more readable for others.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
