Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 759D96B0006
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 12:59:49 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w125so2365793itf.0
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 09:59:49 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f138si164753iof.226.2018.02.21.09.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 09:59:48 -0800 (PST)
Subject: Re: [PATCH 5/6] mm, hugetlb: further simplify hugetlb allocation API
References: <20180103093213.26329-1-mhocko@kernel.org>
 <20180103093213.26329-6-mhocko@kernel.org>
 <20180221042457.uolmhlmv5je5dqx7@xps> <20180221095526.GB2231@dhcp22.suse.cz>
 <20180221100107.GC2231@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <840f8c4f-0994-fa7d-0b8d-ad2c8d77c67d@oracle.com>
Date: Wed, 21 Feb 2018 09:59:40 -0800
MIME-Version: 1.0
In-Reply-To: <20180221100107.GC2231@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dan Rue <dan.rue@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On 02/21/2018 02:01 AM, Michal Hocko wrote:
> On Wed 21-02-18 10:55:26, Michal Hocko wrote:
> Hmm, I guess I can see it. Does the following help?
> ---
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7c204e3d132b..a963f2034dfc 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1583,7 +1583,7 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
>  		page = NULL;
>  	} else {
>  		h->surplus_huge_pages++;
> -		h->nr_huge_pages_node[page_to_nid(page)]++;
> +		h->surplus_huge_pages_node[page_to_nid(page)]++;
>  	}
>  
>  out_unlock:

I thought we had this corrected in a previous version of the patch.
My apologies for not looking more closely at this version.

FWIW,
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
