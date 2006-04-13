Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3DHasZG013255
	for <linux-mm@kvack.org>; Thu, 13 Apr 2006 13:36:54 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3DHaiWw133554
	for <linux-mm@kvack.org>; Thu, 13 Apr 2006 13:36:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k3DHahug018047
	for <linux-mm@kvack.org>; Thu, 13 Apr 2006 13:36:44 -0400
Subject: [RFD hugetlbfs] strict accounting and wasteful reservations
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Thu, 13 Apr 2006 12:36:42 -0500
Message-Id: <1144949802.10795.99.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'David Gibson' <david@gibson.dropbear.id.au>, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry to bring this up after the strict accounting patch was merged but
things moved along a bit too fast for me to intervene.

In the thread beginning at http://lkml.org/lkml/2006/3/8/47 , a
discussion was had to compare the patch from David Gibson (the patch
that was ultimately merged) with an alternative patch from Ken Chen.
The main functional difference is how we handle arbitrary file offsets
into a hugetlb file.  The current patch reserves enough huge pages to
populate the whole file up to the highest file offset in use.  Ken's
patch supported arbitrary blocks.

For libhugetlbfs, we would like to have sparsely populated hugetlb files
without wasting all the extra huge pages that the current implementation
requires.  That aside, having yet another difference in behavior for
hugetlbfs files (that isn't necessary) seems like a bad idea.

So on to my questions.  Do people agree that supporting reservation for
sparsely populated hugetlbfs files makes sense?

I've been hearing complaints about the code churn in hugetlbfs code
lately, so is there a way to adapt what we currently have to support
this?

Otherwise, should I (or Ken?) take a stab at resurrecting Ken's
competing patch with the intent of eventually replacing the current
code?
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
