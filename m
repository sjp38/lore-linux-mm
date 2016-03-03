Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 916E5828E5
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:55:02 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p65so26258325wmp.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:55:02 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id wf8si35637800wjb.122.2016.03.03.02.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 02:55:01 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id p65so28928578wmp.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:55:01 -0800 (PST)
Date: Thu, 3 Mar 2016 13:54:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/hugetlb: use EOPNOTSUPP in hugetlb sysctl handlers
Message-ID: <20160303105459.GD30948@node.shutemov.name>
References: <bdc32a3ce19bd1fa232852d179a6af958778c2c0.1456999026.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bdc32a3ce19bd1fa232852d179a6af958778c2c0.1456999026.git.jstancek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, paul.gortmaker@windriver.com

On Thu, Mar 03, 2016 at 11:02:51AM +0100, Jan Stancek wrote:
> Replace ENOTSUPP with EOPNOTSUPP. If hugepages are not supported,
> this value is propagated to userspace. EOPNOTSUPP is part of uapi
> and is widely supported by libc libraries.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> ---
>  mm/hugetlb.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 01f2b48c8618..851a29928a99 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2751,7 +2751,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
>  	int ret;
>  
>  	if (!hugepages_supported())
> -		return -ENOTSUPP;
> +		return -EOPNOTSUPP;
>  
>  	table->data = &tmp;
>  	table->maxlen = sizeof(unsigned long);
> @@ -2792,7 +2792,7 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
>  	int ret;
>  
>  	if (!hugepages_supported())
> -		return -ENOTSUPP;
> +		return -EOPNOTSUPP;
>  
>  	tmp = h->nr_overcommit_huge_pages;
>  
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
