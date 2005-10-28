Date: Fri, 28 Oct 2005 17:23:34 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051028212334.GA17846@thunk.org>
References: <1130366995.23729.38.camel@localhost.localdomain> <20051028034616.GA14511@ccure.user-mode-linux.org> <200510281955.09615.blaisorblade@yahoo.it>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200510281955.09615.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Jeff Dike <jdike@addtoit.com>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 28, 2005 at 07:55:09PM +0200, Blaisorblade wrote:
> > On Thu, Oct 27, 2005 at 06:42:36PM -0700, Badari Pulavarty wrote:
> > > Like Andrea mentioned MADV_DONTNEED should be able to do what JVM
> > > folks want. If they want more than that, get in touch with me.
> > > While doing MADV_REMOVE, I will see if I can satsify their needs also.
> 
> > Well, I asked if what he wanted was simply walking all of the page
> > tables and marking the indicated pages as "clean",
> This idea sounds interesting and kludgy enough :-) .
> > but he claimed that 
> > anything that involved walking the pages tables would be too slow.
> > But it may be that he was assuming this would be as painful as
> > munmap(), when of course it wouldn't be.
> 
> I am curious which is the difference between the two. I know that we must also 
> walk the vma tree, and that since we bundle the pointers in the vma the 
> spatial locality is very poor, but I still don't get this huge loss.

Because if we do an munmap, we're removing entries from the page table
entries, which means we have to do cross-CPU IPI's to flush TLB's on
all of the CPU's.  That wouldn't be necessary if we're just marking
the pages clean.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
