Message-ID: <20041008173155.52028.qmail@web52901.mail.yahoo.com>
Date: Fri, 8 Oct 2004 18:31:55 +0100 (BST)
From: Ankit Jain <ankitjain1580@yahoo.com>
Subject: hit/miss
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Consider a two-level memory hierarchy system M1 & M2.
M1 is accessed first and on miss M2 is accessed. The
access of M1 is 2 nanoseconds and the miss penalty
(the time to get the data from M2 in case of a miss)
is 100 nanoseconds. The probability that a valid data
is found in M1 is 0.97. The average memory access time
will be how much?

if somebody can solve this?

thanks 

ankit

________________________________________________________________________
Yahoo! Messenger - Communicate instantly..."Ping" 
your friends today! Download Messenger Now 
http://uk.messenger.yahoo.com/download/index.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
