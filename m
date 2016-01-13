Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 07AC1828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 13:11:50 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id ho8so101316687pac.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 10:11:50 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id r70si3373977pfr.123.2016.01.13.10.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 10:11:49 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id ho8so101316545pac.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 10:11:49 -0800 (PST)
Subject: Re: [PATCH v5 3/7] x86: mm/gup: add gup trace points
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
 <1449696151-4195-4-git-send-email-yang.shi@linaro.org>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <56969363.9010007@linaro.org>
Date: Wed, 13 Jan 2016 10:11:47 -0800
MIME-Version: 1.0
In-Reply-To: <1449696151-4195-4-git-send-email-yang.shi@linaro.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

Hi folks,

Any comment for this one? The tracing part review has been done.

Thanks,
Yang


On 12/9/2015 1:22 PM, Yang Shi wrote:
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---
>   arch/x86/mm/gup.c | 6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> index ae9a37b..df5f3ab 100644
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -12,6 +12,8 @@
>
>   #include <asm/pgtable.h>
>
> +#include <trace/events/gup.h>
> +
>   static inline pte_t gup_get_pte(pte_t *ptep)
>   {
>   #ifndef CONFIG_X86_PAE
> @@ -270,6 +272,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   					(void __user *)start, len)))
>   		return 0;
>
> +	trace_gup_get_user_pages_fast(start, nr_pages);
> +
>   	/*
>   	 * XXX: batch / limit 'nr', to avoid large irq off latency
>   	 * needs some instrumenting to determine the common sizes used by
> @@ -373,6 +377,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   	} while (pgdp++, addr = next, addr != end);
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
