Date: Wed, 14 Nov 2007 17:28:24 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 06/17] SLUB: Slab defrag core
In-Reply-To: <20071115101324.3c00e47d.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0711141726160.22161@schroedinger.engr.sgi.com>
References: <20071114220906.206294426@sgi.com> <20071114221020.940981964@sgi.com>
 <20071115101324.3c00e47d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Nov 2007, KAMEZAWA Hiroyuki wrote:

> > 	from the partial list. So there could be a double effect.
> > 
> 
> I think shrink_slab()? is called under memory shortage and "re-allocation and
> move" may require to allocate new page. Then, kick() should use GFP_ATOMIC if
> they want to do reallocation. Right ?

There is no reason for allocating a new page. We are talking about slab 
allocations. The defrag stuff is run when there is a high degree of 
fragmentation. So there are a lot of partially allocated pages around. The 
allocation will grab a free object out of one of them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
