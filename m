Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAEFRVTe011059
	for <linux-mm@kvack.org>; Tue, 14 Nov 2006 10:27:31 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAEFRUbi359158
	for <linux-mm@kvack.org>; Tue, 14 Nov 2006 08:27:30 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAEFRUpT029026
	for <linux-mm@kvack.org>; Tue, 14 Nov 2006 08:27:30 -0700
Subject: Re: [hugepage] Check for brk() entering a hugepage region
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20061114040339.GK13060@localhost.localdomain>
References: <20061114040339.GK13060@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 14 Nov 2006 09:27:28 -0600
Message-Id: <1163518049.17046.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: Hugh Dickins <hugh@veritas.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Lameter' <clameter@sgi.com>, 'Andrew Morton' <akpm@osdl.org>, bill.irwin@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-11-14 at 15:03 +1100, 'David Gibson' wrote:
> Andrew, please apply.  I could have sworn I checked ages ago, and
> thought that sys_brk() eventually called do_mmap_pgoff() which would
> do the necessary checks.  Can't find any evidence of such a change
> though, so either I was just blind at the time, or it happened before
> the changeover to git.
> 
> Unlike mmap(), the codepath for brk() creates a vma without first
> checking that it doesn't touch a region exclusively reserved for
> hugepages.  On powerpc, this can allow it to create a normal page vma
> in a hugepage region, causing oopses and other badness.
> 
> This patch adds a test to prevent this.  With this patch, brk() will
> simply fail if it attempts to move the break into a hugepage reserved
> region.
> 
> Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
