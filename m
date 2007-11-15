Date: Thu, 15 Nov 2007 11:30:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 06/17] SLUB: Slab defrag core
Message-Id: <20071115113048.16c33010.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0711141726160.22161@schroedinger.engr.sgi.com>
References: <20071114220906.206294426@sgi.com>
	<20071114221020.940981964@sgi.com>
	<20071115101324.3c00e47d.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0711141726160.22161@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Nov 2007 17:28:24 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 15 Nov 2007, KAMEZAWA Hiroyuki wrote:
> 
> > > 	from the partial list. So there could be a double effect.
> > > 
> > 
> > I think shrink_slab()? is called under memory shortage and "re-allocation and
> > move" may require to allocate new page. Then, kick() should use GFP_ATOMIC if
> > they want to do reallocation. Right ?
> 
> There is no reason for allocating a new page. We are talking about slab 
> allocations. The defrag stuff is run when there is a high degree of 
> fragmentation. So there are a lot of partially allocated pages around. The 
> allocation will grab a free object out of one of them.
> 
Hmm, how about alloc_scratch() ?

BTW, how about counting succesfull kick() in __count_vm_events() and
the number of successfully defragmented pages ? (as a debug ops.)

I can't see how many dentrycache/inode defragment reaps objects after
shrinker()s.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
