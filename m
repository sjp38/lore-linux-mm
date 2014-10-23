Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 34C676B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 20:20:04 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id cs9so3246804qab.29
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 17:20:03 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id b10si367905qaw.76.2014.10.22.17.20.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 17:20:03 -0700 (PDT)
Received: by mail-qg0-f41.google.com with SMTP id a108so3452724qge.14
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 17:20:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1414022989-23035-1-git-send-email-gregory.0xf0@gmail.com>
References: <1414022989-23035-1-git-send-email-gregory.0xf0@gmail.com>
From: Gregory Fong <gregory.0xf0@gmail.com>
Date: Wed, 22 Oct 2014 17:19:33 -0700
Message-ID: <CADtm3G7UwHW34vP_067d7cZZ74bBGqtdHGZQjvO-0-gs-5YnRg@mail.gmail.com>
Subject: Re: [PATCH] mm: cma: Use %pa to avoid truncating the physical address
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kevin Cernekee <cernekee@gmail.com>, Gregory Fong <gregory.0xf0@gmail.com>, linux-mm@kvack.org

Replying to change to use the real linux-mm list on CC (sorry for the noise!)

On Wed, Oct 22, 2014 at 5:09 PM, Gregory Fong <gregory.0xf0@gmail.com> wrote:
> From: Kevin Cernekee <cernekee@gmail.com>
>
> Signed-off-by: Kevin Cernekee <cernekee@gmail.com>
> [gregory.0xf0@gmail.com: rebased from 3.14 and updated commit message]
> Signed-off-by: Gregory Fong <gregory.0xf0@gmail.com>
> ---
>  mm/cma.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index 963bc4a..154efb0 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -288,8 +288,8 @@ int __init cma_declare_contiguous(phys_addr_t base,
>         if (ret)
>                 goto err;
>
> -       pr_info("Reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
> -               (unsigned long)base);
> +       pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
> +               &base);
>         return 0;
>
>  err:
> --
> 1.9.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
