Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 953346B0260
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 09:47:33 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g127so157618339ith.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 06:47:33 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0121.outbound.protection.outlook.com. [104.47.2.121])
        by mx.google.com with ESMTPS id c20si2297600ote.150.2016.06.30.06.47.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Jun 2016 06:47:32 -0700 (PDT)
Subject: Re: [PATCH] kasan: add newline to messages
References: <1467294357-98002-1-git-send-email-dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5775232B.2070607@virtuozzo.com>
Date: Thu, 30 Jun 2016 16:48:27 +0300
MIME-Version: 1.0
In-Reply-To: <1467294357-98002-1-git-send-email-dvyukov@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, akpm@linux-foundation.org, glider@google.com, kasan-dev@googlegroups.com, linux-mm@kvack.org



On 06/30/2016 04:45 PM, Dmitry Vyukov wrote:
> Currently GPF messages with KASAN look as follows:
> kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> Add newlines.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

> ---
>  arch/x86/mm/kasan_init_64.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
> index 1b1110f..0493c17 100644
> --- a/arch/x86/mm/kasan_init_64.c
> +++ b/arch/x86/mm/kasan_init_64.c
> @@ -54,8 +54,8 @@ static int kasan_die_handler(struct notifier_block *self,
>  			     void *data)
>  {
>  	if (val == DIE_GPF) {
> -		pr_emerg("CONFIG_KASAN_INLINE enabled");
> -		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access");
> +		pr_emerg("CONFIG_KASAN_INLINE enabled\n");
> +		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access\n");
>  	}
>  	return NOTIFY_OK;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
