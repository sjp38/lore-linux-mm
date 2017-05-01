Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C13B06B02F3
	for <linux-mm@kvack.org>; Mon,  1 May 2017 01:43:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so6616652wme.16
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 22:43:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r66si7674632wma.48.2017.04.30.22.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 22:43:36 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v415hUVN078798
	for <linux-mm@kvack.org>; Mon, 1 May 2017 01:43:35 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a5vuxbmet-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 May 2017 01:43:35 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 1 May 2017 06:43:33 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH man-pages 3/5] ioctl_userfaultfd.2: add BUGS section
Date: Mon,  1 May 2017 08:43:17 +0300
In-Reply-To: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1493617399-20897-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The features handshake is not quite convenient.
Elaborate about it in the BUGS section.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 man2/ioctl_userfaultfd.2 | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
index e12b9de..50316de 100644
--- a/man2/ioctl_userfaultfd.2
+++ b/man2/ioctl_userfaultfd.2
@@ -650,6 +650,15 @@ operations are Linux-specific.
 .SH EXAMPLE
 See
 .BR userfaultfd (2).
+.SH BUGS
+In order to detect available userfault features and
+enable certain subset of those features
+the usefault file descriptor must be closed after the first
+.BR UFFDIO_API
+operation that queries features availability and re-opened before
+the second
+.BR UFFDIO_API
+call that actually enables the desired features.
 .SH SEE ALSO
 .BR ioctl (2),
 .BR mmap (2),
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
