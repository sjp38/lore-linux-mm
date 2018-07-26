Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE966B0274
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:33:12 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j189-v6so1904886oih.11
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:33:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m83-v6si1339711oik.0.2018.07.26.10.33.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 10:33:10 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6QHSodn015106
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:33:10 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kfhj3be8w-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:33:09 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Jul 2018 18:33:07 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v3 7/7] docs/core-api: mm-api: add section about GFP flags
Date: Thu, 26 Jul 2018 20:32:40 +0300
In-Reply-To: <1532626360-16650-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532626360-16650-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532626360-16650-8-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/core-api/mm-api.rst | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/Documentation/core-api/mm-api.rst b/Documentation/core-api/mm-api.rst
index b5913aa..46ae353 100644
--- a/Documentation/core-api/mm-api.rst
+++ b/Documentation/core-api/mm-api.rst
@@ -14,6 +14,27 @@ User Space Memory Access
 .. kernel-doc:: mm/util.c
    :functions: get_user_pages_fast
 
+Memory Allocation Controls
+==========================
+
+Functions which need to allocate memory often use GFP flags to express
+how that memory should be allocated. The GFP acronym stands for "get
+free pages", the underlying memory allocation function. Not every GFP
+flag is allowed to every function which may allocate memory. Most
+users will want to use a plain ``GFP_KERNEL``.
+
+.. kernel-doc:: include/linux/gfp.h
+   :doc: Page mobility and placement hints
+
+.. kernel-doc:: include/linux/gfp.h
+   :doc: Watermark modifiers
+
+.. kernel-doc:: include/linux/gfp.h
+   :doc: Reclaim modifiers
+
+.. kernel-doc:: include/linux/gfp.h
+   :doc: Common combinations
+
 The Slab Cache
 ==============
 
-- 
2.7.4
