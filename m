Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9BIONDJ016847
	for <linux-mm@kvack.org>; Tue, 11 Oct 2005 14:24:23 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9BIOMgA065120
	for <linux-mm@kvack.org>; Tue, 11 Oct 2005 14:24:22 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9BIOM5u012240
	for <linux-mm@kvack.org>; Tue, 11 Oct 2005 14:24:22 -0400
Subject: [PATCH 0/3] Demand faulting for hugetlb
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Tue, 11 Oct 2005 13:24:17 -0500
Message-Id: <1129055057.22182.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: "ADAM G. LITKE [imap]" <agl@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Gibson <david@gibson.dropbear.id.au>, ak@suse.de, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Ok, here's the next iteration of these patches.  I think I've handled
the truncate() case by comparing the hugetlbfs inode's i_size with the
mapping offset of the requested page to make sure it hasn't been
truncated.  Can anyone confirm or deny that I have the locking correct
for this?  The other patches are still unchanged.  Andrew: Did Andi
Kleen's explanation of huge_pages_needed() satisfy?
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
