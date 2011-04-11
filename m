Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 401608D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 01:29:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 36AF13EE0C7
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:29:36 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1642945DE6F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:29:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E780745DE55
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:29:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D81961DB803F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:29:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B8A91DB803C
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 14:29:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [resend][patch 0/4 v3] oom: deadlock avoidance collection
Message-Id: <20110411142949.006C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 11 Apr 2011 14:29:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com

Hi,

Here is a resending of Andrey's oom livelock issue avoidance fixes.
Andrew, please let me know if you hope to route this one via my tree.

Thanks.



Changes from v2
 - no change.

KOSAKI Motohiro (4):
  vmscan: all_unreclaimable() use zone->all_unreclaimable as a name
  remove boost_dying_task_prio()
  mm: introduce wait_on_page_locked_killable
  x86,mm: make pagefault killable

 arch/x86/mm/fault.c     |   12 +++++++++++-
 include/linux/mm.h      |    1 +
 include/linux/pagemap.h |    9 +++++++++
 mm/filemap.c            |   42 +++++++++++++++++++++++++++++++++++-------
 mm/oom_kill.c           |   28 ----------------------------
 mm/vmscan.c             |   24 +++++++++++++-----------
 6 files changed, 69 insertions(+), 47 deletions(-)

-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
