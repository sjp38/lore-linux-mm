Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id B1B416B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 22:47:41 -0500 (EST)
Date: Mon, 28 Jan 2013 12:47:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/4] staging: zsmalloc: various cleanups/improvments
Message-ID: <20130128034740.GE3321@blaptop>
References: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Hi Seth,

On Fri, Jan 25, 2013 at 11:46:14AM -0600, Seth Jennings wrote:
> These patches are the first 4 patches of the zswap patchset I
> sent out previously.  Some recent commits to zsmalloc and
> zcache in staging-next forced a rebase. While I was at it, Nitin
> (zsmalloc maintainer) requested I break these 4 patches out from
> the zswap patchset, since they stand on their own.

[2/4] and [4/4] is okay to merge current zsmalloc in staging but
[1/4] and [3/4] is dependent on zswap so it should be part of
zswap patchset.

> 
> All are already Acked-by Nitin.
> 
> Based on staging-next as of today.
> 
> Seth Jennings (4):
>   staging: zsmalloc: add gfp flags to zs_create_pool
>   staging: zsmalloc: remove unused pool name
>   staging: zsmalloc: add page alloc/free callbacks
>   staging: zsmalloc: make CLASS_DELTA relative to PAGE_SIZE
> 
>  drivers/staging/zram/zram_drv.c          |    4 +-
>  drivers/staging/zsmalloc/zsmalloc-main.c |   60 ++++++++++++++++++------------
>  drivers/staging/zsmalloc/zsmalloc.h      |   10 ++++-
>  3 files changed, 47 insertions(+), 27 deletions(-)
> 
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
