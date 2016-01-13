Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9145A828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 13:13:10 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id e65so85259487pfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 10:13:10 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id c26si3408387pfj.47.2016.01.13.10.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 10:13:09 -0800 (PST)
Received: by mail-pa0-x229.google.com with SMTP id yy13so269479215pab.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 10:13:09 -0800 (PST)
Subject: Re: [PATCH v5 7/7] sparc64: mm/gup: add gup trace points
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
 <1449696151-4195-8-git-send-email-yang.shi@linaro.org>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <569693B4.6060305@linaro.org>
Date: Wed, 13 Jan 2016 10:13:08 -0800
MIME-Version: 1.0
In-Reply-To: <1449696151-4195-8-git-send-email-yang.shi@linaro.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org

Hi David,

Any comment on this one? The tracing part review has been done.

Thanks,
Yang


On 12/9/2015 1:22 PM, Yang Shi wrote:
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: sparclinux@vger.kernel.org
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---
>   arch/sparc/mm/gup.c | 6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
> index 2e5c4fc..5a06c34 100644
> --- a/arch/sparc/mm/gup.c
> +++ b/arch/sparc/mm/gup.c
> @@ -12,6 +12,8 @@
>   #include <linux/rwsem.h>
>   #include <asm/pgtable.h>
>
> +#include <trace/events/gup.h>
> +
>   /*
>    * The performance critical leaf functions are made noinline otherwise gcc
>    * inlines everything into a single function which results in too much
> @@ -174,6 +176,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   	len = (unsigned long) nr_pages << PAGE_SHIFT;
>   	end = start + len;
>
> +	trace_gup_get_user_pages_fast(start, nr_pages);
> +
>   	local_irq_save(flags);
>   	pgdp = pgd_offset(mm, addr);
>   	do {
> @@ -236,6 +240,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>
>   	local_irq_enable();
>
> +	trace_gup_get_user_pages_fast(start, nr_pages);
> +
>   	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
>   	return nr;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
