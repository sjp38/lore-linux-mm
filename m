Message-ID: <3DEE1CA5.7C45C252@scs.ch>
Date: Wed, 04 Dec 2002 16:17:57 +0100
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: Question on swapping
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hello,

I am looking at the swapping mechanism in Linux. I have read the relevant chapter 16 in 'Understanding the Linux Kernel' from Bovet&Cesati, and looked at the 2.2.18 kernel
source code. I still have the follwing question:

Function try_to_swap_out() [p. 481 in 'Understanding the Linux Kernel']:
If the page in question already belongs to the swap cache, the function performs no data transfer to the swap space on the disk (but only marks the page as swapped out).
The corresponding comment in the try_to_swap_out() functions states 'Is the page already in the swap cache? If so, ..... - it is already up-to-date on disk.
Understanding the Linux Kernel states on p. 482 'If the page belongs to the swap cache .... no memory transfer is performed'.
Now my question is, couldn't the page have been modified since it was added to the swap cache (and written to disk), and thus differ from the data in the swap space? In
this case shouldn't the page be written to disk (again)?
Such a modification may result from a store operation of another process that shares the page with the process from which it was added to the swap cache, or by an I/O
operation from some external device - in both cases the data stored in the corresponding page slot in the swap area differs from the data stored in the page frame. If later
on the page frame is released by shrink_mmap() from the swap cache, and subsequently needs to be restored from the data in the swap area, the page frame's latest content is
lost.

Thanks in advance for any help
with best regards
Martin Maletinsky

P.S. Please put me on CC: in your reply, since I am not in the mailing list.

--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
