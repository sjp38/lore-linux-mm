Date: Tue, 14 Nov 2006 15:48:13 -0800
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: [hugepage] Fix unmap_and_free_vma backout path
Message-ID: <20061114234813.GP7919@holomorphy.com>
References: <000301c706f6$4ae26160$a081030a@amr.corp.intel.com> <Pine.LNX.4.64.0611131650140.8280@blonde.wat.veritas.com> <1163450069.17046.24.camel@localhost.localdomain> <Pine.LNX.4.64.0611132039001.23846@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0611132039001.23846@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Adam Litke <agl@us.ibm.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'David Gibson' <david@gibson.dropbear.id.au>, 'Christoph Lameter' <clameter@sgi.com>, 'Andrew Morton' <akpm@osdl.org>, bill.irwin@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 13, 2006 at 08:41:49PM +0000, Hugh Dickins wrote:
> [PATCH] hugetlb: prepare_hugepage_range check offset too
> prepare_hugepage_range should check file offset alignment when it checks
> virtual address and length, to stop MAP_FIXED with a bad huge offset from
> unmapping before it fails further down.  PowerPC should apply the same
> prepare_hugepage_range alignment checks as ia64 and all the others do.
> Then none of the alignment checks in hugetlbfs_file_mmap are required
> (nor is the check for too small a mapping); but even so, move up setting
> of VM_HUGETLB and add a comment to warn of what David Gibson discovered -
> if hugetlbfs_file_mmap fails before setting it, do_mmap_pgoff's unmap_region
> when unwinding from error will go the non-huge way, which may cause bad
> behaviour on architectures (powerpc and ia64) which segregate their huge
> mappings into a separate region of the address space.
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Acked-by: William Irwin <wli@holomorphy.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
