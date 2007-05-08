Message-ID: <46405C92.1080003@shadowen.org>
Date: Tue, 08 May 2007 12:18:42 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [KJ PATCH] Replacing memset(<addr>,0,PAGE_SIZE) with clear_page()
 in mm/memory.c
References: <1178621156.3598.10.camel@shani-win>
In-Reply-To: <1178621156.3598.10.camel@shani-win>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shani Moideen <shani.moideen@wipro.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@lists.osdl.org
List-ID: <linux-mm.kvack.org>

Shani Moideen wrote:
> Hi,
> 
> Replacing memset(<addr>,0,PAGE_SIZE) with clear_page() in mm/memory.c.
> 
> Signed-off-by: Shani Moideen <shani.moideen@wipro.com>
> ----
> 
> thanks.
> 
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e7066e7..2780d07 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1505,7 +1505,7 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
>                  * zeroes.
>                  */
>                 if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
> -                       memset(kaddr, 0, PAGE_SIZE);
> +                       clear_page(kaddr);
>                 kunmap_atomic(kaddr, KM_USER0);
>                 flush_dcache_page(dst);
>                 return;
> 
> 

This looks to be whitespace dammaged?

-apw

use tabs not spaces
PATCH: -:64:
FILE: b/mm/memory.c:1508:
+                       clear_page(kaddr);$

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
