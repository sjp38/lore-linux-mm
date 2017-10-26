Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD906B025F
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:04:17 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k123so2350932qke.10
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 06:04:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t15si1092683qtg.216.2017.10.26.06.04.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 06:04:16 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9QD0Rpd038018
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:04:15 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dudc69j15-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:04:14 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Oct 2017 14:04:11 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] userfaultfd.2: document spurious UFFD_EVENT_FORK
Date: Thu, 26 Oct 2017 16:04:03 +0300
Message-Id: <1509023043-19872-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-man <linux-man@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 man2/userfaultfd.2 | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
index 1c9e64b..08c41e1 100644
--- a/man2/userfaultfd.2
+++ b/man2/userfaultfd.2
@@ -465,6 +465,16 @@ for checkpoint/restore mechanisms,
 as well as post-copy migration to allow (nearly) uninterrupted execution
 when transferring virtual machines and Linux containers
 from one host to another.
+.SH BUGS
+If the
+.B UFFD_FEATURE_EVENT_FORK
+is enabled and a system call from the
+.BR fork (2)
+family is interrupted by a signal or failed,q a stale userfaultfd descriptor
+might be created.
+In this case a spurious
+.B UFFD_EVENT_FORK
+will be delivered to the userfaultfd monitor.
 .SH EXAMPLE
 The program below demonstrates the use of the userfaultfd mechanism.
 The program creates two threads, one of which acts as the
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
