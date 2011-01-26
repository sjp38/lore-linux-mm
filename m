Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7238D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 18:30:22 -0500 (EST)
From: Mandeep Singh Baines <msb@chromium.org>
Subject: [PATCH 3/6] PM: use appropriate printk priority level
Date: Wed, 26 Jan 2011 15:29:27 -0800
Message-Id: <1296084570-31453-4-git-send-email-msb@chromium.org>
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

Changed these messages to pr_info. But might be more appropriate as
pr_debug.

Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
---
 drivers/base/power/trace.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/base/power/trace.c b/drivers/base/power/trace.c
index 9f4258d..c80e138 100644
--- a/drivers/base/power/trace.c
+++ b/drivers/base/power/trace.c
@@ -112,7 +112,7 @@ static unsigned int read_magic_time(void)
 	unsigned int val;
 
 	get_rtc_time(&time);
-	printk("Time: %2d:%02d:%02d  Date: %02d/%02d/%02d\n",
+	pr_info("Time: %2d:%02d:%02d  Date: %02d/%02d/%02d\n",
 		time.tm_hour, time.tm_min, time.tm_sec,
 		time.tm_mon + 1, time.tm_mday, time.tm_year % 100);
 	val = time.tm_year;				/* 100 years */
@@ -179,7 +179,7 @@ static int show_file_hash(unsigned int value)
 		unsigned int hash = hash_string(lineno, file, FILEHASH);
 		if (hash != value)
 			continue;
-		printk("  hash matches %s:%u\n", file, lineno);
+		pr_info("  hash matches %s:%u\n", file, lineno);
 		match++;
 	}
 	return match;
@@ -255,7 +255,7 @@ static int late_resume_init(void)
 	val = val / FILEHASH;
 	dev = val /* % DEVHASH */;
 
-	printk("  Magic number: %d:%d:%d\n", user, file, dev);
+	pr_info("  Magic number: %d:%d:%d\n", user, file, dev);
 	show_file_hash(file);
 	show_dev_hash(dev);
 	return 0;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
