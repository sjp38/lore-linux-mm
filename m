Message-ID: <378CA731.846F7580@sap-ag.de>
Date: Wed, 14 Jul 1999 17:05:21 +0200
From: Thomas Hiller <thomas.hiller@sap-ag.de>
MIME-Version: 1.0
Subject: SHM implementation in 2.2.x
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org, kanoj@google.engr.sgi.com
List-ID: <linux-mm.kvack.org>

What are the real limits in using SHM ?
I looked through the code and are quite lost.
There seem to be a 24 bit limit in ID + IDX bits (shmparam.h). Is this
due to the fact that the other 8 bits are used for SWP_TYPE ?
What is the limit for SHMMAX and what advantage is there to leave it at
a lower limit ?

What we need are many big shared segments (say 4000 * 1 GB). Is this
possible with the current implementation ? Or what must be changed ?
Only SHM_ID_BITS and SHMMAX ?

Thanks in advance.

- Thomas

--
Thomas Hiller
Compaq Computer EMEA BV
SAP International Competence Center
LinuxLab



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
