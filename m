Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 589626B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 01:43:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g23so68020702pfj.10
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 22:43:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d9si3385492pgn.218.2017.04.30.22.43.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 22:43:31 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v415hUFC029506
	for <linux-mm@kvack.org>; Mon, 1 May 2017 01:43:30 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a5x619fqu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 May 2017 01:43:30 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 1 May 2017 06:43:26 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH man-pages 0/5] {ioctl_}userfaultfd.2: yet another update
Date: Mon,  1 May 2017 08:43:14 +0300
Message-Id: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi Michael,

These updates pretty much complete the coverage of 4.11 additions, IMHO.

Mike Rapoport (5):
  ioctl_userfaultfd.2: update description of shared memory areas
  ioctl_userfaultfd.2: UFFDIO_COPY: add ENOENT and ENOSPC description
  ioctl_userfaultfd.2: add BUGS section
  userfaultfd.2: add note about asynchronios events delivery
  userfaultfd.2: update VERSIONS section with 4.11 chanegs

 man2/ioctl_userfaultfd.2 | 35 +++++++++++++++++++++++++++++++++--
 man2/userfaultfd.2       | 15 +++++++++++++++
 2 files changed, 48 insertions(+), 2 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
