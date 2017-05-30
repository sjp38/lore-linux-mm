Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 355796B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 19:19:38 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id c1so111420lfe.7
        for <linux-mm@kvack.org>; Tue, 30 May 2017 16:19:38 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id 18si8418741ljp.24.2017.05.30.16.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 16:19:36 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id m18so33416lfj.0
        for <linux-mm@kvack.org>; Tue, 30 May 2017 16:19:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2345aabc-ae98-1d31-afba-40a02c5baf3d@users.sourceforge.net>
References: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net> <2345aabc-ae98-1d31-afba-40a02c5baf3d@users.sourceforge.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 30 May 2017 19:18:55 -0400
Message-ID: <CALZtONC5Jb15itFG-zxDC317oqdKGosp=44c=hpsEdaoYLmmUg@mail.gmail.com>
Subject: Re: [PATCH 1/3] zswap: Delete an error message for a failed memory
 allocation in zswap_pool_create()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjenning@redhat.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

On Sun, May 21, 2017 at 4:25 AM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 20 May 2017 22:33:21 +0200
>
> Omit an extra message for a memory allocation failure in this function.
>
> This issue was detected by using the Coccinelle software.
>
> Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Acked-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/zswap.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index eedc27894b10..18d8e87119a6 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -518,7 +518,5 @@ static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
> -       if (!pool) {
> -               pr_err("pool alloc failed\n");
> +       if (!pool)
>                 return NULL;
> -       }
>
>         /* unique name for each pool specifically required by zsmalloc */
>         snprintf(name, 38, "zswap%x", atomic_inc_return(&zswap_pools_count));
> --
> 2.13.0
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
