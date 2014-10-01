Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2185C6B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 07:31:42 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so108829pab.26
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 04:31:41 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id zd2si666669pbb.44.2014.10.01.04.31.40
        for <linux-mm@kvack.org>;
        Wed, 01 Oct 2014 04:31:41 -0700 (PDT)
Message-ID: <1412163094.3126.0.camel@linux.intel.com>
Subject: Re: [PATCH] MM: dmapool: Fixed a brace coding style issue
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Wed, 01 Oct 2014 14:31:34 +0300
In-Reply-To: <542B176E.6000007@gmail.com>
References: <542B176E.6000007@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McQuade <paulmcquad@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Krzysztof =?UTF-8?Q?Ha=C5=82asa?= <khalasa@piap.pl>, jiri Kosina <jkosina@suse.cz>, Hiroshige Sato <sato.vintage@gmail.com>, Daeseok Youn <daeseok.youn@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, 2014-09-30 at 21:49 +0100, Paul McQuade wrote:
> From 33890970bfffc2bd64b307c41e5c1c92aaba8a2e Mon Sep 17 00:00:00 2001
> From: Paul McQuade <paulmcquad@gmail.com>
> Date: Tue, 30 Sep 2014 21:39:37 +0100
> Subject: [PATCH] MM: dmapool: Fixed a brace coding style issue
> 
> Removed 3 brace coding style for any arm of this statement
> 
> Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
> ---
>  mm/dmapool.c | 17 ++++++++---------
>  1 file changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/dmapool.c b/mm/dmapool.c
> index ba8019b..8b3b050 100644
> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -133,28 +133,27 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
>      struct dma_pool *retval;
>      size_t allocation;
>  
> -    if (align == 0) {
> +    if (align == 0)
>          align = 1;
> -    } else if (align & (align - 1)) {
> +    else if (align & (align - 1))
>          return NULL;
> -    }
>  
> -    if (size == 0) {
> +

Extra empty line?


> +    if (size == 0)
>          return NULL;
> -    } else if (size < 4) {
> +    else if (size < 4)

>          size = 4;
> -    }
> +
>  
>      if ((size % align) != 0)
>          size = ALIGN(size, align);
>  
>      allocation = max_t(size_t, size, PAGE_SIZE);
>  
> -    if (!boundary) {
> +    if (!boundary)
>          boundary = allocation;
> -    } else if ((boundary < size) || (boundary & (boundary - 1))) {
> +    else if ((boundary < size) || (boundary & (boundary - 1)))
>          return NULL;
> -    }
>  
>      retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
>      if (!retval)


-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
