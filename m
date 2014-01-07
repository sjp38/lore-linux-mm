Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD156B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 03:34:29 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so8233829eek.7
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 00:34:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h45si87829720eeo.172.2014.01.07.00.34.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 00:34:28 -0800 (PST)
Date: Tue, 7 Jan 2014 09:34:25 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: could you clarify mm/mempolicy: fix !vma in new_vma_page()
Message-ID: <20140107083425.GB8756@dhcp22.suse.cz>
References: <20140106112422.GA27602@dhcp22.suse.cz>
 <CAA_GA1dNdrG9aQ3UKDA0O=BY721rvseORVkc2+RxUpzysp3rYw@mail.gmail.com>
 <20140106141827.GB27602@dhcp22.suse.cz>
 <52cb81ed.e3d8420a.72a1.ffffea65SMTPIN_ADDED_BROKEN@mx.google.com>
 <52cb83e3.c9903c0a.614e.1751SMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52cb83e3.c9903c0a.614e.1751SMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Bob Liu <lliubbo@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bob Liu <bob.liu@oracle.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 07-01-14 12:34:34, Wanpeng Li wrote:
> Cced Sasha,
> On Tue, Jan 07, 2014 at 12:26:13PM +0800, Wanpeng Li wrote:
> >Hi Michal,
> >On Mon, Jan 06, 2014 at 03:18:27PM +0100, Michal Hocko wrote:
> >>On Mon 06-01-14 20:45:54, Bob Liu wrote:
> >>[...]
> >>>  544         if (PageAnon(page)) {
> >>>  545                 struct anon_vma *page__anon_vma = page_anon_vma(page);
> >>>  546                 /*
> >>>  547                  * Note: swapoff's unuse_vma() is more efficient with this
> >>>  548                  * check, and needs it to match anon_vma when KSM is active.
> >>>  549                  */
> >>>  550                 if (!vma->anon_vma || !page__anon_vma ||
> >>>  551                     vma->anon_vma->root != page__anon_vma->root)
> >>>  552                         return -EFAULT;
> >>>  553         } else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
> >>>  554                 if (!vma->vm_file ||
> >>>  555                     vma->vm_file->f_mapping != page->mapping)
> >>>  556                         return -EFAULT;
> >>>  557         } else
> >>>  558                 return -EFAULT;
> >>> 
> >>> That's the "other conditions" and the reason why we can't use
> >>> BUG_ON(!vma) in new_vma_page().
> >>
> >>Sorry, I wasn't clear with my question. I was interested in which of
> >>these triggered and why only for hugetlb pages?
> >
> >Not just for hugetlb pages, sorry for do two things in one patch. The change 
> >for hugetlb pages is to fix the potential dereference NULL pointer reported 
> >by Dan. http://marc.info/?l=linux-mm&m=137689530323257&w=2 
> >
> >If we should ask Sasha to add more debug information to dump which condition 
> >is failed in page_address_in_vma() for you?

I am always more calm when the removed BUG_ON is properly understood and
justified.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
