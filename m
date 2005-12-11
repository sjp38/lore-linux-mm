Date: Sun, 11 Dec 2005 15:05:54 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] Fix Kconfig of DMA32 for ia64
Message-ID: <20051211150554.GA25645@infradead.org>
References: <20051210194521.4832.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051210194521.4832.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, "Luck, Tony" <tony.luck@intel.com>
List-ID: <linux-mm.kvack.org>

On Sat, Dec 10, 2005 at 08:05:16PM +0900, Yasunori Goto wrote:
> Andew-san.
> 
> I realized ZONE_DMA32 on -mm has a trivial bug at Kconfig for ia64.
> In include/linux/gfp.h on 2.6.15-rc5-mm1, CONFIG is define like
> followings.
> 
> #ifdef CONFIG_DMA_IS_DMA32
> #define __GFP_DMA32	((__force gfp_t)0x01)	/* ZONE_DMA is ZONE_DMA32
> */
>        :
>        :
> 
> So, CONFIG_"ZONE"_DMA_IS_DMA32 is clearly wrong.
> This is patch for it.

Given that apparently no one cared we should just kill it and give ia64
a proper ZONE_DMA32 post 2.6.15.  No one else tried to use it anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
