Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7E35C6B0035
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:34:41 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so2268794pdj.26
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:34:41 -0800 (PST)
Received: from psmtp.com ([74.125.245.185])
        by mx.google.com with SMTP id z1si14725080pbn.241.2013.11.20.09.34.38
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 09:34:39 -0800 (PST)
Received: by mail-la0-f53.google.com with SMTP id ea20so7682316lab.12
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:34:35 -0800 (PST)
Date: Wed, 20 Nov 2013 18:33:50 +0100
From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH] mm/zswap: change params from hidden to ro
Message-ID: <20131120173347.GA2369@hp530>
References: <1384965522-5788-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <1384965522-5788-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org, Seth Jennings <sjennings@variantweb.net>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

Hi Dan!

On Wed, Nov 20, 2013 at 11:38:42AM -0500, Dan Streetman wrote:
> The "compressor" and "enabled" params are currently hidden,
> this changes them to read-only, so userspace can tell if
> zswap is enabled or not and see what compressor is in use.

Could you elaborate more why this pice of information is necessary for
userspace?

Vladimir

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
