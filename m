Date: Mon, 16 Aug 2004 17:33:22 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: use for page_state accounting fields
Message-ID: <20040816203322.GA21796@logos.cnet>
References: <20040816192941.GB21238@logos.cnet> <20040816143149.510a2f90.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040816143149.510a2f90.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 16, 2004 at 02:31:49PM -0700, Andrew Morton wrote:
> Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> >
> > Hi Andrew,
> > 
> > I suppose you wrote the page_state per-CPU statistics structure.
> > 
> > There are some fields, for instance pgactivate/pgdeactivate, that
> > do not seem to be used anywhere. Sure, they are useful for statistics, 
> > but no place in the kernel exports them to userspace AFAICS.
> > 
> >         unsigned long pgactivate;       /* pages moved inactive->active */
> >         unsigned long pgdeactivate;     /* pages moved active->inactive */
> > 
> > Counting them is somewhat expensive I believe (need to disable IRQ), based
> > on the assumption that these days any cycle is a loss.
> > 
> > So, from my POV we should 
> > 
> > a) export them to userspace
> > b) surround them by CONFIG_DEBUG_MMSTATS or something similar
> > 
> > Tell me I'm wrong.
> 
> Take a peek in /proc/vmstat ;)

Doh. 

Is there any tool which reads these statistics and makes use of them? Number of 
inactivations/activations per timeframe, etc?

Thanks
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
