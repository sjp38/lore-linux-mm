Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8E26B7C48
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 16:13:19 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id g188so1021557pgc.22
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 13:13:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n11-v6si1153018plg.300.2018.12.06.13.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 13:13:18 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB6LAkXC021620
	for <linux-mm@kvack.org>; Thu, 6 Dec 2018 16:13:18 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p79kx5693-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Dec 2018 16:13:17 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 6 Dec 2018 21:13:15 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 2/2] docs/mm-api: link slab_common.c to "The Slab Cache" section
Date: Thu,  6 Dec 2018 23:13:01 +0200
In-Reply-To: <1544130781-13443-1-git-send-email-rppt@linux.ibm.com>
References: <1544130781-13443-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1544130781-13443-3-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

Several functions in mm/slab_common.c have kernel-doc comments, it makes
perfect sense to link them to the MM API reference.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 Documentation/core-api/mm-api.rst | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/Documentation/core-api/mm-api.rst b/Documentation/core-api/mm-api.rst
index c81e754..aa8e54b8 100644
--- a/Documentation/core-api/mm-api.rst
+++ b/Documentation/core-api/mm-api.rst
@@ -46,6 +46,9 @@ The Slab Cache
 .. kernel-doc:: mm/slab.c
    :export:
 
+.. kernel-doc:: mm/slab_common.c
+   :export:
+
 .. kernel-doc:: mm/util.c
    :functions: kfree_const kvmalloc_node kvfree
 
-- 
2.7.4
