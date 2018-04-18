Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8216B0007
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z7-v6so910010wrg.11
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 01:08:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j10si875051edk.263.2018.04.18.01.08.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 01:08:01 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3I85rp0113429
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:00 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2he24qrcwq-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:07:59 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 18 Apr 2018 09:07:58 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/7]  docs/vm: start moving files do Documentation/admin-guide`
Date: Wed, 18 Apr 2018 11:07:43 +0300
Message-Id: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@infradead.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These pacthes begin categorizing memory management documentation.  The
documents that describe userspace APIs and do not overload the reader with
implementation details can be moved to Documentation/admin-guide, so let's
do it :)

Mike Rapoport (7):
  docs/vm: hugetlbpage: minor improvements
  docs/vm: hugetlbpage: move section about kernel development to
    hugetlbfs_reserv
  docs/vm: pagemap: formatting and spelling updates
  docs/vm: pagemap: change document title
  docs/admin-guide: introduce basic index for mm documentation
  docs/admin-guide/mm: start moving here files from Documentation/vm
  docs/admin-guide/mm: convert plain text cross references to hyperlinks

 Documentation/ABI/stable/sysfs-devices-node        |  2 +-
 .../ABI/testing/sysfs-kernel-mm-hugepages          |  2 +-
 Documentation/admin-guide/index.rst                |  1 +
 .../{vm => admin-guide/mm}/hugetlbpage.rst         | 28 +++++++--------
 .../{vm => admin-guide/mm}/idle_page_tracking.rst  |  5 +--
 Documentation/admin-guide/mm/index.rst             | 28 +++++++++++++++
 Documentation/{vm => admin-guide/mm}/pagemap.rst   | 40 ++++++++++++----------
 .../{vm => admin-guide/mm}/soft-dirty.rst          |  0
 .../{vm => admin-guide/mm}/userfaultfd.rst         |  0
 Documentation/filesystems/proc.txt                 |  6 ++--
 Documentation/sysctl/vm.txt                        |  4 +--
 Documentation/vm/00-INDEX                          | 10 ------
 Documentation/vm/hugetlbfs_reserv.rst              |  8 +++++
 Documentation/vm/hwpoison.rst                      |  2 +-
 Documentation/vm/index.rst                         |  5 ---
 fs/Kconfig                                         |  2 +-
 fs/proc/task_mmu.c                                 |  4 +--
 mm/Kconfig                                         |  5 +--
 18 files changed, 89 insertions(+), 63 deletions(-)
 rename Documentation/{vm => admin-guide/mm}/hugetlbpage.rst (95%)
 rename Documentation/{vm => admin-guide/mm}/idle_page_tracking.rst (96%)
 create mode 100644 Documentation/admin-guide/mm/index.rst
 rename Documentation/{vm => admin-guide/mm}/pagemap.rst (83%)
 rename Documentation/{vm => admin-guide/mm}/soft-dirty.rst (100%)
 rename Documentation/{vm => admin-guide/mm}/userfaultfd.rst (100%)

-- 
2.7.4
