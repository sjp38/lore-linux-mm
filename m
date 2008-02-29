Date: Fri, 29 Feb 2008 13:07:30 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/6] Use two zonelist that are filtered by GFP mask
In-Reply-To: <1204300094.5311.50.camel@localhost>
Message-ID: <Pine.LNX.4.64.0802291305360.11889@schroedinger.engr.sgi.com>
References: <20080227214708.6858.53458.sendpatchset@localhost>
 <20080227214734.6858.9968.sendpatchset@localhost>
 <20080228133247.6a7b626f.akpm@linux-foundation.org>  <20080229145030.GD6045@csn.ul.ie>
 <1204300094.5311.50.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008, Lee Schermerhorn wrote:

> + usage in slab.c and slub.c appears to be the fallback/slow path.
> Christoph can chime in, here, if he disagrees.

Correct. And in 2.6.25 slub will start to buffer page allocator allocs in 
order to avoid that current issue with 4k allocs being slower than slab 
due to page allocator inefficiency.

I think we need a new fastpath for the page allocator! (No not me, I am 
already handing a gazillion patches).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
