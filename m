Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id CBBB66B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 08:18:54 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so5909401pab.38
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:18:54 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id gx4si11406202pbc.261.2014.01.27.05.18.46
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 05:18:47 -0800 (PST)
Date: Mon, 27 Jan 2014 05:19:50 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/8] mm/swap: fix some rare issues in swap subsystem
Message-ID: <20140127131950.GD16027@kroah.com>
References: <000501cf1b46$b899edb0$29cdc910$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000501cf1b46$b899edb0$29cdc910$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: hughd@google.com, 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, shli@kernel.org, 'Bob Liu' <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, 'Seth Jennings' <sjennings@variantweb.net>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, 'Heesub Shin' <heesub.shin@samsung.com>, mguzik@redhat.com

On Mon, Jan 27, 2014 at 06:00:03PM +0800, Weijie Yang wrote:
> This patch series focus on some tiny and rare issues in swap subsystem.
> These issues happen rarely, so it is just for the correctness of the code.
> 
> It firstly add some comments to try to make swap flag/lock usage in
> swapfile.c more clear and readable,
> and fix some rare issues in swap subsystem that cause race condition among
> swapon, swapoff and frontswap_register_ops.
> and fix some not race issues.
> 
> Please see individual patch for details, any complaint and suggestion
> are welcome.
> 
> Regards
> 
> patch 1/8: add some comments for swap flag/lock usage
> 
> patch 2/8: fix race on swap_info reuse between swapoff and swapon
> 	This patch has been in akpm -mm tree, however I improve it according
> 	to Heesub Shin and Mateusz Guzik's suggestion. So, that old patch need
> 	to be dropped.
> 
> patch 3/8: prevent concurrent swapon on the same S_ISBLK blockdev
> 
> patch 4/8: fix race among frontswap_register_ops, swapoff and swapon
> 
> patch 5/8: drop useless and bug frontswap_shrink codes
> 
> patch 6/8: remove swap_lock to simplify si_swapinfo()
> 
> patch 7/8: check swapfile blocksize greater than PAGE_SIZE
> 
> patch 8/8: add missing handle on a dup-store failure
> 
>  include/linux/blkdev.h    |    4 +++-
>  include/linux/frontswap.h |    2 --
>  include/linux/swapfile.h  |    4 +---
>  mm/frontswap.c            |  127 +++++++------------------------------------------------------------------------------------------------------------------------
>  mm/page_io.c              |    2 ++
>  mm/rmap.c                 |    2 +-
>  mm/swapfile.c             |  138 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----------------------------------------
>  7 files changed, 112 insertions(+), 167 deletions(-)


<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
