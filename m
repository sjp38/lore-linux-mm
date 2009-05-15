Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7CE5D6B0055
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:00:23 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/11] mm: Convert #ifdef DEBUG printk(KERN_DEBUG to pr_debug(
Date: Fri, 15 May 2009 10:59:45 -0700
Message-Id: <d2d789905b3ec219d015729a162be7707564fb67.1242407227.git.joe@perches.com>
In-Reply-To: <cover.1242407227.git.joe@perches.com>
References: <cover.1242407227.git.joe@perches.com>
In-Reply-To: <cover.1242407227.git.joe@perches.com>
References: <cover.1242407227.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, James Morris <jmorris@namei.org>, David Rientjes <rientjes@google.com>, Serge Hallyn <serue@us.ibm.com>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Joe Perches <joe@perches.com>

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/oom_kill.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 92bcf1d..8f7fb51 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -159,10 +159,8 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 			points >>= -(p->oomkilladj);
 	}
 
-#ifdef DEBUG
-	printk(KERN_DEBUG "OOMkill: task %d (%s) got %lu points\n",
-	p->pid, p->comm, points);
-#endif
+	pr_debug("OOMkill: task %d (%s) got %lu points\n",
+		 p->pid, p->comm, points);
 	return points;
 }
 
-- 
1.6.3.1.9.g95405b.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
