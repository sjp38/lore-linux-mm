Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F0C386B00B3
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 18:08:00 -0500 (EST)
Date: Tue, 22 Nov 2011 15:07:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v2 3/4]thp: add tlb_remove_pmd_tlb_entry
Message-Id: <20111122150758.b05d90d9.akpm@linux-foundation.org>
In-Reply-To: <1321340658.22361.296.camel@sli10-conroe>
References: <1321340658.22361.296.camel@sli10-conroe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, 15 Nov 2011 15:04:18 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> --- linux.orig/include/asm-generic/tlb.h	2011-11-15 09:39:11.000000000 +0800
> +++ linux/include/asm-generic/tlb.h	2011-11-15 09:39:23.000000000 +0800
> @@ -139,6 +139,20 @@ static inline void tlb_remove_page(struc
>  		__tlb_remove_tlb_entry(tlb, ptep, address);	\
>  	} while (0)
>  
> +/**
> + * tlb_remove_pmd_tlb_entry - remember a pmd mapping for later tlb invalidation
> + * This is a nop so far, because only x86 needs it.
> + */
> +#ifndef __tlb_remove_pmd_tlb_entry
> +#define __tlb_remove_pmd_tlb_entry(tlb, pmdp, address) do {} while (0)
> +#endif
> +
> +#define tlb_remove_pmd_tlb_entry(tlb, pmdp, address)		\
> +	do {							\
> +		tlb->need_flush = 1;				\
> +		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);	\
> +	} while (0)
> +

Is there any reason why we cannot implement tlb_remove_pmd_tlb_entry()
as a nice, typesafe C function?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
