Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4SDbmJA018420
	for <linux-mm@kvack.org>; Wed, 28 May 2008 09:37:48 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4SDbkb8068012
	for <linux-mm@kvack.org>; Wed, 28 May 2008 07:37:46 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4SDbiB2032149
	for <linux-mm@kvack.org>; Wed, 28 May 2008 07:37:46 -0600
Subject: Re: [PATCH 1/3] Move hugetlb_acct_memory()
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080527185048.16194.40237.sendpatchset@skynet.skynet.ie>
References: <20080527185028.16194.57978.sendpatchset@skynet.skynet.ie>
	 <20080527185048.16194.40237.sendpatchset@skynet.skynet.ie>
Content-Type: text/plain
Date: Wed, 28 May 2008 08:37:45 -0500
Message-Id: <1211981865.12036.56.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, dean@arctic.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, dwg@au1.ibm.com, linux-mm@kvack.org, andi@firstfloor.org, kenchen@google.com, apw@shadowen.org, abh@cray.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-05-27 at 19:50 +0100, Mel Gorman wrote:
> A later patch in this set needs to call hugetlb_acct_memory() before it
> is defined. This patch moves the function without modification. This makes
> later diffs easier to read.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
