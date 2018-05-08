Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC1B56B000A
	for <linux-mm@kvack.org>; Tue,  8 May 2018 03:02:22 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o68so23145909qke.3
        for <linux-mm@kvack.org>; Tue, 08 May 2018 00:02:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l17-v6si2740642qvd.35.2018.05.08.00.02.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 00:02:21 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w486wskv040265
	for <linux-mm@kvack.org>; Tue, 8 May 2018 03:02:20 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hu6wf8kwp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 May 2018 03:02:20 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 8 May 2018 08:02:18 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/3] docs/vm: move numa_memory_policy.rst to admin-guide/mm
Date: Tue,  8 May 2018 10:02:07 +0300
Message-Id: <1525762930-28163-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches include minor formatting and spelling updates to
Documentation/vm/numa_memory_policy.rst and move this file to
Documentation/admin-guide/mm.

Mike Rapoport (3):
  docs/vm: numa_memory_policy: formatting and spelling updates
  docs/vm: numa_memory_policy: s/Linux memory policy/NUMA memory policy/
  docs/vm: move numa_memory_policy.rst to Documentation/admin-guide/mm

 Documentation/admin-guide/mm/hugetlbpage.rst       |  2 +-
 Documentation/admin-guide/mm/index.rst             |  1 +
 .../{vm => admin-guide/mm}/numa_memory_policy.rst  | 38 ++++++++++++++--------
 Documentation/filesystems/proc.txt                 |  2 +-
 Documentation/filesystems/tmpfs.txt                |  5 +--
 Documentation/vm/00-INDEX                          |  2 --
 Documentation/vm/index.rst                         |  1 -
 Documentation/vm/numa.rst                          |  2 +-
 8 files changed, 31 insertions(+), 22 deletions(-)
 rename Documentation/{vm => admin-guide/mm}/numa_memory_policy.rst (95%)

-- 
2.7.4
