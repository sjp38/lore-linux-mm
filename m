Date: Thu, 20 Mar 2008 20:35:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 5/9] slub: Fallback to minimal order during slab page
 allocation
In-Reply-To: <1206060738.14496.66.camel@ymzhang>
Message-ID: <Pine.LNX.4.64.0803202034340.14239@schroedinger.engr.sgi.com>
References: <20080317230516.078358225@sgi.com>  <20080317230528.939792410@sgi.com>
 <1205989839.14496.32.camel@ymzhang>  <Pine.LNX.4.64.0803201128001.10474@schroedinger.engr.sgi.com>
 <1206060738.14496.66.camel@ymzhang>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Mar 2008, Zhang, Yanmin wrote:

> > However, its a division in a potentially hot codepath.
> No as long as there is no allocation failure because of fragmentation.

If its only used for the fallback path then the race condition is still 
there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
