Date: Tue, 14 Nov 2006 11:19:51 +1100
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [hugepage] Fix unmap_and_free_vma backout path
Message-ID: <20061114001951.GE13060@localhost.localdomain>
References: <20061113062246.GH27042@localhost.localdomain> <000301c706f6$4ae26160$a081030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000301c706f6$4ae26160$a081030a@amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Christoph Lameter' <clameter@sgi.com>, 'Andrew Morton' <akpm@osdl.org>, 'Hugh Dickins' <hugh@veritas.com>, bill.irwin@oracle.com, 'Adam Litke' <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 12, 2006 at 11:35:28PM -0800, Chen, Kenneth W wrote:
> David Gibson wrote on Sunday, November 12, 2006 10:23 PM
> > > > Probably, yes, although it's yet another "if (hugepage)
> > > > specialcase()".  But I still think we want the above patch as well.
> > > > It will make sure we correctly back out from any other possible
> > > > failure cases in hugetlbfs_file_mmap() - ones I haven't thought of, or
> > > > which get added later.
> > > 
> > > 
> > > Something like this?  I haven't tested it yet.  But looks plausible
> > > because we already have if is_file_hugepages() in the generic path.
> > 
> > Um.. if you're going to test pgoff here, you should also test the
> > address.
> 
> prepare_hugepage_range() should catch misaligned memory address, right?
> What more does get_unmapped_area() need to test?
> 
> 
> > Oh, and that point is too late to catch MAP_FIXED mappings.
> 
> I don't understand what you mean by that.

Sorry, old data.  I was thinking of the old get_unmapped_area() which
had entirely separate paths for MAP_FIXED and otherwise.  And I had my
sense inverted as well.

It used to be that prepare_hugepage_range() was called *only* in the
MAP_FIXED case (it being assumed that the hugetlb specific
get_unmapped_area call would do any necessary preparation).

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
