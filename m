Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 932E482F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 17:30:26 -0500 (EST)
Received: by ykek133 with SMTP id k133so158595288yke.2
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 14:30:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j192si6550757vkf.28.2015.11.05.14.30.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 14:30:17 -0800 (PST)
Message-Id: <20151105223014.964111331@redhat.com>
Date: Thu, 05 Nov 2015 17:30:19 -0500
From: aris@redhat.com
Subject: [PATCH 5/5] mm: use KERN_DEBUG for dump_stack() during an OOM
References: <20151105223014.701269769@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=mm-reduce_priority_in_oom_dump_stack.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kerne@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

dump_stack() isn't always useful and in some scenarios OOMs can be quite
common and there's no need to flood the console with dump_stack()'s output.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Aristeu Rozanski <aris@redhat.com>

---
 mm/oom_kill.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.orig/mm/oom_kill.c	2015-10-27 09:24:01.014413690 -0400
+++ linux-2.6/mm/oom_kill.c	2015-11-05 14:51:31.091521337 -0500
@@ -384,7 +384,7 @@ pr_warning("%s invoked oom-killer: gfp_m
 		current->signal->oom_score_adj);
 	cpuset_print_task_mems_allowed(current);
 	task_unlock(current);
-	dump_stack();
+	dump_stack_lvl(KERN_DEBUG);
 	if (memcg)
 		mem_cgroup_print_oom_info(memcg, p);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
