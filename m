Received: from chiara.elte.hu (chiara.elte.hu [157.181.150.200])
	by mx2.elte.hu (Postfix) with ESMTP id 1DF024856C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2002 15:14:09 +0100 (CET)
Date: Tue, 5 Feb 2002 17:11:56 +0100 (CET)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: <mingo@elte.hu>
Subject: [patch] O(1) scheduler -K2 for rmap 12c
Message-ID: <Pine.LNX.4.33.0202051708280.13312-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

a number of people have expressed interest in running both the rmap patch
and the O(1) scheduler, but Rik's patch touches sched.h in nonobvious ways
which collides with the O(1) scheduler patch. I've uploaded the following
merge:

  http://redhat.com/~mingo/O(1)-scheduler/sched-O1-2.4.17-rmap-12c-K2.patch

this patch should be applied after applying 2.4.17-rmap-12c.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
