Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RLfZDg022000
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:41:35 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RLfNvY057016
	for <linux-mm@kvack.org>; Tue, 27 May 2008 15:41:29 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RLfJX9017101
	for <linux-mm@kvack.org>; Tue, 27 May 2008 15:41:20 -0600
Subject: Re: [patch 18/23] hugetlb: allow arch overried hugepage allocation
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080525143454.025813000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143454.025813000@nick.local0.net>
Content-Type: text/plain
Date: Tue, 27 May 2008 16:41:18 -0500
Message-Id: <1211924479.12036.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi-suse@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Jon Tollefson <kniht@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> plain text document attachment
> (hugetlb-allow-arch-override-hugepage-allocation.patch)
> Allow alloc_bootmem_huge_page() to be overridden by architectures that can't
> always use bootmem. This requires huge_boot_pages to be available for
> use by this function. The 16G pages on ppc64 have to be reserved prior
> to boot-time. The location of these pages are indicated in the device
> tree.
> 
> Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
