Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8586B02F3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 14:20:50 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id f102so5873347ioi.7
        for <linux-mm@kvack.org>; Wed, 10 May 2017 11:20:50 -0700 (PDT)
Received: from mail-it0-x22e.google.com (mail-it0-x22e.google.com. [2607:f8b0:4001:c0b::22e])
        by mx.google.com with ESMTPS id n62si4537007itc.124.2017.05.10.11.20.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 11:20:49 -0700 (PDT)
Received: by mail-it0-x22e.google.com with SMTP id o5so30259831ith.1
        for <linux-mm@kvack.org>; Wed, 10 May 2017 11:20:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170510174441.26163-1-danielmicay@gmail.com>
References: <20170510174441.26163-1-danielmicay@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 10 May 2017 11:20:47 -0700
Message-ID: <CAGXu5j+avp7VAEAhRCH2fyQdqJo_yM2xkwxVbcO0eXeSscNNLA@mail.gmail.com>
Subject: Re: [PATCH] mark protection_map as __ro_after_init
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 10, 2017 at 10:44 AM, Daniel Micay <danielmicay@gmail.com> wrote:
> The protection map is only modified by per-arch init code so it can be
> protected from writes after the init code runs.
>
> This change was extracted from PaX where it's part of KERNEXEC.
>
> Signed-off-by: Daniel Micay <danielmicay@gmail.com>

Thanks!

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  mm/mmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f82741e199c0..3bd5ecd20d4d 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -94,7 +94,7 @@ static void unmap_region(struct mm_struct *mm,
>   *                                                             w: (no) no
>   *                                                             x: (yes) yes
>   */
> -pgprot_t protection_map[16] = {
> +pgprot_t protection_map[16] __ro_after_init = {
>         __P000, __P001, __P010, __P011, __P100, __P101, __P110, __P111,
>         __S000, __S001, __S010, __S011, __S100, __S101, __S110, __S111
>  };
> --
> 2.12.2
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
