Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8CF6B0006
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 14:17:37 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id w17so5026098iow.23
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 11:17:37 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m205si441576ioa.211.2018.02.08.11.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Feb 2018 11:17:36 -0800 (PST)
Subject: Re: [PATCH] mm/zpool: zpool_evictable: fix mismatch in parameter name
 and kernel-doc
References: <1518116984-21141-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <1a8a3fb7-3061-d9e7-a42c-53ae96c8ca29@infradead.org>
Date: Thu, 8 Feb 2018 11:17:33 -0800
MIME-Version: 1.0
In-Reply-To: <1518116984-21141-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On 02/08/2018 11:09 AM, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  mm/zpool.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/zpool.c b/mm/zpool.c
> index f8cb83e7699b..9d53a1ef8f1e 100644
> --- a/mm/zpool.c
> +++ b/mm/zpool.c
> @@ -360,7 +360,7 @@ u64 zpool_get_total_size(struct zpool *zpool)
>  
>  /**
>   * zpool_evictable() - Test if zpool is potentially evictable
> - * @pool	The zpool to test
> + * @zpool	The zpool to test

  + * @zpool:	The zpool to test

>   *
>   * Zpool is only potentially evictable when it's created with struct
>   * zpool_ops.evict and its driver implements struct zpool_driver.shrink.
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
