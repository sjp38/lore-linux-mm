Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA7LBRDh017474
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 16:11:27 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA7LBRqu118382
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 16:11:27 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jA7LBRDO002776
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 16:11:27 -0500
Subject: [RFC 0/2] Copy on write for hugetlbfs
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Mon, 07 Nov 2005 15:10:41 -0600
Message-Id: <1131397841.25133.90.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>, hugh@veritas.com, rohit.seth@intel.com, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

The following two patches implement copy-on-write for hugetlbfs (thus
enabling MAP_PRIVATE mappings).  Patch 1/2 (previously posted by David
Gibson) contains a couple small fixes to the demand fault handler and
makes COW fit in nicely.  Patch 2/2 is the cow changes.  Comments?
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
