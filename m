Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0359B8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 09:04:16 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: 
Date: Mon, 31 Jan 2011 15:03:52 +0100
Message-Id: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

these three patches are small fixes for urgent issues with memory
cgroups and transparent huge pages.  They are inspired by 4/7 of
KAMEZAWA-san's recent series 'memcg : more fixes and clean up for
2.6.28-rc' to make memory cgroups work with THP.

2/3 fixes a bug that is first uncovered through 1/3.  Minchan
suggested this order for review purposes, but they should probably be
applied the other way round (2, then 1) for better bisectability.

If everybody agrees, I would prefer these going into -mmotm now, and
have further cleanups and optimizations based on them.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
