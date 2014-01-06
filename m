Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3F56A6B0037
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 09:18:31 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id b57so7965472eek.12
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 06:18:30 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e48si84079980eeh.92.2014.01.06.06.18.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 06:18:30 -0800 (PST)
Date: Mon, 6 Jan 2014 15:18:27 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: could you clarify mm/mempolicy: fix !vma in new_vma_page()
Message-ID: <20140106141827.GB27602@dhcp22.suse.cz>
References: <20140106112422.GA27602@dhcp22.suse.cz>
 <CAA_GA1dNdrG9aQ3UKDA0O=BY721rvseORVkc2+RxUpzysp3rYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1dNdrG9aQ3UKDA0O=BY721rvseORVkc2+RxUpzysp3rYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bob Liu <bob.liu@oracle.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 06-01-14 20:45:54, Bob Liu wrote:
[...]
>  544         if (PageAnon(page)) {
>  545                 struct anon_vma *page__anon_vma = page_anon_vma(page);
>  546                 /*
>  547                  * Note: swapoff's unuse_vma() is more efficient with this
>  548                  * check, and needs it to match anon_vma when KSM is active.
>  549                  */
>  550                 if (!vma->anon_vma || !page__anon_vma ||
>  551                     vma->anon_vma->root != page__anon_vma->root)
>  552                         return -EFAULT;
>  553         } else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
>  554                 if (!vma->vm_file ||
>  555                     vma->vm_file->f_mapping != page->mapping)
>  556                         return -EFAULT;
>  557         } else
>  558                 return -EFAULT;
> 
> That's the "other conditions" and the reason why we can't use
> BUG_ON(!vma) in new_vma_page().

Sorry, I wasn't clear with my question. I was interested in which of
these triggered and why only for hugetlb pages?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
