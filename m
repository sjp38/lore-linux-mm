Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7776B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 05:00:09 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f144so91071635pfa.3
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 02:00:09 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id q10si6378147pge.19.2017.01.20.02.00.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 02:00:08 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id y143so21537974pfb.0
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 02:00:08 -0800 (PST)
Date: Fri, 20 Jan 2017 02:00:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, oom: header nodemask is NULL when cpusets are disabled
 fix
In-Reply-To: <001801d272eb$ece5f460$c6b1dd20$@alibaba-inc.com>
Message-ID: <alpine.DEB.2.10.1701200158300.88321@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701181347320.142399@chino.kir.corp.google.com> <279f10c2-3eaa-c641-094f-3070db67d84f@suse.cz> <alpine.DEB.2.10.1701191454470.2381@chino.kir.corp.google.com> <001801d272eb$ece5f460$c6b1dd20$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Newline per Hillf

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1767e50844ac..51c091849dcb 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -408,7 +408,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 	if (oc->nodemask)
 		pr_cont("%*pbl", nodemask_pr_args(oc->nodemask));
 	else
-		pr_cont("(null)\n");
+		pr_cont("(null)");
 	pr_cont(",  order=%d, oom_score_adj=%hd\n",
 		oc->order, current->signal->oom_score_adj);
 	if (!IS_ENABLED(CONFIG_COMPACTION) && oc->order)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
