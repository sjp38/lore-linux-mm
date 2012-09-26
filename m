Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 9C1996B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 05:44:03 -0400 (EDT)
Message-ID: <5062CE1E.3010203@cn.fujitsu.com>
Date: Wed, 26 Sep 2012 17:42:54 +0800
From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Reply-To: gaowanlong@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] zsmalloc: promote to lib/
References: <1348649419-16494-1-git-send-email-minchan@kernel.org> <1348649419-16494-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1348649419-16494-2-git-send-email-minchan@kernel.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/26/2012 04:50 PM, Minchan Kim wrote:
> This patch promotes the slab-based zsmalloc memory allocator
> from the staging tree to lib/
> 
> zcache/zram depends on this allocator for storing compressed RAM pages
> in an efficient way under system wide memory pressure where
> high-order (greater than 0) page allocation are very likely to
> fail.
> 
> For more information on zsmalloc and its internals, read the
> documentation at the top of the zsmalloc.c file.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/Kconfig                  |    2 -
>  drivers/staging/Makefile                 |    1 -
>  drivers/staging/zcache/zcache-main.c     |    4 +-
>  drivers/staging/zram/zram_drv.h          |    3 +-
>  drivers/staging/zsmalloc/Kconfig         |   10 -
>  drivers/staging/zsmalloc/Makefile        |    3 -
>  drivers/staging/zsmalloc/zsmalloc-main.c | 1064 ------------------------------
>  drivers/staging/zsmalloc/zsmalloc.h      |   43 --
>  include/linux/zsmalloc.h                 |   43 ++
>  lib/Kconfig                              |    2 +
>  lib/Makefile                             |    1 +
>  lib/zsmalloc/Kconfig                     |   18 +
>  lib/zsmalloc/Makefile                    |    1 +
>  lib/zsmalloc/zsmalloc.c                  | 1064 ++++++++++++++++++++++++++++++
>  14 files changed, 1132 insertions(+), 1127 deletions(-)
>  delete mode 100644 drivers/staging/zsmalloc/Kconfig
>  delete mode 100644 drivers/staging/zsmalloc/Makefile
>  delete mode 100644 drivers/staging/zsmalloc/zsmalloc-main.c
>  delete mode 100644 drivers/staging/zsmalloc/zsmalloc.h
>  create mode 100644 include/linux/zsmalloc.h
>  create mode 100644 lib/zsmalloc/Kconfig
>  create mode 100644 lib/zsmalloc/Makefile
>  create mode 100644 lib/zsmalloc/zsmalloc.c

Since there's just one file here, why not just move to lib flatly without creating a new directory?

Thanks,
Wanlong Gao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
