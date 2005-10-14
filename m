Date: Fri, 14 Oct 2005 13:09:46 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [Patch 2/2] Special Memory (mspec) driver.
Message-ID: <20051014180946.GA4143@lnx-holt.americas.sgi.com>
References: <20051012194022.GE17458@lnx-holt.americas.sgi.com> <20051012194233.GG17458@lnx-holt.americas.sgi.com> <1129266725.22903.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1129266725.22903.25.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Robin Holt <holt@sgi.com>, ia64 list <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, hch@infradead.org, jgarzik@pobox.com, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 13, 2005 at 10:12:05PM -0700, Dave Hansen wrote:
> On Wed, 2005-10-12 at 14:42 -0500, Robin Holt wrote:
> ...
> 
> Looks like you could un-indent almost the entire function of you just
> did this instead:
> 
> 	if (!atomic_dec_and_test(&vdata->refcnt))
> 		return;

Done

> 
> This looks pretty similar to get_one_pte_map().  Is there enough
> commonality to use it?
> 

Added an extra patch to export get_one_pte_map and used that instead.

> How about:
> 
> 	vdata = vmalloc(sizeof(struct vma_data) + pages * sizeof(long));
> 	if (!vdata)
> 		return -ENOMEM;

Done

> This whole thing really is a driver for a piece of arch-specific
> hardware, right?  Does it really belong in /proc?  You already have a
> misc device, so you already have some area in sysfs.  Would that make a
> better place for it?

Most of the useful information for this was removed when the kernel
uncached allocator (and gen_alloc) were moved out of the earliest mspec.c.
Removed entirely.

> Isn't the general kernel style for these to keep the action out of the
> if() condition?
> 
> 	ret = misc_register(&cached_miscdev);
> 	if (ret) {
> 		...

Done.

Thanks,
Robin Holt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
