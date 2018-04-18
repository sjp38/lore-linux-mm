Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3872B6B000C
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:14 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id q10-v6so609351qtp.18
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 01:08:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z22-v6si948770qto.12.2018.04.18.01.08.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 01:08:13 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3I885Ft098349
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:12 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hdy1yge8j-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:12 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 18 Apr 2018 09:08:09 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 4/7] docs/vm: pagemap: change document title
Date: Wed, 18 Apr 2018 11:07:47 +0300
In-Reply-To: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524038870-413-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@infradead.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

"pagemap from the Userspace Perspective" is not very descriptive for
unaware readers. Since the document describes how to examine a process page
tables, let's title it "Examining Process Page Tables"

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/pagemap.rst | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/vm/pagemap.rst b/Documentation/vm/pagemap.rst
index 9644bc0..7ba8cbd 100644
--- a/Documentation/vm/pagemap.rst
+++ b/Documentation/vm/pagemap.rst
@@ -1,8 +1,8 @@
 .. _pagemap:
 
-======================================
-pagemap from the Userspace Perspective
-======================================
+=============================
+Examining Process Page Tables
+=============================
 
 pagemap is a new (as of 2.6.25) set of interfaces in the kernel that allow
 userspace programs to examine the page tables and related information by
-- 
2.7.4
