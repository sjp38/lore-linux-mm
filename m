Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l99KN1ph026130
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 21:23:02 +0100
Received: from rv-out-0910.google.com (rvbf5.prod.google.com [10.140.82.5])
	by zps38.corp.google.com with ESMTP id l99KMalN018654
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 13:23:01 -0700
Received: by rv-out-0910.google.com with SMTP id f5so1853171rvb
        for <linux-mm@kvack.org>; Tue, 09 Oct 2007 13:23:00 -0700 (PDT)
Message-ID: <b040c32a0710091323v7fab02b0vaab61f0ea12278d@mail.gmail.com>
Date: Tue, 9 Oct 2007 13:23:00 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [rfc] more granular page table lock for hugepages
In-Reply-To: <20071008225234.GC27824@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071008225234.GC27824@linux-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/8/07, Siddha, Suresh B <suresh.b.siddha@intel.com> wrote:
> Appended patch is a quick prototype which extends the concept of separate
> spinlock per page table page to hugepages. More granular spinlock will
> be used to guard the page table entries in the pmd page, instead of using the
> mm's single page_table_lock.

What path do you content on mm->page_table_lock?

The major fault for hugetlb page is blanket by
hugetlb_instantiation_mutex.  So likelihood of contention on
page_table spin lock is low.  For minor fault, I would think
mapping->i_mmap_lock will kick in before page table lock.  That left
follow_hugetlb_page path.  Is it the case?

Also are you contending within hugetlb regions, or contenting with
other vma regions?

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
