Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 1F0726B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 00:10:22 -0400 (EDT)
Date: Mon, 19 Aug 2013 13:10:44 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/4] mm: merge zram into zswap
Message-ID: <20130819041044.GB26832@bbox>
References: <1376815249-6611-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376815249-6611-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, eternaleye@gmail.com, mgorman@suse.de, gregkh@linuxfoundation.org, akpm@linux-foundation.org, axboe@kernel.dk, sjenning@linux.vnet.ibm.com, ngupta@vflare.org, semenzato@google.com, penberg@iki.fi, sonnyrao@google.com, smbarber@google.com, konrad.wilk@oracle.com, riel@redhat.com, kmpark@infradead.org, Bob Liu <bob.liu@oracle.com>

On Sun, Aug 18, 2013 at 04:40:45PM +0800, Bob Liu wrote:
> Both zswap and zram are used to compress anon pages in memory so as to reduce
> swap io operation. The main different is that zswap uses zbud as its allocator
> while zram uses zsmalloc. The other different is zram will create a block
> device, the user need to mkswp and swapon it.
> 
> Minchan has areadly try to promote zram/zsmalloc into drivers/block/, but it may
> cause increase maintenance headaches. Since the purpose of zswap and zram are
> the same, this patch series try to merge them together as Mel suggested.
> Dropped zram from staging and extended zswap with the same feature as zram.
> 
> zswap todo:
> Improve the writeback of zswap pool pages!
> 
> Bob Liu (4):
>   drivers: staging: drop zram and zsmalloc

Bob, I feel you're very rude and I'm really upset.

You're just dropping the subsystem you didn't do anything without any consensus
from who are contriubting lots of patches to make it works well for a long time.
I understand you want to merge zram/zswap to remove the concern Mel suggested
but so your intention might help the community. But the approach was totally wrong.
You just said a few days ago in my thread and I was holiday so I didn't have
a time to reply all of the mail sent to me. Should I break my holiday for
just replying to you? Are you okay that someone else removes or moves your efforts
without any consensus with you while you're spending good time with family?

Please be careful. Bob.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
