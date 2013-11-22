Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB3F6B0036
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 12:21:56 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id i7so981158yha.32
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 09:21:56 -0800 (PST)
Received: from mail-oa0-x22e.google.com (mail-oa0-x22e.google.com [2607:f8b0:4003:c02::22e])
        by mx.google.com with ESMTPS id 41si11388842yhf.252.2013.11.22.09.21.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 09:21:54 -0800 (PST)
Received: by mail-oa0-f46.google.com with SMTP id o6so1667696oag.19
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 09:21:53 -0800 (PST)
Date: Fri, 22 Nov 2013 11:21:47 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH] mm/zswap: change params from hidden to ro
Message-ID: <20131122172147.GA6477@cerebellum.variantweb.net>
References: <1384965522-5788-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384965522-5788-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Wed, Nov 20, 2013 at 11:38:42AM -0500, Dan Streetman wrote:
> The "compressor" and "enabled" params are currently hidden,
> this changes them to read-only, so userspace can tell if
> zswap is enabled or not and see what compressor is in use.

Reasonable to me.

Acked-by: Seth Jennings <sjennings@variantweb.net>

> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> ---
>  mm/zswap.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index d93510c..36b268b 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -77,12 +77,12 @@ static u64 zswap_duplicate_entry;
>  **********************************/
>  /* Enable/disable zswap (disabled by default, fixed at boot for now) */
>  static bool zswap_enabled __read_mostly;
> -module_param_named(enabled, zswap_enabled, bool, 0);
> +module_param_named(enabled, zswap_enabled, bool, 0444);
>  
>  /* Compressor to be used by zswap (fixed at boot for now) */
>  #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
>  static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
> -module_param_named(compressor, zswap_compressor, charp, 0);
> +module_param_named(compressor, zswap_compressor, charp, 0444);
>  
>  /* The maximum percentage of memory that the compressed pool can occupy */
>  static unsigned int zswap_max_pool_percent = 20;
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
