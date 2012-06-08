Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id B6BF26B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 03:13:14 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2414050dak.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 00:13:14 -0700 (PDT)
Message-ID: <4FD1A5FE.7020305@vflare.org>
Date: Fri, 08 Jun 2012 00:13:02 -0700
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3] zsmalloc: zsmalloc: use unsigned long instead of void
 *
References: <1339137567-29656-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1339137567-29656-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>

On 06/07/2012 11:39 PM, Minchan Kim wrote:

> We should use unsigned long as handle instead of void * to avoid any
> confusion. Without this, users may just treat zs_malloc return value as
> a pointer and try to deference it.
> 
> This patch passed compile test(zram, zcache and ramster) and zram is
> tested on qemu.
> 
> changelog
>   * from v2
> 	- remove hval pointed out by Nitin
> 	- based on next-20120607
>   * from v1
> 	- change zcache's zv_create return value
> 	- baesd on next-20120604
> 
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zcache/zcache-main.c     |   12 ++++++------
>  drivers/staging/zram/zram_drv.c          |   16 ++++++++--------
>  drivers/staging/zram/zram_drv.h          |    2 +-
>  drivers/staging/zsmalloc/zsmalloc-main.c |   28 +++++++++++++---------------
>  drivers/staging/zsmalloc/zsmalloc.h      |    8 ++++----
>  5 files changed, 32 insertions(+), 34 deletions(-)
> 


Thanks for all these fixes and cleanups.

Acked-by: Nitin Gupta <ngupta@vflare.org>

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
