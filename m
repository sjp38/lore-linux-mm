Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 39A306B0037
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 21:16:49 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so8531551pdj.16
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 18:16:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sl10si12010833pab.128.2013.12.10.18.16.47
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 18:16:47 -0800 (PST)
Date: Tue, 10 Dec 2013 18:18:20 -0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v9 0/4] zram/zsmalloc promotion
Message-ID: <20131211021820.GA18540@kroah.com>
References: <1386727479-18502-1-git-send-email-minchan@kernel.org>
 <20131211020959.GA17970@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131211020959.GA17970@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>

On Wed, Dec 11, 2013 at 11:09:59AM +0900, Minchan Kim wrote:
> Hello Greg,
> 
> On Wed, Dec 11, 2013 at 11:04:35AM +0900, Minchan Kim wrote:
> > Zram is a simple pseudo block device which can keep data on
> > in-memory with compressed[1].
> > 
> > It have been used for many embedded system for several years
> > One of significant usecase is in-memory swap device.
> > Because NAND which is very popular on most embedded device
> > is weak for frequent write without good wear-level
> > and slow I/O hurts system's responsiblity so zram is really
> > good choice to use memory efficiently.
> > 
> > In previous trial, there was some argument[2] that zram has
> > similar goal with zswap so let's merge zram's functionality
> > into zswap via adding pseudo block device in zswap but I and
> > some people(At least, Hugh and Rik) believe it's not a good idea.
> > [2][3][4] and zswap might go writethrough model[5]. It makes
> > clear difference zram and zswap.
> > 
> > Zram itself is simple/well-designed/good abstraciton so it has
> > clear market(ex, Android, TV, ChromeOS, some Linux distro) which
> > is never niche. :)
> > 
> > Another zram-blk's usecase is following as.
> > The admin can use it as tmpfs so it could help small memory system.
> > The tmpfs is never good solution for swapless embedded system.
> > 
> > Patch 1 adds new Kconfig for zram to use page table method instead
> > of copy.
> > 
> > Patch 2 adds more comment for zsmalloc.
> > 
> > Patch 3 moves zsmalloc under mm.
> > 
> > Patch 4 moves zram from driver/staging to driver/blocks, finally.
> 
> Patch 1(suggested by Andrew Morton) and 2(Just comment to make review easy)
> are prepartion for promotion so I hope it could be merged into your staging
> regardless of allowing promotion at the moment.

Sure, I'll be glad to do so, thanks for letting me know.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
