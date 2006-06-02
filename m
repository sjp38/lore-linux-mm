Date: Fri, 2 Jun 2006 17:43:13 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] hugetlb: powerpc: Actively close unused htlb regions on
 vma close
In-Reply-To: <1149257287.9693.6.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0606021737310.26864@blonde.wat.veritas.com>
References: <1149257287.9693.6.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, David Gibson <david@gibson.dropbear.id.au>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Jun 2006, Adam Litke wrote:
> 
> On powerpc, each segment can contain pages of only one size.  When a
> hugetlb mapping is requested, a segment is located and marked for use
> with huge pages.  This is a uni-directional operation -- hugetlb
> segments are never marked for use again with normal pages.  For long
> running processes which make use of a combination of normal and hugetlb
> mappings, this behavior can unduly constrain the virtual address space.
> 
> The following patch introduces a architecture-specific vm_ops.close()
> hook.  For all architectures besides powerpc, this is a no-op.  On
> powerpc, the low and high segments are scanned to locate empty hugetlb
> segments which can be made available for normal mappings.  Comments?

Wouldn't hugetlb_free_pgd_range be a better place to do that kind of
thing, all within arch/powerpc, no need for arch_hugetlb_close_vma etc?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
