Date: Fri, 16 Nov 2001 09:33:56 +0100
From: Jens Axboe <axboe@suse.de>
Subject: Re: parisc scatterlist doesn't want page/offset
Message-ID: <20011116093356.D27010@suse.de>
References: <200111160730.AAA18774@puffin.external.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200111160730.AAA18774@puffin.external.hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Grant Grundler <grundler@puffin.external.hp.com>
Cc: "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 16 2001, Grant Grundler wrote:
> Hi all,
> Could someone point me to any discussion about adding
> page/offset to struct scatterlist?

See lkml a couple months back, 32-bit dma etc discussion.
> 
> To me, it looks like a half-assed step to support DMA to HIGHMEM
> on 32-bit arches.  TBH, I'd like to see page/offset replace
> address in the pci_map* interfaces and struct scatterlist.
> But then replace it across the board so the DMA mapping code
> doesn't have to decide which field to use (KISS). This really
> belongs in 2.5 kernel.

It's not half-assed, it's needed. I would imagine that pci_map_single
etc stays though, although pci_map_page or pci_map_sg is the preferred
approach.

Regarding the patch -- please add a helper function to set the sg list
instead of introducing CONFIG_HIGHMEM all over the place. I'm assuming
you are missing the piece which leaves out page/offset for non-highmem,
if not you are really pedantic about saving a few cycles :-)

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
