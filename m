Date: Wed, 2 Feb 2005 21:00:46 +0000 (GMT)
From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: A scrub daemon (prezeroing)
In-Reply-To: <20050202153256.GA19615@logos.cnet>
Message-ID: <Pine.LNX.4.61L.0502022000470.9448@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
 <1106828124.19262.45.camel@hades.cambridge.redhat.com> <20050202153256.GA19615@logos.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: David Woodhouse <dwmw2@infradead.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Feb 2005, Marcelo Tosatti wrote:

> > Some architectures tend to have spare DMA engines lying around. There's
> > no need to use the CPU for zeroing pages. How feasible would it be for
> > scrubd to use these?
[...]
> I suppose you are talking about DMA engines which are not being driven 
> by any driver ?

 E.g. the Broadcom's MIPS64-based SOCs have four general purpose DMA 
engines onchip which can transfer data to/from the memory controller in 
32-byte chunks over the 256-bit internal bus.  We have hardly any use for 
these devices and certainly not for all four of them.

> Sounds very interesting idea to me. Guess it depends on whether the cost of 
> DMA write for memory zeroing, which is memory architecture/DMA engine dependant, 
> offsets the cost of CPU zeroing.

 I suppose so, at least with the Broadcom's chips you avoid cache 
trashing, yet you don't need to care about stale data as coherency between 
CPUs and the onchip memory controller is maintained automatically by 
hardware.

  Maciej
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
