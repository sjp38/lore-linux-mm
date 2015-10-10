Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 37AFC6B0038
	for <linux-mm@kvack.org>; Sat, 10 Oct 2015 06:15:01 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so51217578pab.2
        for <linux-mm@kvack.org>; Sat, 10 Oct 2015 03:15:01 -0700 (PDT)
Received: from out11.biz.mail.alibaba.com (out114-135.biz.mail.alibaba.com. [205.204.114.135])
        by mx.google.com with ESMTP id sg10si9471035pac.170.2015.10.10.03.14.58
        for <linux-mm@kvack.org>;
        Sat, 10 Oct 2015 03:15:00 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <079201d10342$ce509f10$6af1dd30$@alibaba-inc.com>
In-Reply-To: <079201d10342$ce509f10$6af1dd30$@alibaba-inc.com>
Subject: Re: [PATCH v2 08/20] hugetlb: fix compile error on tile
Date: Sat, 10 Oct 2015 18:14:45 +0800
Message-ID: <079501d10344$7d0e6590$772b30b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dan Williams' <dan.j.williams@intel.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> Inlude asm/pgtable.h to get the definition for pud_t to fix:
> 
> include/linux/hugetlb.h:203:29: error: unknown type name 'pud_t'
> 
But that type is already used in 4.3-rc4

117 struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
118				pud_t *pud, int flags);

> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/hugetlb.h |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 5e35379f58a5..ad5539cf52bf 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -8,6 +8,7 @@
>  #include <linux/cgroup.h>
>  #include <linux/list.h>
>  #include <linux/kref.h>
> +#include <asm/pgtable.h>
> 
>  struct ctl_table;
>  struct user_struct;
> 
> --
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
