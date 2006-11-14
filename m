Date: Tue, 14 Nov 2006 15:16:53 -0800
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: [hugepage] Check for brk() entering a hugepage region
Message-ID: <20061114231653.GO7919@holomorphy.com>
References: <20061114040339.GK13060@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061114040339.GK13060@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: Hugh Dickins <hugh@veritas.com>, Adam Litke <agl@us.ibm.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Lameter' <clameter@sgi.com>, 'Andrew Morton' <akpm@osdl.org>, bill.irwin@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 14, 2006 at 03:03:39PM +1100, 'David Gibson' wrote:
> Andrew, please apply.  I could have sworn I checked ages ago, and
> thought that sys_brk() eventually called do_mmap_pgoff() which would
> do the necessary checks.  Can't find any evidence of such a change
> though, so either I was just blind at the time, or it happened before
> the changeover to git.
> Unlike mmap(), the codepath for brk() creates a vma without first
> checking that it doesn't touch a region exclusively reserved for
> hugepages.  On powerpc, this can allow it to create a normal page vma
> in a hugepage region, causing oopses and other badness.
> This patch adds a test to prevent this.  With this patch, brk() will
> simply fail if it attempts to move the break into a hugepage reserved
> region.
> Signed-off-by: David Gibson <david@gibson.dropbear.id.au>

Acked-by: William Irwin <wli@holomorphy.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
