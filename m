Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6AI2dYq017384
	for <linux-mm@kvack.org>; Thu, 10 Jul 2008 14:02:39 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6AI2aXU101672
	for <linux-mm@kvack.org>; Thu, 10 Jul 2008 12:02:36 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6AI2YEY012920
	for <linux-mm@kvack.org>; Thu, 10 Jul 2008 12:02:34 -0600
Subject: Re: [PATCH 2/2] [PATCH] Align faulting address to a hugepage
	boundary before unmapping
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080710173041.16433.21192.sendpatchset@skynet.skynet.ie>
References: <20080710173001.16433.87538.sendpatchset@skynet.skynet.ie>
	 <20080710173041.16433.21192.sendpatchset@skynet.skynet.ie>
Content-Type: text/plain
Date: Thu, 10 Jul 2008 13:02:52 -0500
Message-Id: <1215712972.14825.111.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, apw@shadowen.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-10 at 18:30 +0100, Mel Gorman wrote:
> When taking a fault for COW on a private mapping it is possible that the
> parent will have to steal the original page from its children due to an
> insufficient hugepage pool.  In this case, unmap_ref_private() is called
> for the faulting address to unmap via unmap_hugepage_range(). This patch
> ensures that the address used for unmapping is hugepage-aligned.
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
