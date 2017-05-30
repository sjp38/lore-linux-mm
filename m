Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6B46B02C3
	for <linux-mm@kvack.org>; Tue, 30 May 2017 19:20:15 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o139so51576lfe.15
        for <linux-mm@kvack.org>; Tue, 30 May 2017 16:20:15 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id y24si8541261ljd.79.2017.05.30.16.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 16:20:13 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id m18so33948lfj.0
        for <linux-mm@kvack.org>; Tue, 30 May 2017 16:20:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <19f9da22-092b-f867-bdf6-f4dbad7ccf1f@users.sourceforge.net>
References: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net> <19f9da22-092b-f867-bdf6-f4dbad7ccf1f@users.sourceforge.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 30 May 2017 19:19:33 -0400
Message-ID: <CALZtOND7iFpCHQJPGpH21p+N5dcHiVM29ij=DTvJC33U9176=w@mail.gmail.com>
Subject: Re: [PATCH 2/3] zswap: Improve a size determination in zswap_frontswap_init()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjenning@redhat.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

On Sun, May 21, 2017 at 4:26 AM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 20 May 2017 22:44:03 +0200
>
> Replace the specification of a data structure by a pointer dereference
> as the parameter for the operator "sizeof" to make the corresponding size
> determination a bit safer according to the Linux coding style convention.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Acked-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/zswap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 18d8e87119a6..a6e67633be03 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -1156,5 +1156,5 @@ static void zswap_frontswap_init(unsigned type)
>  {
>         struct zswap_tree *tree;
>
> -       tree = kzalloc(sizeof(struct zswap_tree), GFP_KERNEL);
> +       tree = kzalloc(sizeof(*tree), GFP_KERNEL);
>         if (!tree) {
> --
> 2.13.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
