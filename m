Message-ID: <413021BA.3090908@yahoo.com.au>
Date: Sat, 28 Aug 2004 16:10:02 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: OOM-killer for zone DMA?
References: <s5hoekwjz00.wl@alsa2.suse.de>
In-Reply-To: <s5hoekwjz00.wl@alsa2.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Takashi Iwai <tiwai@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Takashi Iwai wrote:
> Hi,
> 
> In the primary version of my DMA allocation patch, I tried to allocate
> pages with GFP_DMA as much as possible, then allocate with GFP_KERNEL
> as fallback.  But this doesn't work.  When the zone DMA is exhausted,
> I oberseved endless OOM-killer.
> 
> Is this a desired behavior?  I don't think triggering OOM-killer for
> zone DMA makes sense, because apps don't allocate pages in this
> area...
> 

They easily could.

> Note that the driver tried to allocate bunch of single pages with
> GFP_DMA, not big pages, by calling dma_alloc_coherent with GFP_DMA
> only (no __GFP_REPEAT or such modifiers).
> 

You at least need __GFP_NORETRY to achieve what you want.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
