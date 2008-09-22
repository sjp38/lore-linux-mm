Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8MGegrR011996
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 12:40:43 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8MGmcWC203398
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 10:48:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8MMmT1E025724
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 16:48:29 -0600
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in
	/proc/pid/smaps
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080922162152.GB7716@csn.ul.ie>
References: <1222047492-27622-1-git-send-email-mel@csn.ul.ie>
	 <1222047492-27622-2-git-send-email-mel@csn.ul.ie>
	 <1222098955.8533.50.camel@nimitz>  <20080922162152.GB7716@csn.ul.ie>
Content-Type: text/plain
Date: Mon, 22 Sep 2008 09:48:18 -0700
Message-Id: <1222102098.8533.62.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-09-22 at 17:21 +0100, Mel Gorman wrote:
> The corollary is that someone running with a 64K base page kernel may be
> surprised that the pagesize is always 4K. However I'll check if there is
> a simple way of checking out if the MMU size differs from PAGE_SIZE.

Sure.  If it isn't easy, the best thing to do is probably just to
document the "interesting" behavior.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
