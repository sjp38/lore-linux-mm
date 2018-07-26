Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C36E6B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:22:15 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b8-v6so1231350oib.4
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 05:22:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w72-v6si853956oif.253.2018.07.26.05.22.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 05:22:14 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6QCJGRe133457
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:22:13 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kfe1k8j5y-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:22:13 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Jul 2018 13:22:11 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 1/7] mm/util: make strndup_user description a kernel-doc comment
Date: Thu, 26 Jul 2018 15:21:56 +0300
In-Reply-To: <1532607722-17079-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532607722-17079-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532607722-17079-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

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
