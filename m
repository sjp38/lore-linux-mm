Subject: Re: NUMA allocator on Opteron systems does non-local allocation on
	node0
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <2793369.1223977380170.SLOX.WebMail.wwwrun@exchange.deltacomputer.de>
References: <1449471.1223892929572.SLOX.WebMail.wwwrun@exchange.deltacomputer.de>
	 <2793369.1223977380170.SLOX.WebMail.wwwrun@exchange.deltacomputer.de>
Content-Type: text/plain
Date: Tue, 14 Oct 2008 07:41:53 -0400
Message-Id: <1223984513.29275.5.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oliver Weihe <o.weihe@deltacomputer.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-10-14 at 11:43 +0200, Oliver Weihe wrote:
> Hello,
> 
> I've sent this to Andi Kleen and posted this on lkml. Andi suggested to
> sent it to this mailing list.
> 
> 
<snip>
> > 
> > > [Another copy of the reply with linux-kernel added this time]
> > > 
> > > > In my setup I'm allocating an array of ~7GiB memory size in a
> > > > singlethreaded application.
> > > > Startup: numactl --cpunodebind=X ./app
> > > > For X=1,2,3 it works as expected, all memory is allocated on the
> > > > local
> > > > node.
> > > > For X=0 I can see the memory beeing allocated on node0 as long as
> > > > ~3GiB
> > > > are "free" on node0. At this point the kernel starts using memory
> > > > from
> > > > node1 for the app!
> > > 
> > > Hmm, that sounds like it doesn't want to use the 4GB DMA zone.
> > > 
> > > Normally there should be no protection on it, but perhaps something 
> > > broke.
> > > 


Check your /proc/sys/vm/numa_zonelist_order.  By default, the kernel
will use "zone order", meaning it will overflow to the same zone-e.g.,
Normal--before consuming DMA memory, if the DMA zone is <= half the
system memory.  See default_zonelist_order() and build_zonelists() in
mm/page_alloc.c

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
