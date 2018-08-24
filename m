Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A80E6B2EC7
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 05:24:26 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id t23-v6so5632277pfe.20
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 02:24:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l189-v6sor1930957pgd.35.2018.08.24.02.24.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 02:24:25 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] tools/vm/page-types.c: fix "defined but not used" warning
Date: Fri, 24 Aug 2018 18:24:11 +0900
Message-Id: <1535102651-19418-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>

debugfs_known_mountpoints[] is not used any more, so let's remove it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 tools/vm/page-types.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git v4.18-mmotm-2018-08-17-15-48/tools/vm/page-types.c v4.18-mmotm-2018-08-17-15-48_patched/tools/vm/page-types.c
index 30cb0a0..37908a8 100644
--- v4.18-mmotm-2018-08-17-15-48/tools/vm/page-types.c
+++ v4.18-mmotm-2018-08-17-15-48_patched/tools/vm/page-types.c
@@ -159,12 +159,6 @@ static const char * const page_flag_names[] = {
 };
 
 
-static const char * const debugfs_known_mountpoints[] = {
-	"/sys/kernel/debug",
-	"/debug",
-	0,
-};
-
 /*
  * data structures
  */
-- 
2.7.0
