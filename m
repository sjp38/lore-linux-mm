Date: Fri, 9 Jun 2006 10:18:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01/14] Per zone counter functionality
In-Reply-To: <20060609100627.5ff14228.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0606091016060.32632@schroedinger.engr.sgi.com>
References: <20060608230239.25121.83503.sendpatchset@schroedinger.engr.sgi.com>
 <20060608230244.25121.76440.sendpatchset@schroedinger.engr.sgi.com>
 <20060608210045.62129826.akpm@osdl.org> <Pine.LNX.4.64.0606090845130.31570@schroedinger.engr.sgi.com>
 <20060609100627.5ff14228.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jun 2006, Andrew Morton wrote:

> There's no need for an atomic op - at the most the architecture would need
> local_irq_disable() protection, and that's only if it doesn't have an
> atomic-wrt-this-cpu add instruction.

So I can drop the VM_STATS() definitions?

> > Right thought about that one as well. Can we stablize this first before I 
> > do another big reorg?
> 
> That's unfortunate patch ordering.  Do it (much) later I guess.

Well there are a couple of trailing issues that would have to be resolved 
before that happens. I have another patchset here that does something more 
to the remaining counters.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
