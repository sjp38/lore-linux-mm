Received: from m-net.arbornet.org (m-net.arbornet.org [209.142.209.161])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA18118
	for <linux-mm@kvack.org>; Thu, 1 Apr 1999 04:38:13 -0500
Received: from localhost (amol@localhost)
	by m-net.arbornet.org (8.8.5/8.8.6) with SMTP id EAA29211
	for <linux-mm@kvack.org>; Thu, 1 Apr 1999 04:16:51 -0500 (EST)
Date: Thu, 1 Apr 1999 04:16:51 -0500 (EST)
From: Amol Mohite <amol@m-net.arbornet.org>
Subject: Somw questions [ MAYBE OFFTOPIC ]
Message-ID: <Pine.BSI.3.96.990401041607.28014A-100000@m-net.arbornet.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

These might be newbie like qs., but I would really appreciate it if anyone
could answer them.

1) How does the processor notify the OS of a pagefault ? or a null pointer
exception ?
 Now null pointer exception I know, is done using the expand down
attribute in descriptor. However, when the processor gp faults, how does
it know it is a null pointer exception ?

Where does it store the program counter ?

2) How are the following exceptions handled ;
	TLB Refill
	TLB Invalid
	TLB Modify ?

3) How does the processor differentiate between entries (PTE) in the TLB
belonging to different processes ? Is it a bit in this ?

4) Why is the vm_area_structs maintained as a circular list, AVL tree and
as a doubly linked list ?
	Why an AVL tree ? Any specific reason ?

5) What is the difference between SIGSEGV and a SIGBUS ? 

6) How does the processor signal memory access inan illegal way (i.e.
trying write access to memory when this is not allowed )

7) How does linux handle malloc function ?


I would really appreciate it if anyone could answer these.

Please cc any answers to me as I am not on this list.

Thanks a lot.



--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
