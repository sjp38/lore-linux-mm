Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA836B0315
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:31 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id m132so87144461ith.17
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 09:29:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f91si94442iod.190.2017.04.25.09.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 09:29:30 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3PGTMEb025659
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:29 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a28hfcw7w-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:28 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 25 Apr 2017 17:29:14 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/5] {ioctl_}userfaultfd.2: initial updates for 4.11
Date: Tue, 25 Apr 2017 19:29:03 +0300
Message-Id: <1493137748-32452-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hello Michael,

These patches are some kind of brief highlights of the changes to the
userfaultfd pages.
The changes to userfaultfd functionality are also described at update to
Documentation/vm/userfaultfd.txt [1].

In general, there were three major additions:
* hugetlbfs support
* shmem support
* non-page fault events

I think we should add some details about using userfaultfd with different
memory types, describe meaning of each feature bits and add some text about
the new events.

I haven't updated 'struct uffd_msg' yet, and I hesitate whether it's
description belongs to userfaultfd.2 or ioctl_userfaultfd.2

As for the userfaultfd.7 we've discussed earlier, I believe it would
repeat Documentation/vm/userfaultfd.txt in way, so I'm not really sure it
is required.

--
Sincerely yours,
Mike.

[1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=5a02026d390ea1bb0c16a0e214e45613a3e3d885

Mike Rapoport (5):
  userfaultfd.2: describe memory types that can be used from 4.11
  ioctl_userfaultfd.2: describe memory types that can be used from 4.11
  ioctl_userfaultfd.2: update UFFDIO_API description
  userfaultfd.2: add Linux container migration use-case to NOTES
  usefaultfd.2: add brief description of "non-cooperative" mode

 man2/ioctl_userfaultfd.2 | 46 ++++++++++++++++++++++++++++++++++++++--------
 man2/userfaultfd.2       | 25 ++++++++++++++++++++++---
 2 files changed, 60 insertions(+), 11 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
