Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA9NTaEx030531
	for <linux-mm@kvack.org>; Wed, 9 Nov 2005 18:29:36 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA9NTaCV115664
	for <linux-mm@kvack.org>; Wed, 9 Nov 2005 18:29:36 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jA9NTZ4E023489
	for <linux-mm@kvack.org>; Wed, 9 Nov 2005 18:29:36 -0500
Subject: [PATCH 0/4] hugetlb: copy on write
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Wed, 09 Nov 2005 17:28:45 -0600
Message-Id: <1131578925.28383.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>, wli@holomorphy.com, hugh@veritas.com, rohit.seth@intel.com, kenneth.w.chen@intel.com, "ADAM G. LITKE [imap]" <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a resend of the patches I sent on Nov 7th.  I've broken them out
as requested.  Comments (especially on the copy-on-write portion)
appreciated.  Does anyone have a fundamental objection to moving forward
with these?

remove-dup-isize-check - Remove duplicated i_size truncation race check
rename-find_lock_huge_page - Switch to a more appropriate name
hugetlb_no_page - Mild reorg to support multiple fault types
htlb-cow - Copy on write support

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
