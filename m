Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3980C6B7C45
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 16:13:14 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so1042900pgq.9
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 13:13:14 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b11si1007151pgb.536.2018.12.06.13.13.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 13:13:12 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB6LAYZw038349
	for <linux-mm@kvack.org>; Thu, 6 Dec 2018 16:13:12 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p79k9vqaf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Dec 2018 16:13:12 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 6 Dec 2018 21:13:09 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 0/2] docs/mm-api: link kernel-doc comments from slab_common.c
Date: Thu,  6 Dec 2018 23:12:59 +0200
Message-Id: <1544130781-13443-1-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

Hi,

These patches update formatting of function descriptions in
mm/slab_common.c and link the comments from this file to "The Slab Cache"
section of the MM API reference.

As the changes to mm/slab_common.c only touch the comments, I think these
patches can go via the docs tree.

Mike Rapoport (2):
  slab: make kmem_cache_create{_usercopy} description proper kernel-doc
  docs/mm-api: link slab_common.c to "The Slab Cache" section

 Documentation/core-api/mm-api.rst |  3 +++
 mm/slab_common.c                  | 35 +++++++++++++++++++++++++++++++----
 2 files changed, 34 insertions(+), 4 deletions(-)

-- 
2.7.4
