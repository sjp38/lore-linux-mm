Received: from cs2p05.dial.cistron.nl ([62.216.3.70] helo=test.augan)
	by smtp.cistron.nl with esmtp (Exim 3.13 #1 (Debian))
	id 139se4-00042V-00
	for <linux-mm@kvack.org>; Wed, 05 Jul 2000 19:07:32 +0200
Received: from augan.com (IDENT:roman@serv2.augan [130.1.1.31])
	by test.augan (8.9.3/8.8.7) with ESMTP id TAA05774
	for <linux-mm@kvack.org>; Wed, 5 Jul 2000 19:06:59 +0200
Message-ID: <39636B33.81BD5EC6@augan.com>
Date: Wed, 05 Jul 2000 19:06:59 +0200
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: nice vmm test case
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I have a simple test case that is a nice example of bad mm perfomance
under load (I tested 2.2.16 and 2.4.0-test2, it makes no big
difference). I simply edit a large file with vi (25MB file on a 64MB
system) and watch the some vmm values in top. As a simple edit operation
I remove the first character of every line (or just type ":%s,^.,,").
The interesting point is when the virtual size of vi reaches the amount
of available memory, the perfomance drops immediatly and the system is
only busy with swapping. It's interesting to watch the SWAP and RSS
numbers, they constantly jump between 0 and 50MB.
This example also shows nicely which effect it has on interactive tasks,
if you watch the numbers of top itself (I changed the update delay to 1s
and sorted it by age, so it's easier to follow), top is also busy with
keeping it's own few pages in memory (under 2.4 top generates more page
faults than vi).
The right answer would be probably page aging, but I doubt to see that
in 2.4. Anyway, the swap_cnt in vmscan.c looks suspicious, maybe it's
initiliazed too high?

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
