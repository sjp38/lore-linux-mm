Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A0C8B6B0266
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:32:56 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e23-v6so1917908oii.10
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:32:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c83-v6si1152484oia.350.2018.07.26.10.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 10:32:55 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6QHTfBP032665
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:32:55 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kfgduq1d4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:32:54 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Jul 2018 18:32:51 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v3 1/7] mm/util: make strndup_user description a kernel-doc comment
Date: Thu, 26 Jul 2018 20:32:34 +0300
In-Reply-To: <1532626360-16650-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532626360-16650-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532626360-16650-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

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
