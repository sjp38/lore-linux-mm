Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D72236B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:20:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f6-v6so1012813eds.6
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:20:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u17-v6si1190831edf.182.2018.07.03.07.20.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 07:20:58 -0700 (PDT)
Date: Tue, 3 Jul 2018 16:20:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] m68k/page_no.h: force __va argument to be unsigned
 long
Message-ID: <20180703142054.GL16767@dhcp22.suse.cz>
References: <1530613795-6956-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530613795-6956-3-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530613795-6956-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 03-07-18 13:29:54, Mike Rapoport wrote:
> Add explicit casting to unsigned long to the __va() parameter

Why is this needed?

> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  arch/m68k/include/asm/page_no.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/m68k/include/asm/page_no.h b/arch/m68k/include/asm/page_no.h
> index e644c4d..6bbe520 100644
> --- a/arch/m68k/include/asm/page_no.h
> +++ b/arch/m68k/include/asm/page_no.h
> @@ -18,7 +18,7 @@ extern unsigned long memory_end;
>  #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
>  
>  #define __pa(vaddr)		((unsigned long)(vaddr))
> -#define __va(paddr)		((void *)(paddr))
> +#define __va(paddr)		((void *)((unsigned long)(paddr)))
>  
>  #define virt_to_pfn(kaddr)	(__pa(kaddr) >> PAGE_SHIFT)
>  #define pfn_to_virt(pfn)	__va((pfn) << PAGE_SHIFT)
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
