Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7346B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 12:35:22 -0400 (EDT)
Received: by qkap81 with SMTP id p81so20700525qka.2
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 09:35:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d93si13973238qkh.88.2015.09.10.09.35.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 09:35:21 -0700 (PDT)
Message-ID: <1441902919.18796.10.camel@redhat.com>
Subject: Re: [PATCH] mm/early_ioremap: add explicit #include of
 asm/early_ioremap.h
From: Mark Salter <msalter@redhat.com>
Date: Thu, 10 Sep 2015 12:35:19 -0400
In-Reply-To: <1441900848-18527-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1441900848-18527-1-git-send-email-ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On Thu, 2015-09-10 at 18:00 +0200, Ard Biesheuvel wrote:
> Commit 6b0f68e32ea8 ("mm: add utility for early copy from unmapped
> ram") introduces a function copy_from_early_mem() into mm/early_ioremap.c
> which itself calls early_memremap()/early_memunmap(). However, since
> early_memunmap() has not been declared yet at this point in the .c file,
> nor by any explicitly included header files, we are depending on a
> transitive include of asm/early_ioremap.h to declare it, which is fragile.
> 
> So instead, include this header explicitly.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---

Acked-by: Mark Salter <msalter@redhat.com>

> 
> I ran into this by accident when trying to enable to the generic ioremap
> implementation for 32-bit ARM.
> 
>  mm/early_ioremap.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
> index 23f744d77ce0..17ae14b5aefa 100644
> --- a/mm/early_ioremap.c
> +++ b/mm/early_ioremap.c
> @@ -15,6 +15,7 @@
>  #include <linux/mm.h>
>  #include <linux/vmalloc.h>
>  #include <asm/fixmap.h>
> +#include <asm/early_ioremap.h>
>  
>  #ifdef CONFIG_MMU
>  static int early_ioremap_debug __initdata;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
