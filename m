Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0016B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 07:19:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f23so45980399pgn.15
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 04:19:54 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id d185si374341pfc.533.2017.08.16.04.19.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 04:19:53 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id t86so1118463pfe.1
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 04:19:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <81cdf225-ebaa-19dc-30d8-80ec6cfab6cd@users.sourceforge.net>
References: <0fec59a9-ac68-33f6-533a-adfb5fa3c380@users.sourceforge.net> <81cdf225-ebaa-19dc-30d8-80ec6cfab6cd@users.sourceforge.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 16 Aug 2017 07:19:12 -0400
Message-ID: <CALZtONACUD_EjnBh71accGgLZ+aH44pORv7aBpVDYPgZsBgyow@mail.gmail.com>
Subject: Re: [PATCH 1/2] zpool: Delete an error message for a failed memory
 allocation in zpool_create_pool()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

On Mon, Aug 14, 2017 at 7:15 AM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 14 Aug 2017 12:57:16 +0200
>
> Omit an extra message for a memory allocation failure in this function.
>
> This issue was detected by using the Coccinelle software.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Acked-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/zpool.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/mm/zpool.c b/mm/zpool.c
> index fd3ff719c32c..fe1943f7d844 100644
> --- a/mm/zpool.c
> +++ b/mm/zpool.c
> @@ -172,7 +172,6 @@ struct zpool *zpool_create_pool(const char *type, const char *name, gfp_t gfp,
>
>         zpool = kmalloc(sizeof(*zpool), gfp);
>         if (!zpool) {
> -               pr_err("couldn't create zpool - out of memory\n");
>                 zpool_put_driver(driver);
>                 return NULL;
>         }
> --
> 2.14.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
