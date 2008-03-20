Date: Thu, 20 Mar 2008 11:31:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 8/9] slub: Make the order configurable for each slab
 cache
In-Reply-To: <1205992409.14496.48.camel@ymzhang>
Message-ID: <Pine.LNX.4.64.0803201130230.10474@schroedinger.engr.sgi.com>
References: <20080317230516.078358225@sgi.com>  <20080317230529.701336582@sgi.com>
 <1205992409.14496.48.camel@ymzhang>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Mar 2008, Zhang, Yanmin wrote:

> It could be resolved by fetch s->order in allocate_slab firstly and calculate
> page->objects lately instead of fetching s->objects.

Hmmm..... Indeed a race there. But I want to avoid divisions in that code 
path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
