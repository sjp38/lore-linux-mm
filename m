Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C46396B0006
	for <linux-mm@kvack.org>; Tue, 29 May 2018 06:13:55 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z7-v6so12317768wrg.11
        for <linux-mm@kvack.org>; Tue, 29 May 2018 03:13:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t37-v6si170530edh.161.2018.05.29.03.13.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 03:13:54 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4TADopM144243
	for <linux-mm@kvack.org>; Tue, 29 May 2018 06:13:52 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j94swra1g-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 May 2018 06:13:52 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 29 May 2018 11:13:45 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] docs/vm: move ksm and transhuge from "user" to "internals" section.
Date: Tue, 29 May 2018 13:13:38 +0300
Message-Id: <1527588818-7031-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

After the userspace interface description for KSM and THP was split to
Documentation/admin-guide/mm, the remaining parts belong to the section
describing MM internals.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/index.rst | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/index.rst b/Documentation/vm/index.rst
index 8e1cc66..c4ded22 100644
--- a/Documentation/vm/index.rst
+++ b/Documentation/vm/index.rst
@@ -13,8 +13,6 @@ various features of the Linux memory management
 .. toctree::
    :maxdepth: 1
 
-   ksm
-   transhuge
    swap_numa
    zswap
 
@@ -36,6 +34,7 @@ descriptions of data structures and algorithms.
    hmm
    hwpoison
    hugetlbfs_reserv
+   ksm
    mmu_notifier
    numa
    overcommit-accounting
@@ -45,6 +44,7 @@ descriptions of data structures and algorithms.
    remap_file_pages
    slub
    split_page_table_lock
+   transhuge
    unevictable-lru
    z3fold
    zsmalloc
-- 
2.7.4
