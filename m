Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 81BCF6B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 03:12:54 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fb1so6667792pad.31
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 00:12:54 -0800 (PST)
Received: from psmtp.com ([74.125.245.195])
        by mx.google.com with SMTP id hb3si10167363pac.181.2013.11.04.00.12.52
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 00:12:53 -0800 (PST)
Received: by mail-qc0-f178.google.com with SMTP id x19so3787444qcw.9
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 00:12:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1383223953-28803-1-git-send-email-zwu.kernel@gmail.com>
References: <1383223953-28803-1-git-send-email-zwu.kernel@gmail.com>
Date: Mon, 4 Nov 2013 16:12:51 +0800
Message-ID: <CAEH94LiCWH3EKohx7FqY9C10mB=ocjEkJt9ZBeX1X15XOoMCrQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: fix the incorrect function name in alloc_low_pages()
From: Zhi Yong Wu <zwu.kernel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel mlist <linux-kernel@vger.kernel.org>, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>, akpm@linux-foundation.org

CCed Andrew Morton

On Thu, Oct 31, 2013 at 8:52 PM, Zhi Yong Wu <zwu.kernel@gmail.com> wrote:
> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> ---
>  arch/x86/mm/init.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
> index 04664cd..64d860f 100644
> --- a/arch/x86/mm/init.c
> +++ b/arch/x86/mm/init.c
> @@ -53,12 +53,12 @@ __ref void *alloc_low_pages(unsigned int num)
>         if ((pgt_buf_end + num) > pgt_buf_top || !can_use_brk_pgt) {
>                 unsigned long ret;
>                 if (min_pfn_mapped >= max_pfn_mapped)
> -                       panic("alloc_low_page: ran out of memory");
> +                       panic("alloc_low_pages: ran out of memory");
>                 ret = memblock_find_in_range(min_pfn_mapped << PAGE_SHIFT,
>                                         max_pfn_mapped << PAGE_SHIFT,
>                                         PAGE_SIZE * num , PAGE_SIZE);
>                 if (!ret)
> -                       panic("alloc_low_page: can not alloc memory");
> +                       panic("alloc_low_pages: can not alloc memory");
>                 memblock_reserve(ret, PAGE_SIZE * num);
>                 pfn = ret >> PAGE_SHIFT;
>         } else {
> --
> 1.7.11.7
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Regards,

Zhi Yong Wu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
