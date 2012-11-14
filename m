Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id EFDEE6B006C
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 19:28:52 -0500 (EST)
Message-ID: <50A2E55B.20801@intel.com>
Date: Wed, 14 Nov 2012 08:27:07 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86/tlb: correct vmflag test for checking VM_HUGETLB
References: <1352740656-19417-1-git-send-email-js1304@gmail.com>
In-Reply-To: <1352740656-19417-1-git-send-email-js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

On 11/13/2012 01:17 AM, Joonsoo Kim wrote:
> commit 611ae8e3f5204f7480b3b405993b3352cfa16662('enable tlb flush range
> support for x86') change flush_tlb_mm_range() considerably. After this,
> we test whether vmflag equal to VM_HUGETLB and it may be always failed,
> because vmflag usually has other flags simultaneously.
> Our intention is to check whether this vma is for hughtlb, so correct it
> according to this purpose.
> 
> Cc: Alex Shi <alex.shi@intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> 

Acked-by: Alex Shi <alex.shi@intel.com>

> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index 0777f04..60f926c 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -197,7 +197,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>  	}
>  
>  	if (end == TLB_FLUSH_ALL || tlb_flushall_shift == -1
> -					|| vmflag == VM_HUGETLB) {
> +					|| vmflag & VM_HUGETLB) {
>  		local_flush_tlb();
>  		goto flush_all;
>  	}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
