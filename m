Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 323AE6B0038
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 05:17:53 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so267663186pab.2
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 02:17:52 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id xf4si6814097pbc.157.2015.04.22.02.17.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Apr 2015 02:17:52 -0700 (PDT)
Received: by paboj16 with SMTP id oj16so267773339pab.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 02:17:52 -0700 (PDT)
Date: Wed, 22 Apr 2015 18:18:07 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 0/2] zram, zsmalloc: remove obsolete DEBUGs
Message-ID: <20150422091807.GB3624@swordfish>
References: <1429615220-20676-1-git-send-email-m.jabrzyk@samsung.com>
 <1429692756-15197-1-git-send-email-m.jabrzyk@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429692756-15197-1-git-send-email-m.jabrzyk@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Jabrzyk <m.jabrzyk@samsung.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kyungmin.park@samsung.com

On (04/22/15 10:52), Marcin Jabrzyk wrote:
> 
> This patchset removes unused DEBUG defines in zram and zsmalloc,
> that remained in sources and config without actual usage.
> 

Acked-by: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

	-ss

> Changes from v1:
> - Apply the removal also to zsmalloc
> 
> Marcin Jabrzyk (2):
>   zram: remove obsolete ZRAM_DEBUG option
>   zsmalloc: remove obsolete ZSMALLOC_DEBUG
> 
>  drivers/block/zram/Kconfig    | 10 +---------
>  drivers/block/zram/zram_drv.c |  4 ----
>  mm/zsmalloc.c                 |  4 ----
>  3 files changed, 1 insertion(+), 17 deletions(-)
> 
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
