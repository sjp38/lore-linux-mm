Date: Wed, 2 Feb 2005 13:31:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: A scrub daemon (prezeroing)
In-Reply-To: <20050202163110.GB23132@logos.cnet>
Message-ID: <Pine.LNX.4.58.0502021328290.13966@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
 <1106828124.19262.45.camel@hades.cambridge.redhat.com> <20050202153256.GA19615@logos.cnet>
 <Pine.LNX.4.58.0502021103410.12695@schroedinger.engr.sgi.com>
 <20050202163110.GB23132@logos.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: David Woodhouse <dwmw2@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Feb 2005, Marcelo Tosatti wrote:

> > Nope the BTE is a block transfer engine. Its an inter numa node DMA thing
> > that is being abused to zero blocks.
> Ah, OK.
> Is there a driver for normal BTE operation or is not kernel-controlled ?

There is a function bte_copy in the ia64 arch. See

arch/ia64/sn/kernel/bte.c

> I wonder what has to be done to have active DMA engines be abused for zeroing
> when idle and what are the implications of that. Some kind of notification mechanism
> is necessary to inform idleness ?
>
> Someone should try implementing the zeroing driver for a fast x86 PCI device. :)

Sure but I am on ia64 not i386. Find your own means to abuse your own
chips ... ;-)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
