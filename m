Received: from dreambringer (znmeb.cust.aracnet.com [216.99.196.115])
	by franka.aracnet.com (8.12.5/8.12.5) with SMTP id h0M2pAU3006962
	for <linux-mm@kvack.org>; Tue, 21 Jan 2003 18:51:12 -0800
From: "M. Edward Borasky" <znmeb@aracnet.com>
Subject: Kernel panic with Red Hat 2-4-18 kernel
Date: Tue, 21 Jan 2003 18:57:44 -0800
Message-ID: <DEEBJHMCKLIHOCFBLNCCMEMGCDAA.znmeb@aracnet.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.50L.0301201933360.18171-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Is there a fix available for the following, generated on a 6 GB SMP P4 Xeon
system with the Red Hat 2.4.18 kernel?

Kernel panic: Fix pte_chain allocation, you lazy bastard!

I searched the web and found copious references in the context of 2.5, but
nothing in 2.4, Red Hat or otherwise.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
