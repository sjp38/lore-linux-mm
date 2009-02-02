Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AF77B5F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 08:50:52 -0500 (EST)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id n12Dmlfp323700
	for <linux-mm@kvack.org>; Mon, 2 Feb 2009 13:48:47 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n12DmlpQ3444766
	for <linux-mm@kvack.org>; Mon, 2 Feb 2009 14:48:47 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n12DmlJD022528
	for <linux-mm@kvack.org>; Mon, 2 Feb 2009 14:48:47 +0100
Subject: Re: [PATCH -mmotm] mm: unify some pmd_*() functions fix
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <1233183874-26066-1-git-send-email-righi.andrea@gmail.com>
References: <1233183874-26066-1-git-send-email-righi.andrea@gmail.com>
Content-Type: text/plain
Date: Mon, 02 Feb 2009 14:48:46 +0100
Message-Id: <1233582526.18006.31.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <righi.andrea@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Roman Zippel <zippel@linux-m68k.org>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-01-29 at 00:04 +0100, Andrea Righi wrote:
> Also unify implementations of pmd_*() functions in arch/*.
> 
> This patch must be applied on top of mm-unify-some-pmd_-functions.patch.
> 
> Signed-off-by: Andrea Righi <righi.andrea@gmail.com>

> diff --git a/arch/s390/include/asm/pgalloc.h b/arch/s390/include/asm/pgalloc.h
> index b2658b9..6a85281 100644
> --- a/arch/s390/include/asm/pgalloc.h
> +++ b/arch/s390/include/asm/pgalloc.h
> @@ -63,8 +63,7 @@ static inline unsigned long pgd_entry_type(struct mm_struct *mm)
>  #define pud_alloc_one(mm,address)		({ BUG(); ((pud_t *)2); })
>  #define pud_free(mm, x)				do { } while (0)
> 
> -#define pmd_alloc_one(mm,address)		({ BUG(); ((pmd_t *)2); })
> -#define pmd_free(mm, x)				do { } while (0)
> +#define pmd_alloc_one	pmd_alloc_one_bug
> 
>  #define pgd_populate(mm, pgd, pud)		BUG()
>  #define pgd_populate_kernel(mm, pgd, pud)	BUG()

This does not compile for 32 bit s390. With the patches for 'dynamic
page tables' and '1K/2k page tables' I decided to get completely
independent from the nopmd/nopud #ifdef hell. The include files from
asm-generic are simply not used for s390. Please drop the above hunk
from your patch and leave s390 as it is.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
