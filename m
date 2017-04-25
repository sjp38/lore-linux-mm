Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 771D66B02EE
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:25 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 67so87126435ite.6
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 09:29:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a21si5231878ita.125.2017.04.25.09.29.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 09:29:24 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3PGSs87018992
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:24 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a24a4h4ms-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:23 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 25 Apr 2017 17:29:21 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/5] ioctl_userfaultfd.2: describe memory types that can be used from 4.11
Date: Tue, 25 Apr 2017 19:29:05 +0300
In-Reply-To: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1493137748-32452-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 man2/ioctl_userfaultfd.2 | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
index 66fbfdc..78abc4d 100644
--- a/man2/ioctl_userfaultfd.2
+++ b/man2/ioctl_userfaultfd.2
@@ -169,11 +169,15 @@ field was not zero.
 (Since Linux 4.3.)
 Register a memory address range with the userfaultfd object.
 The pages in the range must be "compatible".
-In the current implementation,
-.\" According to Mike Rapoport, this will change in Linux 4.11.
+
+Up to Linux kernel 4.11,
 only private anonymous ranges are compatible for registering with
 .BR UFFDIO_REGISTER .
 
+Since Linux 4.11,
+hugetlbfs and shared memory ranges are also compatible with
+.BR UFFDIO_REGISTER .
+
 The
 .I argp
 argument is a pointer to a
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
