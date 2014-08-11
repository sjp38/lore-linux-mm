Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id C642D6B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 07:23:46 -0400 (EDT)
Received: by mail-yk0-f169.google.com with SMTP id 131so5857609ykp.28
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 04:23:46 -0700 (PDT)
Received: from mail-yh0-x22f.google.com (mail-yh0-x22f.google.com [2607:f8b0:4002:c01::22f])
        by mx.google.com with ESMTPS id t32si12980187yhi.164.2014.08.11.04.23.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 04:23:46 -0700 (PDT)
Received: by mail-yh0-f47.google.com with SMTP id f10so6158261yha.20
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 04:23:46 -0700 (PDT)
From: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
Subject: [PATCH] mm: ksm: Remove unused function process_timeout()
Date: Mon, 11 Aug 2014 08:22:45 -0300
Message-Id: <1407756165-1906-1-git-send-email-mopsfelder@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Murilo Opsfelder Araujo <mopsfelder@gmail.com>

This patch fixes compilation warning:

mm/ksm.c:1711:13: warning: a??process_timeouta?? defined but not used [-Wunused-function]

Signed-off-by: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
---
 mm/ksm.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index f7de4c0..434a50a 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1708,11 +1708,6 @@ static void ksm_do_scan(unsigned int scan_npages)
 	}
 }
 
-static void process_timeout(unsigned long __data)
-{
-	wake_up_process((struct task_struct *)__data);
-}
-
 static int ksmd_should_run(void)
 {
 	return (ksm_run & KSM_RUN_MERGE) && !list_empty(&ksm_mm_head.mm_list);
-- 
2.1.0.rc1.204.gae8bc8d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
