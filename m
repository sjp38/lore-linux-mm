Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA03164
	for <linux-mm@kvack.org>; Tue, 10 Mar 1998 04:01:57 -0500
Received: from mirkwood.dummy.home (root@anx1p4.fys.ruu.nl [131.211.33.93])
	by max.fys.ruu.nl (8.8.7/8.8.7/hjm) with ESMTP id KAA29730
	for <linux-mm@kvack.org>; Tue, 10 Mar 1998 10:01:49 +0100 (MET)
Date: Mon, 9 Mar 1998 22:27:21 -0500 (EST)
Message-Id: <199803100327.WAA10336@saturn.cs.uml.edu>
From: "Albert D. Cahalan" <acahalan@cs.uml.edu>
Subject: VM info
ReSent-To: linux-mm <linux-mm@kvack.org>
ReSent-Message-ID: <Pine.LNX.3.91.980310094858.12682C@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
List-ID: <linux-mm.kvack.org>



Please forward this to the VM mailing list you have. This is a list
of some things that /bin/ps needs to know about for proper output.
Some of them might help you too.

Digital Unix formats:
JOBC    Current count of processes qualifying PGID for job control
CP      Short-term CPU utilization factor (used in scheduling)
SL      Sleep time                                     

FreeBSD formats:
JOBC    job control count
CPU     short-term cpu usage factor (for scheduling)
SL      sleep time (in seconds; 127 = infinity)
RE      core residency time (in seconds; 127 = infinity)
