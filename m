Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 39E5A6B0317
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:34 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id l196so236026965ioe.19
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 09:29:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 202si5129631itv.105.2017.04.25.09.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 09:29:33 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3PGT3Kd058394
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:32 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a1qnxk8cu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:32 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 25 Apr 2017 17:29:30 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 5/5] usefaultfd.2: add brief description of "non-cooperative" mode
Date: Tue, 25 Apr 2017 19:29:08 +0300
In-Reply-To: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1493137748-32452-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 man2/userfaultfd.2 | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
index dc37319..291dd10 100644
--- a/man2/userfaultfd.2
+++ b/man2/userfaultfd.2
@@ -89,6 +89,20 @@ them using the operations described in
 .BR ioctl_userfaultfd (2).
 When servicing the page fault events,
 the fault-handling thread can trigger a wake-up for the sleeping thread.
+
+It is possible for the faulting threads and the fault-handling threads
+to run in the context of different processes.
+In this case, these threads may belong to different programs,
+and the program that executes the faulting threads
+will not necessarily cooperate with the program that handles the page faults.
+In such non-cooperative mode,
+the process that monitors userfaultfd and handles page faults,
+needs to be aware of the changes in the virtual memory layout
+of the faulting process to avoid memory corruption.
+.\" FIXME elaborate about non-cooperating mode, describe its limitations
+.\" for kerneles before 4.11, features added in 4.11
+.\" and limitations remaining in 4.11
+.\" Maybe it's worth adding a dedicated sub-section...
 .\"
 .SS Userfaultfd operation
 After the userfaultfd object is created with
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
