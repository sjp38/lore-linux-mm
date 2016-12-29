Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 400796B0253
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 02:56:57 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so1135525334pgc.1
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 23:56:57 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k23si52698241pli.81.2016.12.28.23.56.55
        for <linux-mm@kvack.org>;
        Wed, 28 Dec 2016 23:56:56 -0800 (PST)
Date: Thu, 29 Dec 2016 16:56:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: mm: fix typo of cache_alloc_zspage()
Message-ID: <20161229075654.GF1815@bbox>
References: <58646FB7.2040502@huawei.com>
 <20161229064457.GD1815@bbox>
 <20161229065205.GA3892@jagdpanzerIV.localdomain>
 <20161229065935.GE1815@bbox>
 <20161229073403.GB3892@jagdpanzerIV.localdomain>
MIME-Version: 1.0
In-Reply-To: <20161229073403.GB3892@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, ngupta@vflare.org, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Dec 29, 2016 at 04:34:03PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (12/29/16 15:59), Minchan Kim wrote:
> [..]
> > > I don't know... do we want to have it as a separate patch?
> > > may be we can fold it into some other patch someday later.
> > 
> > Xishi spent his time to make the patch(review,create/send). And I want to
> > give a credit to him. :)
> 
> sure, I didn't mean "let's seize the credit" :)  my reasoning was
> that that patch hardly can be counted even as trivial. per
> documentation:
> 
> : Trivial patches must qualify for one of the following rules:
> :
> : - Spelling fixes in documentation
> : - Spelling fixes for errors which could break :manpage:`grep(1)`
> : - Warning fixes (cluttering with useless warnings is bad)
> : - Compilation fixes (only if they are actually correct)
> : - Runtime fixes (only if they actually fix things)
> : - Removing use of deprecated functions/macros
> : - Contact detail and documentation fixes
> : - Non-portable code replaced by portable code (even in arch-specific,
> :   since people copy, as long as it's trivial)
> : - Any fix by the author/maintainer of the file (ie. patch monkey
> :   in re-transmission mode)
> 
> 
> hence was my question. we can have it as "p.s. in this patch we also
> remove XYZ reported by Xishi Qiu".
> 
> but up to you.
> 
> 
> 
> for instance, we can have Xishi's fix up as part of this "fix documentation
> typos" patch. which can be counted in as trivial.

Xishi, Could you send your patch with fixing ones Sergey pointed out
if Sergey doesn't mind?

You should include Sergey's SOB, too.

> 
> 
> ---
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 9cc3c0b2c2c1..af7cd90c26f7 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -25,7 +25,7 @@
>   * Usage of struct page flags:
>   *     PG_private: identifies the first component page
>   *     PG_private2: identifies the last component page
> - *     PG_owner_priv_1: indentifies the huge component page
> + *     PG_owner_priv_1: identifies the huge component page
>   *
>   */
>  
> @@ -65,7 +65,7 @@
>  #define ZS_ALIGN               8
>  
>  /*
> - * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
> + * A single 'zspage' is composed of up to 2^N discontinuous 0-order (single)

Hmm, discontinuous is right?
I'm not a native but discontiguos is wrong? "contiguous" was used mm part widely.


>   * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
>   */
>  #define ZS_MAX_ZSPAGE_ORDER 2
> @@ -2383,7 +2383,7 @@ struct zs_pool *zs_create_pool(const char *name)
>                 goto err;
>  
>         /*
> -        * Iterate reversly, because, size of size_class that we want to use
> +        * Iterate reversely, because, size of size_class that we want to use
>          * for merging should be larger or equal to current size.
>          */
>         for (i = zs_size_classes - 1; i >= 0; i--) {
> 
> 
> ---
> 
> 	-ss
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
