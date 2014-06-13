Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9336B009C
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 02:57:02 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id y10so2300730wgg.32
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 23:57:01 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id r4si518371wif.99.2014.06.12.23.57.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 23:57:00 -0700 (PDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so309330wib.9
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 23:57:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5399A360.3060309@oracle.com>
References: <5399A360.3060309@oracle.com>
Date: Fri, 13 Jun 2014 09:57:00 +0300
Message-ID: <CAOJsxLFyNZ9dc5T7282eqsg6gPtST75_h-5iGLX=t6OsWAPSCw@mail.gmail.com>
Subject: Re: [PATCH] slub: correct return errno on slab_sysfs_init failure
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jun 12, 2014 at 3:56 PM, Jeff Liu <jeff.liu@oracle.com> wrote:
> From: Jie Liu <jeff.liu@oracle.com>
>
> Return ENOMEM instead of ENOSYS if slab_sysfs_init() failed
>
> Signed-off-by: Jie Liu <jeff.liu@oracle.com>
> ---
>  mm/slub.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 2b1ce69..75ca109 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -5304,7 +5304,7 @@ static int __init slab_sysfs_init(void)
>         if (!slab_kset) {
>                 mutex_unlock(&slab_mutex);
>                 printk(KERN_ERR "Cannot register slab subsystem.\n");
> -               return -ENOSYS;
> +               return -ENOMEM;

What is the motivation for this change? AFAICT, kset_create_and_add()
can fail for other reasons than ENOMEM, no?

>         }
>
>         slab_state = FULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
