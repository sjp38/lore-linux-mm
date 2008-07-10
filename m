Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6AJ1i1X003434
	for <linux-mm@kvack.org>; Thu, 10 Jul 2008 15:01:44 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6AJ1iNX1970428
	for <linux-mm@kvack.org>; Thu, 10 Jul 2008 15:01:44 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6AJ1e9t026800
	for <linux-mm@kvack.org>; Thu, 10 Jul 2008 13:01:40 -0600
Subject: Re: [PATCH 1/2] [PATCH] Fix a hugepage reservation check for
	MAP_SHARED
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080710173021.16433.90661.sendpatchset@skynet.skynet.ie>
References: <20080710173001.16433.87538.sendpatchset@skynet.skynet.ie>
	 <20080710173021.16433.90661.sendpatchset@skynet.skynet.ie>
Content-Type: text/plain
Date: Thu, 10 Jul 2008 14:01:59 -0500
Message-Id: <1215716519.14825.112.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-10 at 18:30 +0100, Mel Gorman wrote:
> When removing a huge page from the hugepage pool for a fault the system
> checks to see if the mapping requires additional pages to be reserved, and
> if it does whether there are any unreserved pages remaining.  If not, the
> allocation fails without even attempting to get a page. In order to determine
> whether to apply this check we call vma_has_private_reserves() which tells us
> if this vma is MAP_PRIVATE and is the owner.  This incorrectly triggers the
> remaining reservation test for MAP_SHARED mappings which prevents allocation
> of the final page in the pool even though it is reserved for this mapping.
> 
> In reality we only want to check this for MAP_PRIVATE mappings where the
> process is not the original mapper.  Replace vma_has_private_reserves() with
> vma_has_reserves() which indicates whether further reserves are required,
> and update the caller.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Acked-by: Adam Litke <agl@us.ibm.com>

Tested and confirmed.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
