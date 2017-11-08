Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C2A974403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 01:54:19 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id 78so1333173qkz.13
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 22:54:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t30si410359qtg.264.2017.11.07.22.54.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 22:54:18 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA86qwBP127692
	for <linux-mm@kvack.org>; Wed, 8 Nov 2017 01:54:17 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2e3ptnh96b-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Nov 2017 01:54:17 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 8 Nov 2017 06:54:15 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] userfaultfd.2: document spurious UFFD_EVENT_FORK
Date: Wed,  8 Nov 2017 08:54:08 +0200
Message-Id: <1510124048-7991-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-man@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

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
