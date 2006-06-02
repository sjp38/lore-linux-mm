Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k52Gno24025715
	for <linux-mm@kvack.org>; Fri, 2 Jun 2006 12:49:50 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k52Gnoqs061104
	for <linux-mm@kvack.org>; Fri, 2 Jun 2006 12:49:50 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k52Gno8U004802
	for <linux-mm@kvack.org>; Fri, 2 Jun 2006 12:49:50 -0400
Subject: Re: [PATCH] hugetlb: powerpc: Actively close unused htlb regions
	on vma close
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0606021737310.26864@blonde.wat.veritas.com>
References: <1149257287.9693.6.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0606021737310.26864@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Fri, 02 Jun 2006 11:49:28 -0500
Message-Id: <1149266969.9693.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, David Gibson <david@gibson.dropbear.id.au>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2006-06-02 at 17:43 +0100, Hugh Dickins wrote:
> On Fri, 2 Jun 2006, Adam Litke wrote:
> > 
> > On powerpc, each segment can contain pages of only one size.  When a
> > hugetlb mapping is requested, a segment is located and marked for use
> > with huge pages.  This is a uni-directional operation -- hugetlb
> > segments are never marked for use again with normal pages.  For long
> > running processes which make use of a combination of normal and hugetlb
> > mappings, this behavior can unduly constrain the virtual address space.
> > 
> > The following patch introduces a architecture-specific vm_ops.close()
> > hook.  For all architectures besides powerpc, this is a no-op.  On
> > powerpc, the low and high segments are scanned to locate empty hugetlb
> > segments which can be made available for normal mappings.  Comments?
> 
> Wouldn't hugetlb_free_pgd_range be a better place to do that kind of
> thing, all within arch/powerpc, no need for arch_hugetlb_close_vma etc?

Hmm.  Interesting idea.  I'll take a look.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
