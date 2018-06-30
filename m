Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5366B0003
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l17-v6so3042290edq.11
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 07:55:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a64-v6si146809ede.410.2018.06.30.07.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jun 2018 07:55:18 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5UErV0C010503
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:16 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jx4xkbm9r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:16 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sat, 30 Jun 2018 15:55:14 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 00/11] docs/mm: add boot time memory management docs
Date: Sat, 30 Jun 2018 17:54:55 +0300
Message-Id: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

Both bootmem and memblock have pretty good documentation coverage. With
some fixups and additions we get a nice overall description.

v2 changes:
* address Randy's comments

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
