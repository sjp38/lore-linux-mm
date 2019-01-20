Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6785E8E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 07:01:47 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id u20so17784870qtk.6
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 04:01:47 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x28si903196qvh.153.2019.01.20.04.01.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 04:01:46 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0KBsMZ3030645
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 07:01:46 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2q4jebdnm6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 07:01:45 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 20 Jan 2019 12:01:44 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 0/3] docs/core-api/mm: fix return value descriptions
Date: Sun, 20 Jan 2019 14:01:34 +0200
Message-Id: <1547985697-24588-1-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

Many kernel-doc comments referenced by Documentation/core-api/mm-api.rst
have the return value descriptions misformatted or lack it completely. This
makes kernel-doc script unhappy and produces more than 100 warnings when
running 

	make htmldocs V=1

These patches fix the formatting of present return value descriptions and
add some new ones.

Side note:
----------
I've noticed that kernel-doc produces

	warning: contents before sections

when it is parsing description of a function that has no parameters, but
does have a return value, i.e.

	unsigned long nr_free_buffer_pages(void)

As far as I can tell, the generated html is ok no matter if the detailed
description present before 'the sections', so probably this warning is not
really needed?

Mike Rapoport (3):
  docs/mm: vmalloc: re-indent kernel-doc comemnts
  docs/core-api/mm: fix user memory accessors formatting
  docs/core-api/mm: fix return value descriptions in mm/

 arch/x86/include/asm/uaccess.h |  24 +--
 arch/x86/lib/usercopy_32.c     |   8 +-
 mm/dmapool.c                   |  13 +-
 mm/filemap.c                   |  73 ++++++--
 mm/memory.c                    |  26 ++-
 mm/mempool.c                   |   8 +
 mm/page-writeback.c            |  24 ++-
 mm/page_alloc.c                |  24 ++-
 mm/readahead.c                 |   2 +
 mm/slab.c                      |  14 ++
 mm/slab_common.c               |   6 +
 mm/truncate.c                  |   6 +-
 mm/util.c                      |  37 ++--
 mm/vmalloc.c                   | 394 ++++++++++++++++++++++-------------------
 14 files changed, 409 insertions(+), 250 deletions(-)

-- 
2.7.4
