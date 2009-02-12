Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AA3C56B003D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 06:51:40 -0500 (EST)
Message-Id: <20090212113609.351980834@cmpxchg.org>
Date: Thu, 12 Feb 2009 12:36:09 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/2] vmscan: one cleanup, one bugfix
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

the first patch is from KOSAKI Motohiro, it moves the suspend-to-disk memory
shrinking functions to use sc.nr_reclaimed all over instead of maintaining
an extra local variable.

The second patch is a bugfix for shrink_all_memory() which currently does
reclaim more than requested because of setting swap_cluster_max once to our
overall reclaim goal but failing to decrease it while we go and reclaim is
making progress.  Added Nigel Cunningham to Cc because ISTR he complained
about exactly this behaviour.  Well, this patch seems to fix it, I even
added some shiny numbers coming from real tests!

	Hannes

 mm/vmscan.c |   51 ++++++++++++++++++++++++---------------------------
 1 files changed, 24 insertions(+), 27 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
