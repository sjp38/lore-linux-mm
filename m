Message-ID: <3DF0C9A6.6BCA939E@scs.ch>
Date: Fri, 06 Dec 2002 17:00:38 +0100
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: Another question on swapping
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hello,

In the 2.4.18 kernel, is it possible for a page in the page/swap cache, to be written to disk, while there are still some references (except those of the page/swap cache
and possibly the buffer cache) to that page.
In other words, can a dirty page in the page/swap cache become clean, while it's reference count is >= 3 (or >= 2 and it's not in the buffer cache). If so, could you
explain me the scenario in which this may occur?

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
