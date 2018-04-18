Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2F336B000A
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:08 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y10-v6so923769wrg.9
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 01:08:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e11si969776edl.437.2018.04.18.01.08.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 01:08:07 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3I85sms113441
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:06 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2he24qrd2y-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:05 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 18 Apr 2018 09:08:04 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/7] docs/vm: hugetlbpage: move section about kernel development to hugetlbfs_reserv
Date: Wed, 18 Apr 2018 11:07:45 +0300
In-Reply-To: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524038870-413-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@infradead.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The hugetlbpage describes hugetlbfs from the user perspective and newer
hugetlbfs_reserv document targets kernel developers. Hence the section
about hugetlbfs kernel development naturally belongs there.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/hugetlbfs_reserv.rst | 8 ++++++++
 Documentation/vm/hugetlbpage.rst      | 8 --------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/Documentation/vm/hugetlbfs_reserv.rst b/Documentation/vm/hugetlbfs_reserv.rst
index 36a87a2..9d20076 100644
--- a/Documentation/vm/hugetlbfs_reserv.rst
+++ b/Documentation/vm/hugetlbfs_reserv.rst
@@ -583,5 +583,13 @@ of cpusets or memory policy there is no guarantee that huge pages will be
 available on the required nodes.  This is true even if there are a sufficient
 number of global reservations.
 
+Hugetlbfs regression testing
+============================
 
+The most complete set of hugetlb tests are in the libhugetlbfs repository.
+If you modify any hugetlb related code, use the libhugetlbfs test suite
+to check for regressions.  In addition, if you add any new hugetlb
+functionality, please add appropriate tests to libhugetlbfs.
+
+--
 Mike Kravetz, 7 April 2017
diff --git a/Documentation/vm/hugetlbpage.rst b/Documentation/vm/hugetlbpage.rst
index 99ad5d9..2b374d1 100644
--- a/Documentation/vm/hugetlbpage.rst
+++ b/Documentation/vm/hugetlbpage.rst
@@ -379,11 +379,3 @@ The `libhugetlbfs`_  library provides a wide range of userspace tools
 to help with huge page usability, environment setup, and control.
 
 .. _libhugetlbfs: https://github.com/libhugetlbfs/libhugetlbfs
-
-Kernel development regression testing
-=====================================
-
-The most complete set of hugetlb tests are in the libhugetlbfs repository.
-If you modify any hugetlb related code, use the libhugetlbfs test suite
-to check for regressions.  In addition, if you add any new hugetlb
-functionality, please add appropriate tests to libhugetlbfs.
-- 
2.7.4
