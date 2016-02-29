Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f54.google.com (mail-lf0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 77FE96B0253
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 11:31:37 -0500 (EST)
Received: by mail-lf0-f54.google.com with SMTP id v124so1952649lff.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:31:37 -0800 (PST)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com. [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id t68si12801689lfd.55.2016.02.29.08.31.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 08:31:36 -0800 (PST)
Received: by mail-lb0-x22b.google.com with SMTP id x1so83120322lbj.3
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:31:36 -0800 (PST)
Subject: Re: [PATCH v4 6/7] kasan: Test fix: Warn if the UAF could not be
 detected in kmalloc_uaf2
References: <cover.1456504662.git.glider@google.com>
 <9d9de65bc0661ccb4a663a4b59c0bb096e642cde.1456504662.git.glider@google.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <56D47267.5070308@gmail.com>
Date: Mon, 29 Feb 2016 19:31:35 +0300
MIME-Version: 1.0
In-Reply-To: <9d9de65bc0661ccb4a663a4b59c0bb096e642cde.1456504662.git.glider@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 02/26/2016 07:48 PM, Alexander Potapenko wrote:
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
>  lib/test_kasan.c | 2 ++
>  1 file changed, 2 insertions(+)
> 

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

> diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> index 90ad74f..82169fb 100644
> --- a/lib/test_kasan.c
> +++ b/lib/test_kasan.c
> @@ -294,6 +294,8 @@ static noinline void __init kmalloc_uaf2(void)
>  	}
>  
>  	ptr1[40] = 'x';
> +	if (ptr1 == ptr2)
> +		pr_err("Could not detect use-after-free: ptr1 == ptr2\n");
>  	kfree(ptr2);
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
