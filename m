Received: from rra2002 (helo=localhost)
	by aria.ncl.cs.columbia.edu with local-esmtp (Exim 4.14)
	id 19g4Oi-0007JO-8v
	for linux-mm@kvack.org; Fri, 25 Jul 2003 11:22:20 -0400
Date: Fri, 25 Jul 2003 11:22:20 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Subject: pte flags and tlb miss
Message-ID: <Pine.GSO.4.51.0307251118140.27260@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



  I am just trying to understand how pte flags work. I see that the pte_mkyoung()
is called whenever a pte entry
is created. In i-386 it happens only in handle_pte_fault which is called
during a page fault. My question is will this flag be updated during every
page fault and every tlb miss.

  When is pte_mkyoung() called ?

  One more question is, how are tlb misses handled in linux. Are they
considered as minor faults and handled by do_page_fault() itself or is
there any other function that handles this ?


 Thanks,
Raghu
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
