Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1526B0253
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 11:36:09 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id a143so33401650oii.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 08:36:09 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0142.outbound.protection.outlook.com. [157.56.112.142])
        by mx.google.com with ESMTPS id u11si9754895oib.78.2016.06.01.08.36.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 08:36:08 -0700 (PDT)
Subject: Re: [PATCH] kasan: change memory hot-add error messages to info
 messages
References: <1464794430-5486-1-git-send-email-shuahkh@osg.samsung.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <574F0112.1060006@virtuozzo.com>
Date: Wed, 1 Jun 2016 18:36:50 +0300
MIME-Version: 1.0
In-Reply-To: <1464794430-5486-1-git-send-email-shuahkh@osg.samsung.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuah Khan <shuahkh@osg.samsung.com>, glider@google.com, dvyukov@google.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>



On 06/01/2016 06:20 PM, Shuah Khan wrote:
> Change the following memory hot-add error messages to info messages. There
> is no need for these to be errors.
> 
> [    8.221108] kasan: WARNING: KASAN doesn't support memory hot-add
> [    8.221117] kasan: Memory hot-add will be disabled
> 
> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

> ---
> Note: This is applicable to 4.6 stable releases.
> 
>  mm/kasan/kasan.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 18b6a2b..28439ac 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -763,8 +763,8 @@ static int kasan_mem_notifier(struct notifier_block *nb,
>  
>  static int __init kasan_memhotplug_init(void)
>  {
> -	pr_err("WARNING: KASAN doesn't support memory hot-add\n");
> -	pr_err("Memory hot-add will be disabled\n");
> +	pr_info("WARNING: KASAN doesn't support memory hot-add\n");
> +	pr_info("Memory hot-add will be disabled\n");
>  
>  	hotplug_memory_notifier(kasan_mem_notifier, 0);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
