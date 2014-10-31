Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id BAB6D280046
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 10:10:20 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id y20so1297540ier.6
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 07:10:20 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id cc7si15597382icc.107.2014.10.31.07.10.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 07:10:20 -0700 (PDT)
Date: Fri, 31 Oct 2014 10:10:13 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] Frontswap: fix the condition in BUG_ON
Message-ID: <20141031141013.GH4704@laptop.dumpdata.com>
References: <CAFNq8R7xYA2GTpWE-5rHr5c-xX0ZONKHX6wSbra2MDo1M2DSHQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFNq8R7xYA2GTpWE-5rHr5c-xX0ZONKHX6wSbra2MDo1M2DSHQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Haifeng <omycle@gmail.com>, akpm@linux-foundation.org
Cc: open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Fri, Oct 31, 2014 at 06:14:19PM +0800, Li Haifeng wrote:
> >From 012a564c7210346b99d12e3d2485542bb090586e Mon Sep 17 00:00:00 2001
> From: Haifeng Li <omycle@gmail.com>
> Date: Fri, 31 Oct 2014 17:40:44 +0800
> Subject: [PATCH] Frontswap: fix the condition in BUG_ON
> 
> The largest index of swap device is MAX_SWAPFILES-1. So the type
> should be less than MAX_SWAPFILES.

Ok, so we would never hit this BUG_ON because of that.

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

P.S.
Andrew - are you OK picking this up?

Thank you!
> 
> Signed-off-by: Haifeng Li <omycle@gmail.com>
> ---
>  mm/frontswap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index c30eec5..1b80c05 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -182,7 +182,7 @@ void __frontswap_init(unsigned type, unsigned long *map)
>         if (frontswap_ops)
>                 frontswap_ops->init(type);
>         else {
> -               BUG_ON(type > MAX_SWAPFILES);
> +               BUG_ON(type >= MAX_SWAPFILES);
>                 set_bit(type, need_init);
>         }
>  }
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
