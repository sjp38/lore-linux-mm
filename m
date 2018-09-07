Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 867A26B7FA6
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 14:39:16 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id p4-v6so2774316yba.8
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 11:39:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r85-v6sor1759747ywg.333.2018.09.07.11.39.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 11:39:15 -0700 (PDT)
Date: Fri, 7 Sep 2018 14:39:12 -0400
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: Re: [RESEND PATCH] mm: percpu: remove unnecessary unlikely()
Message-ID: <20180907183909.GA84248@dennisz-mbp.dhcp.thefacebook.com>
References: <20180907181035.1662-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180907181035.1662-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Igor Stoppa <igor.stoppa@huawei.com>, zijun_hu <zijun_hu@htc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Igor,

On Fri, Sep 07, 2018 at 09:10:35PM +0300, Igor Stoppa wrote:
> WARN_ON() already contains an unlikely(), so it's not necessary to
> wrap it into another.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> Acked-by: Dennis Zhou <dennisszhou@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: zijun_hu <zijun_hu@htc.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/percpu.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index a749d4d96e3e..f5c2796fe63e 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -2588,7 +2588,7 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
>  	BUG_ON(ai->nr_groups != 1);
>  	upa = ai->alloc_size/ai->unit_size;
>  	nr_g0_units = roundup(num_possible_cpus(), upa);
> -	if (unlikely(WARN_ON(ai->groups[0].nr_units != nr_g0_units))) {
> +	if (WARN_ON(ai->groups[0].nr_units != nr_g0_units)) {
>  		pcpu_free_alloc_info(ai);
>  		return -EINVAL;
>  	}
> -- 
> 2.17.1
> 

Sorry for the delay. I'll be taking over the percpu tree and am in the
process of getting a tree. I'm still keeping track of this and will take
it for the next release.

Thanks,
Dennis
