Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9IMaalv018495
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 18:36:36 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9IMaZa2088418
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 18:36:35 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9IMaZeS019438
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 18:36:35 -0400
Subject: [PATCH 0/2] hugetlb: Demand faulting
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Tue, 18 Oct 2005 17:36:20 -0500
Message-Id: <1129674980.8702.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com, William Irwin <wli@holomorphy.com>, David Gibson <david@gibson.dropbear.id.au>, "ADAM G. LITKE [imap]" <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Ok.  Hugh and I have rolled these around the last few days and what we
have now should integrate properly and solve the outstanding truncation
issues.  We should be ready to re-insert these patches into -mm.

The old patch [1/3] remove get_user_pages_optimization is no longer
necessary.  We now have [1/2] "the fault handler" and [2/2] "overcommit
accounting check"
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
