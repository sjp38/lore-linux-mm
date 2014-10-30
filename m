Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id B768590008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 04:56:27 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id l4so3900558lbv.0
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 01:56:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tj1si10975901lbb.73.2014.10.30.01.56.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 01:56:26 -0700 (PDT)
Date: Thu, 30 Oct 2014 09:56:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm-cma-make-kmemleak-ignore-cma-regions-fix
Message-ID: <20141030085623.GC4664@dhcp22.suse.cz>
References: <54515a25.46WrYSce5BExT3V4%akpm@linux-foundation.org>
 <1414658824-16480-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1414658824-16480-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thierry Reding <treding@nvidia.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au

On Thu 30-10-14 09:47:04, Michal Hocko wrote:
> include linux/io.h to get phys_to_virt declaration and fix the following
> compile error:
> mm/cma.c:288:4: error: implicit declaration of function a??phys_to_virta?? [-Werror=implicit-function-declaration]
>     kmemleak_ignore(phys_to_virt(addr));

Ohh, skip this. It seems that this has been merged into
mm-cma-make-kmemleak-ignore-cma-regions.patch already. Just my scripts
haven't noticed.

Sorry about the noise.

> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/cma.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/cma.c b/mm/cma.c
> index 9bc687a20495..daec407d1057 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -33,6 +33,7 @@
>  #include <linux/log2.h>
>  #include <linux/cma.h>
>  #include <linux/highmem.h>
> +#include <linux/io.h>
>  
>  struct cma {
>  	unsigned long	base_pfn;
> -- 
> 2.1.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
