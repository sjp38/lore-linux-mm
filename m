Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 45D176B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 17:35:44 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so8212027wic.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 14:35:43 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id ea14si2011844wjb.214.2015.09.17.14.35.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 14:35:43 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so8343550wic.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 14:35:42 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH] doc: add information about max_ptes_swap
Date: Fri, 18 Sep 2015 00:34:58 +0300
Message-Id: <1442525698-22598-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: riel@redhat.com, akpm@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kirill.shutemov@linux.intel.com, dave@stgolabs.net, denc716@gmail.com, ldufour@linux.vnet.ibm.com, sasha.levin@oracle.com, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>

max_ptes_swap specifies how many pages can be brought in from
swap when collapsing a group of pages into a transparent huge page.

/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap

A higher value can cause excessive swap IO and waste
memory. A lower value can prevent THPs from being
collapsed, resulting fewer pages being collapsed into
THPs, and lower memory access performance.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
---
 Documentation/vm/transhuge.txt | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 8143b9e..8a28268 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -170,6 +170,16 @@ A lower value leads to gain less thp performance. Value of
 max_ptes_none can waste cpu time very little, you can
 ignore it.
 
+max_ptes_swap specifies how many pages can be brought in from
+swap when collapsing a group of pages into a transparent huge page.
+
+/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap
+
+A higher value can cause excessive swap IO and waste
+memory. A lower value can prevent THPs from being
+collapsed, resulting fewer pages being collapsed into
+THPs, and lower memory access performance.
+
 == Boot parameter ==
 
 You can change the sysfs boot time defaults of Transparent Hugepage
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
