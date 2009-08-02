Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 524D46B005A
	for <linux-mm@kvack.org>; Sun,  2 Aug 2009 04:34:31 -0400 (EDT)
Received: by bwz24 with SMTP id 24so2508163bwz.38
        for <linux-mm@kvack.org>; Sun, 02 Aug 2009 01:44:44 -0700 (PDT)
Message-ID: <4A755201.1010200@gmail.com>
Date: Sun, 02 Aug 2009 10:44:49 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: mm/hugetlb: GFP_KERNEL allocation under spinlock?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi,

could anybody please confirm this cannot happen?

hugetlb_fault()
-> spin_lock()
-> hugetlb_cow()
   -> alloc_huge_page()
      -> vma_needs_reservation()
         -> region_chg() (either of the 2)
            -> kmalloc(*, GFP_KERNEL)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
