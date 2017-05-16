Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F12E6B03A0
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:35:20 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c202so18867664wme.10
        for <linux-mm@kvack.org>; Tue, 16 May 2017 03:35:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c2si1452352wrb.192.2017.05.16.03.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 03:35:18 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4GAT2Jr144583
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:35:17 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2afr98c6e3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:35:17 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 16 May 2017 11:35:15 +0100
From: "Mike Rapoport" <rppt@linux.vnet.ibm.com>
Subject: [PATCH] exit: don't include unused userfaultfd_k.h
Date: Tue, 16 May 2017 13:35:07 +0300
Message-Id: <1494930907-3060-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Commit dd0db88d8094 (userfaultfd: non-cooperative: rollback
userfaultfd_exit) removed userfaultfd callback from exit() which makes
include of <linux/userfaultfd_k.h> unnecessary.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 kernel/exit.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 516acdb..5b1dc84 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -51,7 +51,6 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/tracehook.h>
 #include <linux/fs_struct.h>
-#include <linux/userfaultfd_k.h>
 #include <linux/init_task.h>
 #include <linux/perf_event.h>
 #include <trace/events/sched.h>
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
