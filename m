Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 599426B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 20:39:06 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so3693895pad.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 17:39:06 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id pr4si3694969pdb.98.2015.08.27.17.39.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 17:39:05 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/2] module: export param_free_charp()
In-Reply-To: <1440613970-23913-2-git-send-email-ddstreet@ieee.org>
References: <1440613970-23913-1-git-send-email-ddstreet@ieee.org> <1440613970-23913-2-git-send-email-ddstreet@ieee.org>
Date: Thu, 27 Aug 2015 13:45:57 +0930
Message-ID: <876141icxu.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Dan Streetman <ddstreet@ieee.org> writes:
> Change the param_free_charp() function from static to exported.
>
> It is used by zswap in the next patch.
>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks!
Rusty.

> ---
>  include/linux/moduleparam.h | 1 +
>  kernel/params.c             | 3 ++-
>  2 files changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/moduleparam.h b/include/linux/moduleparam.h
> index c12f214..52666d9 100644
> --- a/include/linux/moduleparam.h
> +++ b/include/linux/moduleparam.h
> @@ -386,6 +386,7 @@ extern int param_get_ullong(char *buffer, const struct kernel_param *kp);
>  extern const struct kernel_param_ops param_ops_charp;
>  extern int param_set_charp(const char *val, const struct kernel_param *kp);
>  extern int param_get_charp(char *buffer, const struct kernel_param *kp);
> +extern void param_free_charp(void *arg);
>  #define param_check_charp(name, p) __param_check(name, p, char *)
>  
>  /* We used to allow int as well as bool.  We're taking that away! */
> diff --git a/kernel/params.c b/kernel/params.c
> index b6554aa..93a380a 100644
> --- a/kernel/params.c
> +++ b/kernel/params.c
> @@ -325,10 +325,11 @@ int param_get_charp(char *buffer, const struct kernel_param *kp)
>  }
>  EXPORT_SYMBOL(param_get_charp);
>  
> -static void param_free_charp(void *arg)
> +void param_free_charp(void *arg)
>  {
>  	maybe_kfree_parameter(*((char **)arg));
>  }
> +EXPORT_SYMBOL(param_free_charp);
>  
>  const struct kernel_param_ops param_ops_charp = {
>  	.set = param_set_charp,
> -- 
> 2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
