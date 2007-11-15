Date: Wed, 14 Nov 2007 19:59:27 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 06/17] SLUB: Slab defrag core
In-Reply-To: <20071115113048.16c33010.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0711141956220.22549@schroedinger.engr.sgi.com>
References: <20071114220906.206294426@sgi.com> <20071114221020.940981964@sgi.com>
 <20071115101324.3c00e47d.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0711141726160.22161@schroedinger.engr.sgi.com>
 <20071115113048.16c33010.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Nov 2007, KAMEZAWA Hiroyuki wrote:

> > There is no reason for allocating a new page. We are talking about slab 
> > allocations. The defrag stuff is run when there is a high degree of 
> > fragmentation. So there are a lot of partially allocated pages around. The 
> > allocation will grab a free object out of one of them.
> > 
> Hmm, how about alloc_scratch() ?

Hmmm.. We would need GFP_FAIL to simply fail on any attempt to get into 
the page allocator. __GFP_NOMEMALLOC could be sufficient.

> BTW, how about counting succesfull kick() in __count_vm_events() and
> the number of successfully defragmented pages ? (as a debug ops.)

Yes would be easy to add.

> I can't see how many dentrycache/inode defragment reaps objects after
> shrinker()s.

I typically do

	slabinfo -D

to observe the effect. I also have a debug patch here that we could add 
to see numbers in the syslog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
