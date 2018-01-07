Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF9456B027D
	for <linux-mm@kvack.org>; Sun,  7 Jan 2018 10:04:41 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id t94so4116554wrc.18
        for <linux-mm@kvack.org>; Sun, 07 Jan 2018 07:04:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q3sor4379801wrd.74.2018.01.07.07.04.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Jan 2018 07:04:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1514082821-24256-1-git-send-email-nick.desaulniers@gmail.com>
References: <1514082821-24256-1-git-send-email-nick.desaulniers@gmail.com>
From: Minchan Kim <minchan@kernel.org>
Date: Mon, 8 Jan 2018 00:04:38 +0900
Message-ID: <CAEwNFnC9FA44y1vCWmm=LEyQHjJC=Sd8GzbYgY6rS9h9i2HOiw@mail.gmail.com>
Subject: Re: [PATCH] zsmalloc: use U suffix for negative literals being shifted
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello,

Sorry for the delay. I have missed this until now. ;-(

On Sun, Dec 24, 2017 at 11:33 AM, Nick Desaulniers
<nick.desaulniers@gmail.com> wrote:
> Fixes warnings about shifting unsigned literals being undefined
> behavior.
>
> Signed-off-by: Nick Desaulniers <nick.desaulniers@gmail.com>
> ---
>  mm/zsmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 685049a..5d31458 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1056,7 +1056,7 @@ static void init_zspage(struct size_class *class, struct zspage *zspage)
>                          * Reset OBJ_TAG_BITS bit to last link to tell
>                          * whether it's allocated object or not.
>                          */
> -                       link->next = -1 << OBJ_TAG_BITS;
> +                       link->next = -1U << OBJ_TAG_BITS;

-1UL?

Please, resend it with including Andrew Morton
<akpm@linux-foundation.org> who merges zsmalloc patch into his tree.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
