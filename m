Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAEMVEOE017435
	for <linux-mm@kvack.org>; Mon, 14 Nov 2005 17:31:14 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAEMVE4S103498
	for <linux-mm@kvack.org>; Mon, 14 Nov 2005 17:31:14 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jAEMVDGj015806
	for <linux-mm@kvack.org>; Mon, 14 Nov 2005 17:31:14 -0500
Subject: Re: [RFC] NUMA memory policy support for HUGE pages
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0511141340160.4663@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511111051080.20589@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.62.0511111225100.21071@schroedinger.engr.sgi.com>
	 <1131980814.13502.12.camel@localhost.localdomain>
	 <Pine.LNX.4.62.0511141340160.4663@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 14 Nov 2005 16:30:10 -0600
Message-Id: <1132007410.13502.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, ak@suse.de, linux-kernel@vger.kernel.org, kenneth.w.chen@intel.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Mon, 2005-11-14 at 13:46 -0800, Christoph Lameter wrote:
> This is V2 of the patch.
> 
> Changes:
> 
> - Cleaned up by folding find_or_alloc() into hugetlb_no_page().

IMHO this is not really a cleanup.  When the demand fault patch stack
was first accepted, we decided to separate out find_or_alloc_huge_page()
because it has the page_cache retry loop with several exit conditions.
no_page() has its own backout logic and mixing the two makes for a
tangled mess.  Can we leave that hunk out please?

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
