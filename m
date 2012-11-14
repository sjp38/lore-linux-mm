Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id C30C46B0087
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 04:15:27 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so261685pbc.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 01:15:27 -0800 (PST)
Date: Wed, 14 Nov 2012 01:15:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3/4] mm, oom: remove redundant sleep in pagefault oom
 handler
In-Reply-To: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1211140113200.32125@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

out_of_memory() will already cause current to schedule if it has not been
killed, so doing it again in pagefault_out_of_memory() is redundant.
Remove it.

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -683,5 +683,4 @@ void pagefault_out_of_memory(void)
 		out_of_memory(NULL, 0, 0, NULL, false);
 		clear_zonelist_oom(zonelist, GFP_KERNEL);
 	}
-	schedule_timeout_killable(1);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
