Received: from northrelay01.pok.ibm.com (northrelay01.pok.ibm.com [9.117.200.21])
	by e1.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id MAA395590
	for <linux-mm@kvack.org>; Sat, 26 May 2001 12:36:26 -0400
Received: from d01ml233.pok.ibm.com (d01ml233.pok.ibm.com [9.117.200.63])
	by northrelay01.pok.ibm.com (8.8.8m3/NCO v4.96) with ESMTP id MAA227988
	for <linux-mm@kvack.org>; Sat, 26 May 2001 12:38:03 -0400
Message-ID: <OFC6E11B11.FF3CD6E0-ON85256A58.005AC313@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Sat, 26 May 2001 12:38:59 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Is it reasonable to assume that matching
alloc_pages/free_pages pairs will always have the same order
as the 2nd argument?

For example
pg = alloc_pages( , aorder);   free_pages(pg, forder);
Is (aorder == forder) always true?

Or, are there any bizarro drivers etc which will intentionally
free partial amounts, that is (forder < aorder)?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
