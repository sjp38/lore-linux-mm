Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 056386B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 14:11:01 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so600317pdj.22
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:11:01 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id z4si1047997pdn.19.2014.07.03.11.10.59
        for <linux-mm@kvack.org>;
        Thu, 03 Jul 2014 11:11:01 -0700 (PDT)
Date: Thu, 3 Jul 2014 19:10:59 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCHv4 1/5] lib/genalloc.c: Add power aligned algorithm
Message-ID: <20140703181059.GJ17372@arm.com>
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>
 <1404324218-4743-2-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404324218-4743-2-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jul 02, 2014 at 07:03:34PM +0100, Laura Abbott wrote:
> 
> One of the more common algorithms used for allocation
> is to align the start address of the allocation to
> the order of size requested. Add this as an algorithm
> option for genalloc.
> 
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> ---
>  include/linux/genalloc.h |  4 ++++
>  lib/genalloc.c           | 20 ++++++++++++++++++++
>  2 files changed, 24 insertions(+)
> 
> diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
> index 1c2fdaa..3cd0934 100644
> --- a/include/linux/genalloc.h
> +++ b/include/linux/genalloc.h
> @@ -110,6 +110,10 @@ extern void gen_pool_set_algo(struct gen_pool *pool, genpool_algo_t algo,
>  extern unsigned long gen_pool_first_fit(unsigned long *map, unsigned long size,
>  		unsigned long start, unsigned int nr, void *data);
>  
> +extern unsigned long gen_pool_first_fit_order_align(unsigned long *map,
> +		unsigned long size, unsigned long start, unsigned int nr,
> +		void *data);
> +

You could also update gen_pool_first_fit to call this new function instead.

Anyway, that's up to you:

  Acked-by: Will Deacon <will.deacon@arm.com>

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
