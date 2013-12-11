Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 259306B0037
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 21:09:56 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so8557364pdj.32
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 18:09:55 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id bt3si11978594pbb.344.2013.12.10.18.09.53
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 18:09:54 -0800 (PST)
Date: Wed, 11 Dec 2013 11:09:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v9 0/4] zram/zsmalloc promotion
Message-ID: <20131211020959.GA17970@bbox>
References: <1386727479-18502-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386727479-18502-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>

Hello Greg,

On Wed, Dec 11, 2013 at 11:04:35AM +0900, Minchan Kim wrote:
> Zram is a simple pseudo block device which can keep data on
> in-memory with compressed[1].
> 
> It have been used for many embedded system for several years
> One of significant usecase is in-memory swap device.
> Because NAND which is very popular on most embedded device
> is weak for frequent write without good wear-level
> and slow I/O hurts system's responsiblity so zram is really
> good choice to use memory efficiently.
> 
> In previous trial, there was some argument[2] that zram has
> similar goal with zswap so let's merge zram's functionality
> into zswap via adding pseudo block device in zswap but I and
> some people(At least, Hugh and Rik) believe it's not a good idea.
> [2][3][4] and zswap might go writethrough model[5]. It makes
> clear difference zram and zswap.
> 
> Zram itself is simple/well-designed/good abstraciton so it has
> clear market(ex, Android, TV, ChromeOS, some Linux distro) which
> is never niche. :)
> 
> Another zram-blk's usecase is following as.
> The admin can use it as tmpfs so it could help small memory system.
> The tmpfs is never good solution for swapless embedded system.
> 
> Patch 1 adds new Kconfig for zram to use page table method instead
> of copy.
> 
> Patch 2 adds more comment for zsmalloc.
> 
> Patch 3 moves zsmalloc under mm.
> 
> Patch 4 moves zram from driver/staging to driver/blocks, finally.

Patch 1(suggested by Andrew Morton) and 2(Just comment to make review easy)
are prepartion for promotion so I hope it could be merged into your staging
regardless of allowing promotion at the moment.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
