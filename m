Received: from rra2002 (helo=localhost)
	by aria.ncl.cs.columbia.edu with local-esmtp (Exim 4.22)
	id 19ttYZ-0003yk-Am
	for linux-mm@kvack.org; Mon, 01 Sep 2003 14:37:39 -0400
Date: Mon, 1 Sep 2003 14:37:39 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@aria.ncl.cs.columbia.edu>
Subject: flushing tlb in try_to_swap_out 
Message-ID: <Pine.GSO.4.51.0309011437050.15065@aria.ncl.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   I see that in try_to_swap_out() (linux 2.4.19), the page that is being
unmapped from a process is flushed out. But try_to_swap_out() is executed
in the context of kswapd. And also whenever a context switch takes place
the whole tlb is flushed out. So is this flushing done just becuase linux
uses lazy_tlb_flush during process context switch ?

 thanks a lot,
 Raghu
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
