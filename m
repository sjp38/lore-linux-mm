Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD0E6B0033
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 11:29:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id x7so9254069pfa.19
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 08:29:37 -0800 (PST)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTPS id t64si3081575pgc.821.2017.11.20.08.29.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 08:29:36 -0800 (PST)
Subject: Re: [PATCH 5/8] crypto: remove unused hardirq.h
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
 <1510959741-31109-5-git-send-email-yang.s@alibaba-inc.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <044a9f13-19ac-eee4-4baa-0e0b93ef20be@alibaba-inc.com>
Date: Tue, 21 Nov 2017 00:29:12 +0800
MIME-Version: 1.0
In-Reply-To: <1510959741-31109-5-git-send-email-yang.s@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>

The email to Herbert is returned, resent it.

Yang


On 11/17/17 3:02 PM, Yang Shi wrote:
> Preempt counter APIs have been split out, currently, hardirq.h just
> includes irq_enter/exit APIs which are not used by crypto at all.
> 
> So, remove the unused hardirq.h.
> 
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-crypto@vger.kernel.org
> ---
>   crypto/ablk_helper.c | 1 -
>   crypto/blkcipher.c   | 1 -
>   crypto/mcryptd.c     | 1 -
>   3 files changed, 3 deletions(-)
> 
> diff --git a/crypto/ablk_helper.c b/crypto/ablk_helper.c
> index 1441f07..ee52660 100644
> --- a/crypto/ablk_helper.c
> +++ b/crypto/ablk_helper.c
> @@ -28,7 +28,6 @@
>   #include <linux/crypto.h>
>   #include <linux/init.h>
>   #include <linux/module.h>
> -#include <linux/hardirq.h>
>   #include <crypto/algapi.h>
>   #include <crypto/cryptd.h>
>   #include <crypto/ablk_helper.h>
> diff --git a/crypto/blkcipher.c b/crypto/blkcipher.c
> index 6c43a0a..01c0d4a 100644
> --- a/crypto/blkcipher.c
> +++ b/crypto/blkcipher.c
> @@ -18,7 +18,6 @@
>   #include <crypto/internal/skcipher.h>
>   #include <crypto/scatterwalk.h>
>   #include <linux/errno.h>
> -#include <linux/hardirq.h>
>   #include <linux/kernel.h>
>   #include <linux/module.h>
>   #include <linux/seq_file.h>
> diff --git a/crypto/mcryptd.c b/crypto/mcryptd.c
> index 4e64726..9fa362c 100644
> --- a/crypto/mcryptd.c
> +++ b/crypto/mcryptd.c
> @@ -26,7 +26,6 @@
>   #include <linux/sched.h>
>   #include <linux/sched/stat.h>
>   #include <linux/slab.h>
> -#include <linux/hardirq.h>
>   
>   #define MCRYPTD_MAX_CPU_QLEN 100
>   #define MCRYPTD_BATCH 9
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
