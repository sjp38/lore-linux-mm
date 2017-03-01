Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22EFF6B0388
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 00:17:29 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 67so37238497pfg.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 21:17:29 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d38si3634510pld.165.2017.02.28.21.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 21:17:28 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v215E8WB032806
	for <linux-mm@kvack.org>; Wed, 1 Mar 2017 00:17:27 -0500
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28wqtc8u6p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 Mar 2017 00:17:26 -0500
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 1 Mar 2017 05:17:24 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1.5/3] userfaultfd: documentation fixup after removal of UFFD_EVENT_EXIT
Date: Wed,  1 Mar 2017 07:17:17 +0200
In-Reply-To: <20170224181957.19736-1-aarcange@redhat.com>
References: <20170224181957.19736-1-aarcange@redhat.com>
Message-Id: <1488345437-4364-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
Hello Andrew,

It would be great if you can fold the patch below with the patch 1/3
(userfaultfd: non-cooperative: rollback userfaultfd_exit) 

 Documentation/vm/userfaultfd.txt | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/Documentation/vm/userfaultfd.txt b/Documentation/vm/userfaultfd.txt
index fe51a5a..d57e59c 100644
--- a/Documentation/vm/userfaultfd.txt
+++ b/Documentation/vm/userfaultfd.txt
@@ -172,10 +172,6 @@ the same read(2) protocol as for the page fault notifications. The
 manager has to explicitly enable these events by setting appropriate
 bits in uffdio_api.features passed to UFFDIO_API ioctl:
 
-UFFD_FEATURE_EVENT_EXIT - enable notification about exit() of the
-non-cooperative process. When the monitored process exits, the uffd
-manager will get UFFD_EVENT_EXIT.
-
 UFFD_FEATURE_EVENT_FORK - enable userfaultfd hooks for fork(). When
 this feature is enabled, the userfaultfd context of the parent process
 is duplicated into the newly created process. The manager receives
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
