Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14A7F6B02FA
	for <linux-mm@kvack.org>; Mon,  1 May 2017 01:43:42 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y106so10726497wrb.14
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 22:43:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k78si8430994wmd.66.2017.04.30.22.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 22:43:41 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v415hT3I019945
	for <linux-mm@kvack.org>; Mon, 1 May 2017 01:43:39 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a5u3hxa7a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 May 2017 01:43:39 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 1 May 2017 06:43:37 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH man-pages 5/5] userfaultfd.2: update VERSIONS section with 4.11 chanegs
Date: Mon,  1 May 2017 08:43:19 +0300
In-Reply-To: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1493617399-20897-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 man2/userfaultfd.2 | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
index f177bba..07a69f1 100644
--- a/man2/userfaultfd.2
+++ b/man2/userfaultfd.2
@@ -404,6 +404,9 @@ Insufficient kernel memory was available.
 The
 .BR userfaultfd ()
 system call first appeared in Linux 4.3.
+
+The support for hugetlbfs and shared memory areas and
+non-page-fault events was added in Linux 4.11
 .SH CONFORMING TO
 .BR userfaultfd ()
 is Linux-specific and should not be used in programs intended to be
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
