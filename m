Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5C24830D6
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 10:37:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so250476979pfg.1
        for <linux-mm@kvack.org>; Sun, 28 Aug 2016 07:37:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id sl8si33599929pab.264.2016.08.28.07.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Aug 2016 07:37:56 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7SEXcjS059173
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 10:37:56 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2537127vt0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 10:37:56 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 28 Aug 2016 15:37:54 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 724AE2190023
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 15:37:14 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7SEbpoD23921082
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 14:37:51 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7SEbpEx021778
	for <linux-mm@kvack.org>; Sun, 28 Aug 2016 08:37:51 -0600
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/3] userfaultfd: selftest: add event tests
Date: Sun, 28 Aug 2016 17:37:44 +0300
Message-Id: <1472395067-24538-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches add tests for userfaultfd events used in non-cooperative
scenario.
The tests verify that fork(), mremap() and madvise(MADV_DONTNEED) can be
properly handled when the process that monitors userfaultfd is not the
process that causes the pagefaults.

Mike Rapoport (3):
  userfaultfd: selftest: introduce userfaultfd_open
  userfaultfd: selftest: add ufd parameter to copy_page
  userfaultfd: selftest: add test for FORK, MADVDONTNEED and REMAP events

 tools/testing/selftests/vm/userfaultfd.c | 219 ++++++++++++++++++++++++++-----
 1 file changed, 189 insertions(+), 30 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
