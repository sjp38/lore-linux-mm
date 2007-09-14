Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8EHQd0K029401
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 13:26:39 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8EHQdma677388
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 13:26:39 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8EHQd06007444
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 13:26:39 -0400
Date: Fri, 14 Sep 2007 10:26:38 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 1/4] hugetlb: search harder for memory in alloc_fresh_huge_page()
Message-ID: <20070914172638.GT24941@us.ibm.com>
References: <20070906182134.GA7779@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070906182134.GA7779@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 06.09.2007 [11:21:34 -0700], Nishanth Aravamudan wrote:
> hugetlb: search harder for memory in alloc_fresh_huge_page()
> 
> Currently, alloc_fresh_huge_page() returns NULL when it is not able to
> allocate a huge page on the current node, as specified by its custom
> interleave variable. The callers of this function, though, assume that a
> failure in alloc_fresh_huge_page() indicates no hugepages can be
> allocated on the system period. This might not be the case, for
> instance, if we have an uneven NUMA system, and we happen to try to
> allocate a hugepage on a node (with __GFP_THISNODE) with less memory and
> fail, while there is still plenty of free memory on the other nodes.
> 
> To correct this, make alloc_fresh_huge_page() search through all online
> nodes before deciding no hugepages can be allocated. Add a helper
> function for actually allocating the hugepage. Also, while we expect
> particular semantics for __GFP_THISNODE, which are newly enforced --
> that is, that the allocation won't go off-node -- still use
> page_to_nid() to guarantee we don't mess up the accounting.

Christoph, Lee, ping? I haven't heard any response on these patches this
time around. Would it be acceptable to ask Andrew to pick them up for
the next -mm?

Andrew, there probably will be conflicts with Lee's nodes_state patches
and perhaps other patches queued for -mm, if you'd like me to
rebase/retest before picking them up.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
