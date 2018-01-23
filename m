Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 146CA800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:48:01 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id q63so19269683qtd.12
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 01:48:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m6si3833929qti.306.2018.01.23.01.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 01:48:00 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0N9ix8m026255
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:47:59 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fp2kr8ary-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:47:58 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 23 Jan 2018 09:47:57 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/3] mm: docs: trivial fixes
Date: Tue, 23 Jan 2018 11:47:48 +0200
Message-Id: <1516700871-22279-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-mm <linux-mm@kvack.org>, linux-doc <linux-doc@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These are some trvial fixes to the kernel-doc descriptions.

Mike Rapoport (3):
  mm: docs: fixup punctuation
  mm: docs: fix parameter names mismatch
  mm: docs: add blank lines to silence sphinx "Unexpected indentation" errors

 mm/bootmem.c           |  2 +-
 mm/ksm.c               |  2 +-
 mm/maccess.c           |  2 +-
 mm/memcontrol.c        |  6 +++---
 mm/mlock.c             |  2 +-
 mm/nommu.c             |  2 +-
 mm/pagewalk.c          |  1 +
 mm/process_vm_access.c |  4 +++-
 mm/sparse-vmemmap.c    |  4 ++--
 mm/swap.c              |  4 ++--
 mm/vmscan.c            |  1 +
 mm/z3fold.c            |  4 ++--
 mm/zbud.c              |  4 ++--
 mm/zpool.c             | 46 +++++++++++++++++++++++-----------------------
 14 files changed, 44 insertions(+), 40 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
