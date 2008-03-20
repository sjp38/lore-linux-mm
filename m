Date: Thu, 20 Mar 2008 11:29:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 5/9] slub: Fallback to minimal order during slab page
 allocation
In-Reply-To: <1205989839.14496.32.camel@ymzhang>
Message-ID: <Pine.LNX.4.64.0803201128001.10474@schroedinger.engr.sgi.com>
References: <20080317230516.078358225@sgi.com>  <20080317230528.939792410@sgi.com>
 <1205989839.14496.32.camel@ymzhang>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Mar 2008, Zhang, Yanmin wrote:

> page->objects = (PAGE_SIZE << get_order(s->size)) / s->size;
> 
> 
> It'll look more readable and be simplified.

The earlier version of the fallback had that.

However, its a division in a potentially hot codepath.
And some architectures have slow division logic.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
