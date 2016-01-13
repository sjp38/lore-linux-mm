Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6BB05828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 13:12:27 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ho8so101324378pac.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 10:12:27 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id x14si3415540pfi.39.2016.01.13.10.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 10:12:26 -0800 (PST)
Received: by mail-pa0-x234.google.com with SMTP id cy9so362166688pac.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 10:12:26 -0800 (PST)
Subject: Re: [PATCH v5 5/7] s390: mm/gup: add gup trace points
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
 <1449696151-4195-6-git-send-email-yang.shi@linaro.org>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <56969389.9060703@linaro.org>
Date: Wed, 13 Jan 2016 10:12:25 -0800
MIME-Version: 1.0
In-Reply-To: <1449696151-4195-6-git-send-email-yang.shi@linaro.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

Hi folks,

Any comment for this one? The tracing part review has been done.

Thanks,
Yang


On 12/9/2015 1:22 PM, Yang Shi wrote:
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: linux-s390@vger.kernel.org
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---
>   arch/s390/mm/gup.c | 5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
> index 12bbf0e..a1d5db7 100644
> --- a/arch/s390/mm/gup.c
> +++ b/arch/s390/mm/gup.c
> @@ -12,6 +12,8 @@
>   #include <linux/rwsem.h>
>   #include <asm/pgtable.h>
>
> +#include <trace/events/gup.h>
> +
>   /*
>    * The performance critical leaf functions are made noinline otherwise gcc
>    * inlines everything into a single function which results in too much
> @@ -188,6 +190,9 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   	end = start + len;
>   	if ((end <= start) || (end > TASK_SIZE))
>   		return 0;
> +
> +	trace_gup_get_user_pages_fast(start, nr_pages);
> +
>   	/*
>   	 * local_irq_save() doesn't prevent pagetable teardown, but does
>   	 * prevent the pagetables from being freed on s390.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
