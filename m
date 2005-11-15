Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAFMNF92028558
	for <linux-mm@kvack.org>; Tue, 15 Nov 2005 17:23:15 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAFMNFPd115616
	for <linux-mm@kvack.org>; Tue, 15 Nov 2005 17:23:15 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jAFMNE3W030495
	for <linux-mm@kvack.org>; Tue, 15 Nov 2005 17:23:15 -0500
Subject: Re: [PATCH] hugepages: fold find_or_alloc_pages into huge_no_page()
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0511151345470.11011@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511151345470.11011@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 15 Nov 2005 16:22:09 -0600
Message-Id: <1132093329.22243.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, ak@suse.de, linux-kernel@vger.kernel.org, kenneth.w.chen@intel.com, wli@holomorphy.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Tue, 2005-11-15 at 13:47 -0800, Christoph Lameter wrote:
> The number of parameters for find_or_alloc_page increases significantly after
> policy support is added to huge pages. Simplify the code by folding
> find_or_alloc_huge_page() into hugetlb_no_page().
> 
> Adam Litke objected to this piece in an earlier patch but I think this is a
> good simplification. Diffstat shows that we can get rid of almost half of the
> lines of find_or_alloc_page(). If we can find no consensus then lets simply drop
> this patch.

Okay.  Since I am the only objector I'll be willing to back down if
we're sure find_or_alloc_huge_page() has no extra value as a separate
function.  Five parameters is getting a bit unwieldy and suggests it's
usefulness outside of hugetlb_no_page() is near zero.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
