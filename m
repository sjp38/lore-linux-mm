Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4706F6B02EE
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p133so7218513wmd.17
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 09:29:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t190si4231920wme.80.2017.04.25.09.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 09:29:21 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3PGSq5b093872
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:20 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a1v4s2ew1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:19 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 25 Apr 2017 17:29:17 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/5] userfaultfd.2: describe memory types that can be used from 4.11
Date: Tue, 25 Apr 2017 19:29:04 +0300
In-Reply-To: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1493137748-32452-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 man2/userfaultfd.2 | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
index 1603c20..c89484f 100644
--- a/man2/userfaultfd.2
+++ b/man2/userfaultfd.2
@@ -130,8 +130,12 @@ Details of the various
 operations can be found in
 .BR ioctl_userfaultfd (2).
 
-Currently, userfaultfd can be used only with anonymous private memory
-mappings.
+Up to Linux 4.11,
+userfaultfd can be used only with anonymous private memory mappings.
+
+Since Linux 4.11,
+userfaultfd can be also used with hugetlbfs and shared memory mappings.
+
 .\"
 .SS Reading from the userfaultfd structure
 Each
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
