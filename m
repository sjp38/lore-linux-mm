Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B941E8D0039
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 10:17:34 -0500 (EST)
Received: by iyf13 with SMTP id 13so1913106iyf.14
        for <linux-mm@kvack.org>; Sun, 20 Feb 2011 07:17:30 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 0/2] memcg: migration clean up
Date: Mon, 21 Feb 2011 00:17:16 +0900
Message-Id: <cover.1298214672.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>

This patch cleans up memcg migration.
This patch sent Tue, Jan 11, 2011 but maybe Andrew was very busy so lost.
I resend with Acked-by and rebased on mmotm-2011-02-04.

Minchan Kim (2):
  memcg: remove unnecessary BUG_ON
  memcg: remove charge variable in unmap_and_move

 mm/memcontrol.c |    1 +
 mm/migrate.c    |   10 +++-------
 2 files changed, 4 insertions(+), 7 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
