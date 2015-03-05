Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4FBB56B006E
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 11:48:56 -0500 (EST)
Received: by ierx19 with SMTP id x19so78136205ier.3
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 08:48:56 -0800 (PST)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id m1si15213881ige.61.2015.03.05.08.48.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 08:48:55 -0800 (PST)
Message-ID: <1425574096.17007.275.camel@misato.fc.hp.com>
Subject: Re: [PATCH mmotm] x86, mm: ioremap_pud_capable can be static
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 05 Mar 2015 09:48:16 -0700
In-Reply-To: <20150305123534.GA21563@snb>
References: <201503052019.YDsQ378S%fengguang.wu@intel.com>
	 <20150305123534.GA21563@snb>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu, 2015-03-05 at 20:35 +0800, kbuild test robot wrote:
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>

Thanks for the update!

Reviewed-by: Toshi Kani <toshi.kani@hp.com>

-Toshi


> ---
>  ioremap.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/lib/ioremap.c b/lib/ioremap.c
> index 3055ada..1634c53 100644
> --- a/lib/ioremap.c
> +++ b/lib/ioremap.c
> @@ -14,9 +14,9 @@
>  #include <asm/pgtable.h>
>  
>  #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
> -int __read_mostly ioremap_pud_capable;
> -int __read_mostly ioremap_pmd_capable;
> -int __read_mostly ioremap_huge_disabled;
> +static int __read_mostly ioremap_pud_capable;
> +static int __read_mostly ioremap_pmd_capable;
> +static int __read_mostly ioremap_huge_disabled;
>  
>  static int __init set_nohugeiomap(char *str)
>  {
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
