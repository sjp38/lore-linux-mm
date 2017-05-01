Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0686B02F4
	for <linux-mm@kvack.org>; Mon,  1 May 2017 01:43:39 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q25so68090392pfg.6
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 22:43:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s65si13371220pgb.37.2017.04.30.22.43.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 22:43:38 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v415hXul057161
	for <linux-mm@kvack.org>; Mon, 1 May 2017 01:43:37 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a5sbb97s5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 May 2017 01:43:37 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 1 May 2017 06:43:35 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH man-pages 4/5] userfaultfd.2: add note about asynchronios events delivery
Date: Mon,  1 May 2017 08:43:18 +0300
In-Reply-To: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1493617399-20897-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 man2/userfaultfd.2 | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
index 8b89162..f177bba 100644
--- a/man2/userfaultfd.2
+++ b/man2/userfaultfd.2
@@ -112,6 +112,18 @@ created for the child process,
 which allows userfaultfd monitor to perform user-space paging
 for the child process.
 
+Unlike page faults which have to be synchronous and require
+explicit or implicit wakeup,
+all other events are delivered asynchronously and
+the non-cooperative process resumes execution as
+soon as manager executes
+.BR read(2).
+The userfaultfd manager should carefully synchronize calls
+to UFFDIO_COPY with the events processing.
+
+The current asynchronous model of the event delivery is optimal for
+single threaded non-cooperative userfaultfd manager implementations.
+
 .\" FIXME elaborate about non-cooperating mode, describe its limitations
 .\" for kernels before 4.11, features added in 4.11
 .\" and limitations remaining in 4.11
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
