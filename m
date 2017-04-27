Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1257C6B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 10:14:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k57so3236216wrk.6
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 07:14:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v21si464011wrd.319.2017.04.27.07.14.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 07:14:45 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3REDoQa100625
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 10:14:44 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a3a4epsuw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 10:14:44 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 15:14:41 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH man-pages 0/2] some more userfault pages updates
Date: Thu, 27 Apr 2017 17:14:32 +0300
Message-Id: <1493302474-4701-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi Michael,

Here are some more updates to {ioctl_}userfaultfd.2 pages.

Mike Rapoport (2):
  userfaultfd.2: start documenting non-cooperative events
  ioctl_userfaultfd.2: start adding details about userfaultfd features

 man2/ioctl_userfaultfd.2 |  53 ++++++++++++++++++-
 man2/userfaultfd.2       | 135 ++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 179 insertions(+), 9 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
