Received: from northrelay02.pok.ibm.com (northrelay02.pok.ibm.com [9.117.200.22])
	by e1.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id NAA140474
	for <linux-mm@kvack.org>; Sat, 26 May 2001 13:08:09 -0400
Received: from d01ml233.pok.ibm.com (d01ml233.pok.ibm.com [9.117.200.63])
	by northrelay02.pok.ibm.com (8.8.8m3/NCO v4.96) with ESMTP id NAA188988
	for <linux-mm@kvack.org>; Sat, 26 May 2001 13:04:22 -0400
Subject: order of matching alloc_pages/free_pages call pairs.  Are they always same?
Message-ID: <OF5385EE96.412D8BDB-ON85256A58.005E44E7@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Sat, 26 May 2001 13:10:42 -0400
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
