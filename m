Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0A06B02F3
	for <linux-mm@kvack.org>; Tue, 30 May 2017 19:20:42 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id r14so111417lfi.8
        for <linux-mm@kvack.org>; Tue, 30 May 2017 16:20:42 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id g83si9417208ljg.237.2017.05.30.16.20.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 16:20:41 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id m18so34304lfj.0
        for <linux-mm@kvack.org>; Tue, 30 May 2017 16:20:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <bae25b04-2ce2-7137-a71c-50d7b4f06431@users.sourceforge.net>
References: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net> <bae25b04-2ce2-7137-a71c-50d7b4f06431@users.sourceforge.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 30 May 2017 19:20:00 -0400
Message-ID: <CALZtONA5gyeqioF=F4BWpJ8T8-kc-BNsuas0gK4555GS-GkApQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] zswap: Delete an error message for a failed memory
 allocation in zswap_dstmem_prepare()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjenning@redhat.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

On Sun, May 21, 2017 at 4:27 AM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sun, 21 May 2017 09:29:25 +0200
>
> Omit an extra message for a memory allocation failure in this function.
>
> This issue was detected by using the Coccinelle software.
>
> Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Acked-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/zswap.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 3f0a9a1daef4..ed7312291df9 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -374,7 +374,6 @@ static int zswap_dstmem_prepare(unsigned int cpu)
> -       if (!dst) {
> -               pr_err("can't allocate compressor buffer\n");
> +       if (!dst)
>                 return -ENOMEM;
> -       }
> +
>         per_cpu(zswap_dstmem, cpu) = dst;
>         return 0;
>  }
> --
> 2.13.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
