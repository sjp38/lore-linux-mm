Received: from northrelay02.pok.ibm.com (northrelay02.pok.ibm.com [9.117.200.22])
	by e4.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id RAA150886
	for <linux-mm@kvack.org>; Thu, 25 Jan 2001 17:08:20 -0500
Received: from d01ml233.pok.ibm.com (d01ml233.pok.ibm.com [9.117.200.63])
	by northrelay02.pok.ibm.com (8.8.8m3/NCO v4.95) with ESMTP id RAA38766
	for <linux-mm@kvack.org>; Thu, 25 Jan 2001 17:06:10 -0500
Subject: How do you determine PA in the X86_PAE mode.
Message-ID: <OF0A565D7B.D20E47EA-ON852569DF.00791D69@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Thu, 25 Jan 2001 17:09:40 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Given struct page * p, how do you determine the physical page number in the
CONFIG_X86_PAE mode?
Is it simply  (p - mem_map)  ?  Thanks for any suggestions.

Bulent Abali


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
