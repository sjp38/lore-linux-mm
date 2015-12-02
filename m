Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9010E6B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 08:23:28 -0500 (EST)
Received: by wmvv187 with SMTP id v187so254654688wmv.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 05:23:28 -0800 (PST)
Received: from cvs.linux-mips.org (eddie.linux-mips.org. [148.251.95.138])
        by mx.google.com with ESMTP id x84si5071938wmg.94.2015.12.02.05.23.27
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 05:23:27 -0800 (PST)
Received: from localhost.localdomain ([127.0.0.1]:57572 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S27007537AbbLBNX0s-7Za (ORCPT <rfc822;linux-mm@kvack.org>);
        Wed, 2 Dec 2015 14:23:26 +0100
Date: Wed, 2 Dec 2015 14:23:20 +0100
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 4/7] mips: mm/gup: add gup trace points
Message-ID: <20151202132320.GA24730@linux-mips.org>
References: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
 <1449011177-30686-5-git-send-email-yang.shi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449011177-30686-5-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, linux-mips@linux-mips.org

On Tue, Dec 01, 2015 at 03:06:14PM -0800, Yang Shi wrote:

>  arch/mips/mm/gup.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
> index 349995d..3c5b8c8 100644
> --- a/arch/mips/mm/gup.c
> +++ b/arch/mips/mm/gup.c
> @@ -12,6 +12,9 @@
>  #include <linux/swap.h>
>  #include <linux/hugetlb.h>
>  
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/gup.h>
> +
>  #include <asm/cpu-features.h>
>  #include <asm/pgtable.h>
>  
> @@ -211,6 +214,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  					(void __user *)start, len)))
>  		return 0;
>  
> +	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
> +
>  	/*
>  	 * XXX: batch / limit 'nr', to avoid large irq off latency
>  	 * needs some instrumenting to determine the common sizes used by
> @@ -277,6 +282,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  	if (end < start || cpu_has_dc_aliases)
>  		goto slow_irqon;
>  
> +	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
> +
>  	/* XXX: batch / limit 'nr' */
>  	local_irq_disable();
>  	pgdp = pgd_offset(mm, addr);

Acked-by: Ralf Baechle <ralf@linux-mips.org>

Please feel free to merge this upstream with the remainder of the
series once it's been acked.

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
