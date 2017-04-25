Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E17276B02FA
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:29 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p18so6703292wrb.22
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 09:29:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x8si4835515wmg.92.2017.04.25.09.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 09:29:28 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3PGSp5A093773
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:27 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a1v4s2f4x-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:27 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 25 Apr 2017 17:29:25 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 4/5] userfaultfd.2: add Linux container migration use-case to NOTES
Date: Tue, 25 Apr 2017 19:29:07 +0300
In-Reply-To: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1493137748-32452-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 man2/userfaultfd.2 | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
index c89484f..dc37319 100644
--- a/man2/userfaultfd.2
+++ b/man2/userfaultfd.2
@@ -279,7 +279,8 @@ signal and
 It can also be used to implement lazy restore
 for checkpoint/restore mechanisms,
 as well as post-copy migration to allow (nearly) uninterrupted execution
-when transferring virtual machines from one host to another.
+when transferring virtual machines and Linux containers
+from one host to another.
 .SH EXAMPLE
 The program below demonstrates the use of the userfaultfd mechanism.
 The program creates two threads, one of which acts as the
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
