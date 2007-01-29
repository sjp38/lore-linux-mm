Date: Mon, 29 Jan 2007 15:37:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/8] Create ZONE_MOVABLE to partition memory between
 movable and non-movable pages
In-Reply-To: <20070129225000.GG6602@flint.arm.linux.org.uk>
Message-ID: <Pine.LNX.4.64.0701291533500.1169@schroedinger.engr.sgi.com>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <20070126030753.03529e7a.akpm@osdl.org> <Pine.LNX.4.64.0701260751230.6141@schroedinger.engr.sgi.com>
 <20070126114615.5aa9e213.akpm@osdl.org> <Pine.LNX.4.64.0701261147300.15394@schroedinger.engr.sgi.com>
 <20070126122747.dde74c97.akpm@osdl.org> <Pine.LNX.4.64.0701291349450.548@schroedinger.engr.sgi.com>
 <20070129143654.27fcd4a4.akpm@osdl.org> <Pine.LNX.4.64.0701291441260.1102@schroedinger.engr.sgi.com>
 <20070129225000.GG6602@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk+lkml@arm.linux.org.uk>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007, Russell King wrote:

> This sounds like it could help ARM where we have some weird DMA areas.

Some ARM platforms have no need for a ZONE_DMA. The code in mm allows you 
to not compile ZONE_DMA support into these kernels.

> What will help even more is if the block layer can also be persuaded that
> a device dma mask is precisely that - a mask - and not a set of leading
> ones followed by a set of zeros, then we could eliminate the really ugly
> dmabounce code.

With a alloc_pages_range() one would be able to specify upper and lower 
boundaries. The device dma mask can be translated to a fitting boundary. 
Maybe we can then also get rid of the device mask and specify a boundary 
there. There is a lot of ugly code all around that circumvents the 
existing issues with dma masks. That would all go away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
