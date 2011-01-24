Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 81C676B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 14:37:25 -0500 (EST)
Received: by ewy27 with SMTP id 27so2088112ewy.14
        for <linux-mm@kvack.org>; Mon, 24 Jan 2011 11:33:01 -0800 (PST)
Message-ID: <4D3DD366.8000704@mvista.com>
Date: Mon, 24 Jan 2011 22:30:46 +0300
From: Sergei Shtylyov <sshtylyov@mvista.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fix build error when CONFIG_SWAP is not set
References: <20110124210813.ba743fc5.yuasa@linux-mips.org>
In-Reply-To: <20110124210813.ba743fc5.yuasa@linux-mips.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Yoichi Yuasa <yuasa@linux-mips.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mips <linux-mips@linux-mips.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello.

Yoichi Yuasa wrote:

> In file included from
> linux-2.6/arch/mips/include/asm/tlb.h:21,
>                  from mm/pgtable-generic.c:9:
> include/asm-generic/tlb.h: In function 'tlb_flush_mmu':
> include/asm-generic/tlb.h:76: error: implicit declaration of function
> 'release_pages'
> include/asm-generic/tlb.h: In function 'tlb_remove_page':
> include/asm-generic/tlb.h:105: error: implicit declaration of function
> 'page_cache_release'
> make[1]: *** [mm/pgtable-generic.o] Error 1
> 
> Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>
[...]

> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 4d55932..92c1be6 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -8,6 +8,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/sched.h>
>  #include <linux/node.h>
> +#include <linux/pagemap.h>

    Hm, if the errors are in <asm-generic/tlb.h>, why add #include in 
<linux/swap.h>?

WBR. Sergei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
