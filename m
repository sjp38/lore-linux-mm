Subject: Re: [patch 07/10] Memoryless nodes: SLUB support
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706200951300.22446@schroedinger.engr.sgi.com>
References: <20070618191956.411091458@sgi.com>
	 <20070618192545.764710140@sgi.com> <1182348612.5058.3.camel@localhost>
	 <Pine.LNX.4.64.0706200951300.22446@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 20 Jun 2007 13:17:28 -0400
Message-Id: <1182359848.5058.10.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-20 at 09:53 -0700, Christoph Lameter wrote:
> On Wed, 20 Jun 2007, Lee Schermerhorn wrote:
> 
> > This patch didn't apply to 22-rc4-mm2.  Does it assume some other SLUB
> > patches?
> 
> Yes sorry this was based on SLUB with patches already accepted by Andrew 
> for SLUB.

No problem.  That's what I thought happened, as I did see a big SLUB
series of yours go by.  Just wanted to be sure.

>  
> > I resolved the conflicts by just doing what the description says:
> > replacing all 'for_each_online_node" with "for_each_memory_node", but I
> > was surprised that this one patch out of 10 didn't apply.  I'm probably
> > missing some other patch.
> 
> I think you should be fine with that approach. 

It appears to be running OK.

> There is a later patch that 
> does more for_each_memory stuff for the policy layer. I'd appreciate it if 
> you could check if that proposed change in semantics for memoryless 
> nodes makes sense to you.

So far, so good.  We moved all of our equipment between buildings over
the weekend and I still don't have all of the test machines back
on-line.  I have tested your patches with Nish's on my ia64 NUMA
platform, and it seems to be "doing the right thing" for this particular
configuration because the DMA zone on the hardware-interleaved
pseudo-node is too small to allocate even one 256MB huge page.  On a
larger system, I think that it will be allocating some huge pages out of
the DMA zone--which I don't want.  I have an idea for fixing that that
we can discuss at some point.

I'll continue to look at/test your memoryless-node patches for other
than hugepage allocations and on other platforms, as they come on line.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
