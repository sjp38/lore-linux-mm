Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 695FF6B028A
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s18-v6so2980861edr.15
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 04:26:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h7-v6si1696266edb.124.2018.07.25.04.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 04:26:31 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6PBPJ8G086245
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:29 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2keqphhb6p-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:29 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 25 Jul 2018 12:26:26 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 4/7] docs/core-api: move *{str,mem}dup* to "String Manipulation"
Date: Wed, 25 Jul 2018 14:26:07 +0300
In-Reply-To: <1532517970-16409-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532517970-16409-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532517970-16409-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The string and memory duplication routines fit better to the "String
Manipulation" section than to "The SLAB Cache".

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/core-api/kernel-api.rst | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/Documentation/core-api/kernel-api.rst b/Documentation/core-api/kernel-api.rst
index 25e9496..39f1460 100644
--- a/Documentation/core-api/kernel-api.rst
+++ b/Documentation/core-api/kernel-api.rst
@@ -39,6 +39,10 @@ String Manipulation
 .. kernel-doc:: lib/string.c
    :export:
 
+.. kernel-doc:: mm/util.c
+   :functions: kstrdup kstrdup_const kstrndup kmemdup kmemdup_nul memdup_user
+               vmemdup_user strndup_user memdup_user_nul
+
 Basic Kernel Library Functions
 ==============================
 
@@ -168,7 +172,7 @@ The Slab Cache
    :export:
 
 .. kernel-doc:: mm/util.c
-   :export:
+   :functions: kfree_const kvmalloc_node kvfree get_user_pages_fast
 
 User Space Memory Access
 ------------------------
-- 
2.7.4
