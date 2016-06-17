Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A92126B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:01:34 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x6so133972482oif.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:01:34 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id f63si6070728oib.164.2016.06.17.05.01.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 05:01:34 -0700 (PDT)
Message-ID: <5763E694.1050502@huawei.com>
Date: Fri, 17 Jun 2016 20:01:24 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix account pmd page to the process
References: <1466163941-12952-1-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1466163941-12952-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, kirill.shutemov@linux.intel.com
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/6/17 19:45, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
>
> hen a process acquire a pmd table shared by other process, we
> increase the account to current process. otherwise, a race result
> in other tasks have set the pud entry. so it no need to increase it.
>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/hugetlb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 19d0d08..3072857 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4191,7 +4191,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  				(pmd_t *)((unsigned long)spte & PAGE_MASK));
>  	} else {
>  		put_page(virt_to_page(spte));
> -		mm_inc_nr_pmds(mm);
> +		mm_dec_nr_pmds(mm);
>  	}
>  	spin_unlock(ptl);
>  out:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
