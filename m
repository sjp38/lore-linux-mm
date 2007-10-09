Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l99L2rC7026019
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 17:02:53 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l99L2j37367480
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 15:02:49 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l99L2iEJ021513
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 15:02:45 -0600
Subject: Re: [rfc] more granular page table lock for hugepages
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <b040c32a0710091323v7fab02b0vaab61f0ea12278d@mail.gmail.com>
References: <20071008225234.GC27824@linux-os.sc.intel.com>
	 <b040c32a0710091323v7fab02b0vaab61f0ea12278d@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 09 Oct 2007 14:05:57 -0700
Message-Id: <1191963958.12131.43.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-09 at 13:23 -0700, Ken Chen wrote:
> On 10/8/07, Siddha, Suresh B <suresh.b.siddha@intel.com> wrote:
> > Appended patch is a quick prototype which extends the concept of separate
> > spinlock per page table page to hugepages. More granular spinlock will
> > be used to guard the page table entries in the pmd page, instead of using the
> > mm's single page_table_lock.
> 
> What path do you content on mm->page_table_lock?
> 
> The major fault for hugetlb page is blanket by
> hugetlb_instantiation_mutex.  So likelihood of contention on
> page_table spin lock is low.  For minor fault, I would think
> mapping->i_mmap_lock will kick in before page table lock.  That left
> follow_hugetlb_page path.  Is it the case?

Yes. follow_hugetlb_page() is where our benchmark team has seen
contention with threaded workload.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
