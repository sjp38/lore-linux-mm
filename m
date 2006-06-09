Date: Fri, 9 Jun 2006 10:38:20 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 01/14] Per zone counter functionality
Message-Id: <20060609103820.a8cfc7b4.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0606091016060.32632@schroedinger.engr.sgi.com>
References: <20060608230239.25121.83503.sendpatchset@schroedinger.engr.sgi.com>
	<20060608230244.25121.76440.sendpatchset@schroedinger.engr.sgi.com>
	<20060608210045.62129826.akpm@osdl.org>
	<Pine.LNX.4.64.0606090845130.31570@schroedinger.engr.sgi.com>
	<20060609100627.5ff14228.akpm@osdl.org>
	<Pine.LNX.4.64.0606091016060.32632@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jun 2006 10:18:23 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 9 Jun 2006, Andrew Morton wrote:
> 
> > There's no need for an atomic op - at the most the architecture would need
> > local_irq_disable() protection, and that's only if it doesn't have an
> > atomic-wrt-this-cpu add instruction.
> 
> So I can drop the VM_STATS() definitions?

I _think_ so.  But a bit of a review of the existing atomic ops for the
major architectures wouldn't hurt.

> > > Right thought about that one as well. Can we stablize this first before I 
> > > do another big reorg?
> > 
> > That's unfortunate patch ordering.  Do it (much) later I guess.
> 
> Well there are a couple of trailing issues that would have to be resolved 
> before that happens. I have another patchset here that does something more 
> to the remaining counters.

It's a relatively minor issue - we can do this little cleanup much later on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
