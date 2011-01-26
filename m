Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6B38D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 18:30:20 -0500 (EST)
From: Mandeep Singh Baines <msb@chromium.org>
Subject: [PATCH 6/6] taskstats: use appropriate printk priority level
Date: Wed, 26 Jan 2011 15:29:30 -0800
Message-Id: <1296084570-31453-7-git-send-email-msb@chromium.org>
In-Reply-To: <20110125235700.GR8008@google.com>
References: <20110125235700.GR8008@google.com>
Sender: owner-linux-mm@kvack.org
To: gregkh@suse.de, rjw@sisk.pl, mingo@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mandeep Singh Baines <msb@chromium.org>
List-ID: <linux-mm.kvack.org>

printk()s without a priority level default to KERN_WARNING. To reduce
noise at KERN_WARNING, this patch set the priority level appriopriately
for unleveled printks()s. This should be useful to folks that look at
dmesg warnings closely.

Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
---
 kernel/taskstats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index 3971c6b..9ffea36 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -685,7 +685,7 @@ static int __init taskstats_init(void)
 		goto err_cgroup_ops;
 
 	family_registered = 1;
-	printk("registered taskstats version %d\n", TASKSTATS_GENL_VERSION);
+	pr_info("registered taskstats version %d\n", TASKSTATS_GENL_VERSION);
 	return 0;
 err_cgroup_ops:
 	genl_unregister_ops(&family, &taskstats_ops);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
