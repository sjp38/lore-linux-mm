Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF0FC6B0003
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 14:00:00 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id 78so10752566qky.17
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 11:00:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i4si7692886qkh.401.2018.02.25.10.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Feb 2018 10:59:59 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1PIsGuo114087
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 13:59:59 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gbpm4rktx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 13:59:59 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 25 Feb 2018 18:59:57 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/3] mm: docs: more trivial updates
Date: Sun, 25 Feb 2018 20:59:48 +0200
Message-Id: <1519585191-10180-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-doc <linux-doc@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

Here's another set of (mostly) trivial updates for kernel-doc descriptions
in the mm code.

Mike Rapoport (3):
  mm/nommu: remove description of alloc_vm_area
  mm/swap: remove @cold parameter description for release_pages
  mm: kernel-doc: add missing parameter descriptions

 mm/cma.c            |  5 +++++
 mm/compaction.c     |  1 +
 mm/kmemleak.c       | 10 ++++++++++
 mm/memory_hotplug.c |  6 ++++++
 mm/nommu.c          | 12 ------------
 mm/oom_kill.c       |  2 ++
 mm/pagewalk.c       |  3 +++
 mm/rmap.c           |  1 +
 mm/swap.c           |  1 -
 mm/zsmalloc.c       |  2 ++
 10 files changed, 30 insertions(+), 13 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
