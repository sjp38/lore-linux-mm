Date: Fri, 5 Sep 2003 22:02:06 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@cs.columbia.edu>
Subject: swap_free() inside delete_from_swap_cache
Message-ID: <Pine.LNX.4.44.0309052200580.440-100000@tehran.clic.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



 Why is swap_free() called inside delete_from_swap_cache() in linux 
2.4.19? I believe delete_from_swap_cache() is called when we write a page 
to the swap disk. swap_free() decreases the count of number of references 
to that page. I am not understanding why should we decrement the count of 
references when we are swapping the page to the disk.

 Thanks,
 Raghu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
