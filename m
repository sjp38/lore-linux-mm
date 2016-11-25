Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4918C6B0261
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 02:35:49 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id 50so65669815uae.7
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 23:35:49 -0800 (PST)
Received: from mail-ua0-x243.google.com (mail-ua0-x243.google.com. [2607:f8b0:400c:c08::243])
        by mx.google.com with ESMTPS id z23si5576513vkd.167.2016.11.24.23.35.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 23:35:48 -0800 (PST)
Received: by mail-ua0-x243.google.com with SMTP id 20so3111751uak.0
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 23:35:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161124163158.3939337-1-arnd@arndb.de>
References: <20161124163158.3939337-1-arnd@arndb.de>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Fri, 25 Nov 2016 08:35:47 +0100
Message-ID: <CAMJBoFPTTTKCNYDH+HkFz_7PykMSKvh1HgtvUOR2u29cjb2fgA@mail.gmail.com>
Subject: Re: [PATCH] z3fold: use %z modifier for format string
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>, zhong jiang <zhongjiang@huawei.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Arnd,

On Thu, Nov 24, 2016 at 5:31 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> Printing a size_t requires the %zd format rather than %d:
>
> mm/z3fold.c: In function =E2=80=98init_z3fold=E2=80=99:
> include/linux/kern_levels.h:4:18: error: format =E2=80=98%d=E2=80=99 expe=
cts argument of type =E2=80=98int=E2=80=99, but argument 2 has type =E2=80=
=98long unsigned int=E2=80=99 [-Werror=3Dformat=3D]
>
> Fixes: 50a50d2676c4 ("z3fold: don't fail kernel build if z3fold_header is=
 too big")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Vitaly Wool <vitalywool@gmail.com>

And thanks :)

~vitaly

> ---
>  mm/z3fold.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index e282ba073e77..66ac7a7dc934 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -884,7 +884,7 @@ static int __init init_z3fold(void)
>  {
>         /* Fail the initialization if z3fold header won't fit in one chun=
k */
>         if (sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED) {
> -               pr_err("z3fold: z3fold_header size (%d) is bigger than "
> +               pr_err("z3fold: z3fold_header size (%zd) is bigger than "
>                         "the chunk size (%d), can't proceed\n",
>                         sizeof(struct z3fold_header) , ZHDR_SIZE_ALIGNED)=
;
>                 return -E2BIG;
> --
> 2.9.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
