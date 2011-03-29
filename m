Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2408D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 06:39:19 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1DD8B3EE0BD
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:39:16 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E1D4545DE96
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:39:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C9C0445DE94
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:39:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BBC8EE18002
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:39:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 872D4E08002
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:39:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: oom: deadlock avoidance patches v2
Message-Id: <20110329193953.2B7E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 29 Mar 2011 19:39:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com

Hi,

Here is a updated patch of oom livelock avoidance series.



KOSAKI Motohiro (4):
  vmscan: all_unreclaimable() use zone->all_unreclaimable as the name
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
