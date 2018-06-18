Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD8886B0007
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:11 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id h12-v6so12393840wrq.2
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:00:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d28-v6si508980wmi.142.2018.06.18.10.00.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 10:00:10 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5IGwqgb021189
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:08 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jpfyv9y5q-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:08 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 18 Jun 2018 18:00:06 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 00/11] docs/mm: add boot time memory management docs
Date: Mon, 18 Jun 2018 19:59:48 +0300
Message-Id: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

Both bootmem and memblock have pretty good documentation coverage. With
some fixups and additions we get a nice overall description.

The last commit in the series that creates the boot-time-mm.rst depends on
the 'nodoc' sphix directive patch [1] I've sent earlier 

While working on the docs, I've noticed that both bootmem and nobootmem
implement some one-line wrappers for the core allocation methods as a
global functions rather than 'static inline'. I wonder whether I miss
something important here is it just a historic thing?

[1] https://marc.info/?l=linux-doc&m=152932901214922&w=2

Mike Rapoport (11):
  mm/bootmem: drop duplicated kernel-doc comments
  docs/mm: nobootmem: fixup kernel-doc comments
  docs/mm: bootmem: fix kernel-doc warnings
  docs/mm: bootmem: add kernel-doc description of 'struct bootmem_data'
  docs/mm: bootmem: add overview documentation
  mm/memblock: add a name for memblock flags enumeration
  docs/mm: memblock: update kernel-doc comments
  docs/mm: memblock: add kernel-doc comments for memblock_add[_node]
  docs/mm: memblock: add kernel-doc description for memblock types
  docs/mm: memblock: add overview documentation
  docs/mm: add description of boot time memory management

 Documentation/core-api/boot-time-mm.rst |  92 +++++++++++++++
 Documentation/core-api/index.rst        |   1 +
 include/linux/bootmem.h                 |  17 ++-
 include/linux/memblock.h                |  76 ++++++++----
 mm/bootmem.c                            | 159 +++++++++----------------
 mm/memblock.c                           | 203 +++++++++++++++++++++++---------
 mm/nobootmem.c                          |  20 +++-
 7 files changed, 380 insertions(+), 188 deletions(-)
 create mode 100644 Documentation/core-api/boot-time-mm.rst

-- 
2.7.4
