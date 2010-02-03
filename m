Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 76DF46B004D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 10:25:53 -0500 (EST)
Received: by bwz9 with SMTP id 9so46623bwz.10
        for <linux-mm@kvack.org>; Wed, 03 Feb 2010 07:25:51 -0800 (PST)
Subject: [PATCH][mmotm-2010-02-01-16-25] Fix wrong accouting of anon and
 file
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Feb 2010 00:25:39 +0900
Message-ID: <1265210739.1052.36.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Unfortunately, Kame said he doesn't support this series.
I am not sure we need this patch or revert patch.

Who need this?

David. Do you want to remain this patch in mmotm for your OOM patch 
in future?

If anyone doesn't reply my question, Do we have to make revert patch?

== CUT_HERE == 

mm-count-lowmem-rss.patch added lowmem accouting.
But it changed file and rss accouting by mistake.
Unfortunately my review also doesn't found it.

This patch fixes it.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/memory.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 3becdc3..ce8ff9d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -210,14 +210,14 @@ void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
 
 unsigned long get_file_rss(struct mm_struct *mm)
 {
-	return get_mm_counter(mm, MM_ANONPAGES)
-		+ get_mm_counter(mm, MM_ANON_LOWPAGES);
+	return get_mm_counter(mm, MM_FILEPAGES)
+		+ get_mm_counter(mm, MM_FILE_LOWPAGES);
 }
 
 unsigned long get_anon_rss(struct mm_struct *mm)
 {
-	return get_mm_counter(mm, MM_FILEPAGES)
-		+ get_mm_counter(mm, MM_FILE_LOWPAGES);
+	return get_mm_counter(mm, MM_ANONPAGES)
+		+ get_mm_counter(mm, MM_ANON_LOWPAGES);
 }
 
 unsigned long get_low_rss(struct mm_struct *mm)
-- 
1.6.5



-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
