Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 367A69000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 14:10:58 -0400 (EDT)
Message-Id: <cover.1317110948.git.mhocko@suse.cz>
From: Michal Hocko <mhocko@suse.cz>
Date: Tue, 27 Sep 2011 10:09:08 +0200
Subject: [PATCH 0/2] oom: fix livelock when frozen task is selected
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <htejun@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Andrew,
this small patchset addresses a possible livelock when OOM killer tries
to kill a frozen task. The issue has been reported by Konstantin
Khlebnikov at https://lkml.org/lkml/2011/8/23/45.

The first patch addresses a possible issue in lguest which calls
try_to_freeze with user context and then continues with other work after
it returns from the fridge.

The second patch addresses the issue by thawing the frozen task in the
oom kill path.

Michal Hocko (2):
  lguest: move process freezing before pending signals check
  oom: do not live lock on frozen tasks

 drivers/lguest/core.c |   14 +++++++-------
 mm/oom_kill.c         |    6 ++++++
 2 files changed, 13 insertions(+), 7 deletions(-)

-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
