Date: Wed, 2 Feb 2005 11:05:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: A scrub daemon (prezeroing)
In-Reply-To: <20050202153256.GA19615@logos.cnet>
Message-ID: <Pine.LNX.4.58.0502021103410.12695@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
 <1106828124.19262.45.camel@hades.cambridge.redhat.com> <20050202153256.GA19615@logos.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: David Woodhouse <dwmw2@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Feb 2005, Marcelo Tosatti wrote:

> Sounds very interesting idea to me. Guess it depends on whether the cost of
> DMA write for memory zeroing, which is memory architecture/DMA engine dependant,
> offsets the cost of CPU zeroing.
>
> Do you have any thoughts on that?
>
> I wonder if such thing (using unrelated devices DMA engine's for zeroing) ever been
> done on other OS'es?
>
> AFAIK SGI's BTE is special purpose hardware for memory zeroing.

Nope the BTE is a block transfer engine. Its an inter numa node DMA thing
that is being abused to zero blocks.

The same can be done with most DMA chips (I have done so on some other
platforms not on i386)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
