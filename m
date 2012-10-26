Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id D01BA6B0073
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 10:50:06 -0400 (EDT)
Date: Fri, 26 Oct 2012 16:50:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugetlb: remove duplicated include from hugetlb.c
Message-ID: <20121026145001.GA902@dhcp22.suse.cz>
References: <CAPgLHd9zgUBU+aWLhiFW8t5Jx=xCFk8WZim0J9TgBqg83jznSQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPgLHd9zgUBU+aWLhiFW8t5Jx=xCFk8WZim0J9TgBqg83jznSQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Cc: linux-mm@kvack.org, yongjun_wei@trendmicro.com.cn

On Sun 26-08-12 09:34:31, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> To: linux-mm@kvack.org,
>     linux-kernel@vger.kernel.org
>

The above parts are not needed. Ideally use git send-email directly.
Also make sure you include subsystem maintainer into cc
(./scripts/get_maintainer.pl can help you with that).

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Remove duplicated include.

This has been already fixed and waiting in the mmotm tree.

> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  mm/hugetlb.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bc72712..5bf325b 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -30,7 +30,6 @@
>  #include <linux/hugetlb.h>
>  #include <linux/hugetlb_cgroup.h>
>  #include <linux/node.h>
> -#include <linux/hugetlb_cgroup.h>
>  #include "internal.h"
>  
>  const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
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
