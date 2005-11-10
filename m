Date: Wed, 9 Nov 2005 16:13:09 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 3/4] Hugetlb: Reorganize hugetlb_fault to prepare for COW
Message-ID: <20051110001309.GM29402@holomorphy.com>
References: <1131578925.28383.9.camel@localhost.localdomain> <1131579527.28383.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1131579527.28383.22.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>, hugh@veritas.com, rohit.seth@intel.com, kenneth.w.chen@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 09, 2005 at 05:38:47PM -0600, Adam Litke wrote:
> Hugetlb: Reorganize hugetlb_fault to prepare for COW
> This patch splits the "no_page()" type activity into its own function,
> hugetlb_no_page().  hugetlb_fault() becomes the entry point for hugetlb faults
> and delegates to the appropriate handler depending on the type of fault.  Right
> now we still have only hugetlb_no_page() but a later patch introduces a COW
> fault.
> Original post by David Gibson <david@gibson.dropbear.id.au>
> Version 2: Wed 9 Nov 2005
> 	Broken out into a separate patch
> Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
> Signed-off-by: Adam Litke <agl@us.ibm.com>

Straightforward enough.

Acked-by: William Irwin <wli@holomorphy.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
