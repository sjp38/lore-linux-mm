Date: Wed, 11 Jan 2006 17:05:02 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 2/2] hugetlb: synchronize alloc with page cache insert
Message-ID: <20060112010502.GG9091@holomorphy.com>
References: <1137018263.9672.10.camel@localhost.localdomain> <200601120040.k0C0ebg02818@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200601120040.k0C0ebg02818@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Adam Litke' <agl@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 11, 2006 at 04:40:37PM -0800, Chen, Kenneth W wrote:
> What if two processes fault on the same page and races with find_lock_page(),
> both find page not in the page cache.  The process won the race proceed to
> allocate last hugetlb page.  While the other will exit with SIGBUS.
> In theory, both processes should be OK.

This is supposed to fix the incarnation of that as a preexisting
problem, but you're right, there is no fallback or retry for the case
of hugepage queue exhaustion. For some reason I saw a phantom page
allocator fallback in the hugepage allocator changes.

Looks like back to the drawing board for this pair of patches, though
I'd be more than happy to get a solution to this.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
