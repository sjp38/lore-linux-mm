Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6DA6B02EE
	for <linux-mm@kvack.org>; Mon,  1 May 2017 01:43:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u96so10722343wrc.7
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 22:43:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k69si14874099wrc.185.2017.04.30.22.43.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 22:43:33 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v415hTax019914
	for <linux-mm@kvack.org>; Mon, 1 May 2017 01:43:31 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a5u3hxa3r-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 May 2017 01:43:31 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 1 May 2017 06:43:29 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH man-pages 1/5] ioctl_userfaultfd.2: update description of shared memory areas
Date: Mon,  1 May 2017 08:43:15 +0300
In-Reply-To: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1493617399-20897-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 man2/ioctl_userfaultfd.2 | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
index 889feb9..6edd396 100644
--- a/man2/ioctl_userfaultfd.2
+++ b/man2/ioctl_userfaultfd.2
@@ -181,8 +181,17 @@ virtual memory areas
 .TP
 .B UFFD_FEATURE_MISSING_SHMEM
 If this feature bit is set,
-the kernel supports registering userfaultfd ranges on tmpfs
-virtual memory areas
+the kernel supports registering userfaultfd ranges on shared memory areas.
+This includes all kernel shared memory APIs:
+System V shared memory,
+tmpfs,
+/dev/zero,
+.BR mmap(2)
+with
+.I MAP_SHARED
+flag set,
+.BR memfd_create (2),
+etc.
 
 The returned
 .I ioctls
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
