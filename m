Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 63AE56B00BF
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 19:44:29 -0400 (EDT)
Received: by gyd8 with SMTP id 8so564931gyd.14
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 16:44:28 -0700 (PDT)
Subject: [PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
From: "Figo.zhang" <figo1802@gmail.com>
In-Reply-To: <1288662213.10103.2.camel@localhost.localdomain>
References: <1288662213.10103.2.camel@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Nov 2010 07:43:24 +0800
Message-ID: <1288827804.2725.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "rientjes@google.com" <rientjes@google.com>
List-ID: <linux-mm.kvack.org>


CAP_SYS_RESOURCE also had better get 3% bonus for protection.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
--- 
mm/oom_kill.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4029583..30b24b9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -198,7 +198,8 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 	 * Root processes get 3% bonus, just like the __vm_enough_memory()
 	 * implementation used by LSMs.
 	 */
-	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
+	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
+	    has_capability_noaudit(p, CAP_SYS_RESOURCE))
 		points -= 30;
 
 	/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
