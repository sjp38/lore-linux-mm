Date: Tue, 3 Oct 2006 04:52:37 -0700
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: [patch] enforce proper tlb flush in unmap_hugepage_range
Message-ID: <20061003115237.GE3517@holomorphy.com>
References: <000001c6e6ce$4eb93590$bb80030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001c6e6ce$4eb93590$bb80030a@amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>, bill.irwin@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 03, 2006 at 02:28:37AM -0700, Chen, Kenneth W wrote:
> Spotted by Hugh that hugetlb page is free'ed back to global pool
> before performing any TLB flush in unmap_hugepage_range(). This
> potentially allow threads to abuse free-alloc race condition.
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

This seems terribly familiar. I should have gotten this cleaned up a
long time ago since I'm sure I knew this was an outstanding problem at
some point.

Good patch.

Signed-off-by: William Irwin <wli@holomorphy.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
