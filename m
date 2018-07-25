Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6B99C6B0284
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:25 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r9-v6so2985645edh.14
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 04:26:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z14-v6si2313709edd.127.2018.07.25.04.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 04:26:24 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6PBOAEf047745
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:22 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2keq0ckhfg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:26:22 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 25 Jul 2018 12:26:20 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/7] mm/util: make strndup_user description a kernel-doc comment
Date: Wed, 25 Jul 2018 14:26:04 +0300
In-Reply-To: <1532517970-16409-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532517970-16409-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532517970-16409-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The description of the strndup_user function misses '*' character at the
beginning of the comment to be proper kernel-doc. Add the missing
character.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/util.c b/mm/util.c
index 3351659..6809014 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -196,7 +196,7 @@ void *vmemdup_user(const void __user *src, size_t len)
 }
 EXPORT_SYMBOL(vmemdup_user);
 
-/*
+/**
  * strndup_user - duplicate an existing string from user space
  * @s: The string to duplicate
  * @n: Maximum number of bytes to copy, including the trailing NUL.
-- 
2.7.4
