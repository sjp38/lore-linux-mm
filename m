Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id DB3A96B0070
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 05:57:01 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Slzqr-0000PH-Cz
	for linux-mm@kvack.org; Tue, 03 Jul 2012 11:56:57 +0200
Received: from 117.57.172.73 ([117.57.172.73])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 11:56:57 +0200
Received: from xiyou.wangcong by 117.57.172.73 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 03 Jul 2012 11:56:57 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH 1/4] mm: introduce a safer interface to check
 whether a page is managed by SLxB
Date: Tue, 3 Jul 2012 09:56:45 +0000 (UTC)
Message-ID: <jsufks$tnk$1@dough.gmane.org>
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Tue, 03 Jul 2012 at 03:57 GMT, Jiang Liu <jiang.liu@huawei.com> wrote:
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -18,6 +18,7 @@
>  #include <linux/initrd.h>
>  #include <linux/of_fdt.h>
>  #include <linux/highmem.h>
> +#include <linux/huge_mm.h>
>  #include <linux/gfp.h>
>  #include <linux/memblock.h>
>  #include <linux/dma-contiguous.h>
> @@ -116,7 +117,7 @@ void show_mem(unsigned int filter)
>  				reserved++;
>  			else if (PageSwapCache(page))
>  				cached++;
> -			else if (PageSlab(page))
> +			else if (page_managed_by_slab(page))
>  				slab++;

slab.h should #include <linux/huge_mm.h>, not each C source file calls
page_managed_by_slab().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
