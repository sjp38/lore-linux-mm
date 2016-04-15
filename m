Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 545EF6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 12:26:49 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l15so72228584lfg.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:26:49 -0700 (PDT)
Received: from mail-lf0-x235.google.com (mail-lf0-x235.google.com. [2a00:1450:4010:c07::235])
        by mx.google.com with ESMTPS id a66si2108034lfe.171.2016.04.15.09.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 09:26:48 -0700 (PDT)
Received: by mail-lf0-x235.google.com with SMTP id c126so151580397lfb.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:26:47 -0700 (PDT)
Subject: Re: [PATCH v2] lib/stackdepot.c: allow the stack trace hash to be
 zero
References: <1460549245-131634-1-git-send-email-glider@google.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <5711165F.5080304@gmail.com>
Date: Fri, 15 Apr 2016 19:27:11 +0300
MIME-Version: 1.0
In-Reply-To: <1460549245-131634-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, dvyukov@google.com, cl@linux.com, akpm@linux-foundation.org, kcc@google.com, iamjoonsoo.kim@lge.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 04/13/2016 03:07 PM, Alexander Potapenko wrote:
> Do not bail out from depot_save_stack() if the stack trace has zero hash.
> Initially depot_save_stack() silently dropped stack traces with zero
> hashes, however there's actually no point in reserving this zero value.
> 
> Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Alexander Potapenko <glider@google.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

> ---
>  lib/stackdepot.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/lib/stackdepot.c b/lib/stackdepot.c
> index 654c9d8..9e0b031 100644
> --- a/lib/stackdepot.c
> +++ b/lib/stackdepot.c
> @@ -210,10 +210,6 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
>  		goto fast_exit;
>  
>  	hash = hash_stack(trace->entries, trace->nr_entries);
> -	/* Bad luck, we won't store this stack. */
> -	if (hash == 0)
> -		goto exit;
> -
>  	bucket = &stack_table[hash & STACK_HASH_MASK];
>  
>  	/*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
