Message-ID: <3D8054D5.B385C83@scs.ch>
Date: Thu, 12 Sep 2002 10:48:21 +0200
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: kiobuf interface / PG_locked flag
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hello,

I just read about the kiobuf interface in the Linux Device Driver book from Rubini/Corbet, and there is one point, which I don't understand:
- map_user_kiobuf() forces the pages within a user space address range into physical memory, and increments their usage count, which subsequently prevents the pages from
being swapped out.
- lock_kiovec() sets the PG_locked flag for the pages in the kiobufs of a kiovec. The PG_locked flag prevents the pages from being swapped out, which is however already
ensured by map_user_kiobuf().
(1) What is the reason to call lock_kiovec()?
(2) Are there any additional effects (other than prevent the page from being swapped out) resulting from a set PG_locked flag?
(3) Does anyone know a more detailed documentation of the kiobuf interface, than the book mentioned above?

P.S. please put me on CC in your reply, since I am not in the mailing list.

Thanks for any help,
best regards
Martin Maletinsky

--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
