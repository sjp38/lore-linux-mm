Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 097496B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 11:06:40 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so17867366wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:06:39 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id og6si3744310wic.45.2015.08.25.08.06.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 08:06:36 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so18061267wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:06:35 -0700 (PDT)
Date: Tue, 25 Aug 2015 17:06:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] Documentation: clarify in calculating zone protection
Message-ID: <20150825150633.GG6285@dhcp22.suse.cz>
References: <1440511291-3990-1-git-send-email-bywxiaobai@163.com>
 <1440511291-3990-2-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440511291-3990-2-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 25-08-15 22:01:31, Yaowei Bai wrote:
> Every zone's protection is calculated from managed_pages not
> present_pages, to avoid misleading, correct it.

This can be folded in to your previous patch
http://marc.info/?l=linux-mm&m=144023106610358&w=2

> 
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
> ---
>  Documentation/sysctl/vm.txt | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 9832ec5..1739b31 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -349,7 +349,7 @@ zone[i]'s protection[j] is calculated by following expression.
>  
>  (i < j):
>    zone[i]->protection[j]
> -  = (total sums of present_pages from zone[i+1] to zone[j] on the node)
> +  = (total sums of managed_pages from zone[i+1] to zone[j] on the node)
>      / lowmem_reserve_ratio[i];
>  (i = j):
>     (should not be protected. = 0;
> @@ -360,7 +360,7 @@ The default values of lowmem_reserve_ratio[i] are
>      256 (if zone[i] means DMA or DMA32 zone)
>      32  (others).
>  As above expression, they are reciprocal number of ratio.
> -256 means 1/256. # of protection pages becomes about "0.39%" of total present
> +256 means 1/256. # of protection pages becomes about "0.39%" of total managed
>  pages of higher zones on the node.
>  
>  If you would like to protect more pages, smaller values are effective.
> -- 
> 1.9.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
