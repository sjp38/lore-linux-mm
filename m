Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B60588D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 06:02:18 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/4] memcg: operate on page quantities internally
Date: Wed,  9 Feb 2011 12:01:49 +0100
Message-Id: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

this patch set converts the memcg charge and uncharge paths to operate
on multiples of pages instead of bytes.  It already was a good idea
before, but with the merge of THP we made a real mess by specifying
huge pages alternatingly in bytes or in number of regular pages.

If I did not miss anything, this should leave only res_counter and
user-visible stuff in bytes.  The ABI probably won't change, so next
up is converting res_counter to operate on page quantities.

	Hannes

 include/linux/sched.h |    4 +-
 mm/memcontrol.c       |  157 ++++++++++++++++++++++++-------------------------
 2 files changed, 78 insertions(+), 83 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
