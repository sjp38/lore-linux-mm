Date: Fri, 27 Aug 2004 23:04:26 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: OOM-killer for zone DMA?
Message-ID: <20040828060426.GI2793@holomorphy.com>
References: <s5hoekwjz00.wl@alsa2.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <s5hoekwjz00.wl@alsa2.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Takashi Iwai <tiwai@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2004 at 07:02:07PM +0200, Takashi Iwai wrote:
> In the primary version of my DMA allocation patch, I tried to allocate
> pages with GFP_DMA as much as possible, then allocate with GFP_KERNEL
> as fallback.  But this doesn't work.  When the zone DMA is exhausted,
> I oberseved endless OOM-killer.
> Is this a desired behavior?  I don't think triggering OOM-killer for
> zone DMA makes sense, because apps don't allocate pages in this
> area...
> Note that the driver tried to allocate bunch of single pages with
> GFP_DMA, not big pages, by calling dma_alloc_coherent with GFP_DMA
> only (no __GFP_REPEAT or such modifiers).

How are you triggering this?


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
