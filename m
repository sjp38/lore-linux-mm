Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8SKOZjY012756
	for <linux-mm@kvack.org>; Wed, 28 Sep 2005 16:24:35 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8SKPln9426668
	for <linux-mm@kvack.org>; Wed, 28 Sep 2005 14:25:47 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8SKPlS2032515
	for <linux-mm@kvack.org>; Wed, 28 Sep 2005 14:25:47 -0600
Subject: [PATCH 0/3] Demand faulting for huge pages
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Wed, 28 Sep 2005 15:25:41 -0500
Message-Id: <1127939141.26401.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: "ADAM G. LITKE [imap]" <agl@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew.  Can we give hugetlb demand faulting a spin in the mm tree?
And could people with alpha, sparc, and ia64 machines give them a good
spin?  I haven't been able to test those arches yet.

-Thanks

- htlb-get_user_pages removes an optimization that is no longer valid
when demand faulting huge pages

- htlb-fault moves the fault logic from hugetlb_prefault() to
hugetlb_pte_fault() and find_get_huge_page().

- htlb-acct adds an overcommit check to maintain the no-overcommit
semantics provided by hugetlb_prefault()
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
