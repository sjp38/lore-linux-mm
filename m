Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 398146B025E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 02:29:43 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id q92so114221387ioi.3
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 23:29:43 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id m125si40133175iof.41.2016.09.20.23.29.41
        for <linux-mm@kvack.org>;
        Tue, 20 Sep 2016 23:29:42 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com> <20160920155354.54403-2-gerald.schaefer@de.ibm.com>
In-Reply-To: <20160920155354.54403-2-gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH 1/1] mm/hugetlb: fix memory offline with hugepage size > memory block size
Date: Wed, 21 Sep 2016 14:29:25 +0800
Message-ID: <05d701d213d1$7fb70880$7f251980$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Gerald Schaefer' <gerald.schaefer@de.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Michal Hocko' <mhocko@suse.cz>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Mike Kravetz' <mike.kravetz@oracle.com>, "'Aneesh Kumar K . V'" <aneesh.kumar@linux.vnet.ibm.com>, 'Martin Schwidefsky' <schwidefsky@de.ibm.com>, 'Heiko Carstens' <heiko.carstens@de.ibm.com>

> @@ -1466,9 +1468,9 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  	if (!hugepages_supported())
>  		return;
> 
> -	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << minimum_order));

Then the relevant comment has to be updated.

Hillf
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order)
> -		dissolve_free_huge_page(pfn_to_page(pfn));
> +		if (PageHuge(pfn_to_page(pfn)))
> +			dissolve_free_huge_page(pfn_to_page(pfn));
>  }
> 
>  /*
> --
> 2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
