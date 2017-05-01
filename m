Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0A45E6B02F2
	for <linux-mm@kvack.org>; Mon,  1 May 2017 01:43:36 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h65so6581472wmd.7
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 22:43:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a66si16165486wrc.296.2017.04.30.22.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 22:43:34 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v415hVgx140798
	for <linux-mm@kvack.org>; Mon, 1 May 2017 01:43:33 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a5n5qqx03-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 May 2017 01:43:33 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 1 May 2017 06:43:31 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH man-pages 2/5] ioctl_userfaultfd.2: UFFDIO_COPY: add ENOENT and ENOSPC description
Date: Mon,  1 May 2017 08:43:16 +0300
In-Reply-To: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1493617399-20897-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 man2/ioctl_userfaultfd.2 | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
index 6edd396..e12b9de 100644
--- a/man2/ioctl_userfaultfd.2
+++ b/man2/ioctl_userfaultfd.2
@@ -481,6 +481,19 @@ was invalid.
 An invalid bit was specified in the
 .IR mode
 field.
+.TP
+.B ENOENT
+(Since Linux 4.11)
+The faulting process has changed
+its virtual memory layout simultaneously with outstanding
+.I UFFDIO_COPY
+operation.
+.TP
+.B ENOSPC
+(Since Linux 4.11)
+The faulting process has exited at the time of
+.I UFFDIO_COPY
+operation.
 .\"
 .SS UFFDIO_ZEROPAGE
 (Since Linux 4.3.)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
