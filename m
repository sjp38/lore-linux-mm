Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7179E6B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 02:28:06 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u203so136465726itc.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 23:28:06 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id b74si16385147itb.95.2016.06.06.23.28.04
        for <linux-mm@kvack.org>;
        Mon, 06 Jun 2016 23:28:06 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1465235131-6112-1-git-send-email-mike.kravetz@oracle.com> <1465235131-6112-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1465235131-6112-4-git-send-email-mike.kravetz@oracle.com>
Subject: Re: [RFC PATCH 3/6] mm/userfaultfd: add __mcopy_atomic_hugetlb for huge page UFFDIO_COPY
Date: Tue, 07 Jun 2016 14:27:48 +0800
Message-ID: <01ad01d1c085$b61fdd60$225f9820$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: 'Andrea Arcangeli' <aarcange@redhat.com>, 'Hugh Dickins' <hughd@google.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'Michal Hocko' <mhocko@suse.com>, 'Andrew Morton' <akpm@linux-foundation.org>

> @@ -182,6 +354,13 @@ retry:
>  		goto out_unlock;
> 
>  	/*
> +	 * If this is a HUGETLB vma, pass off to appropriate routine
> +	 */
> +	if (dst_vma->vm_flags & VM_HUGETLB)

Use is_vm_hugetlb_page()?
And in cases in subsequent patches?

Hillf
> +		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
> +						src_start, len, false);
> +
> +	/*
>  	 * Be strict and only allow __mcopy_atomic on userfaultfd
>  	 * registered ranges to prevent userland errors going
>  	 * unnoticed. As far as the VM consistency is concerned, it
> --
> 2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
