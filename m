Date: Tue, 9 Oct 2007 17:15:23 -0700
From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Subject: Re: [rfc] more granular page table lock for hugepages
Message-ID: <20071010001523.GA30676@linux-os.sc.intel.com>
References: <20071008225234.GC27824@linux-os.sc.intel.com> <b040c32a0710091323v7fab02b0vaab61f0ea12278d@mail.gmail.com> <1191963958.12131.43.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1191963958.12131.43.camel@dyn9047017100.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: Ken Chen <kenchen@google.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 09, 2007 at 02:05:57PM -0700, Badari Pulavarty wrote:
> On Tue, 2007-10-09 at 13:23 -0700, Ken Chen wrote:
> > On 10/8/07, Siddha, Suresh B <suresh.b.siddha@intel.com> wrote:
> > > Appended patch is a quick prototype which extends the concept of separate
> > > spinlock per page table page to hugepages. More granular spinlock will
> > > be used to guard the page table entries in the pmd page, instead of using the
> > > mm's single page_table_lock.
> > 
> > What path do you content on mm->page_table_lock?
> > 
> > The major fault for hugetlb page is blanket by
> > hugetlb_instantiation_mutex.  So likelihood of contention on
> > page_table spin lock is low.  For minor fault, I would think
> > mapping->i_mmap_lock will kick in before page table lock.  That left
> > follow_hugetlb_page path.  Is it the case?
> 
> Yes. follow_hugetlb_page() is where our benchmark team has seen
> contention with threaded workload.

That's correct. And the direct IO leading to those calls.

thanks,
suresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
