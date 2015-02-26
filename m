Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id E266C6B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 16:34:57 -0500 (EST)
Received: by wesx3 with SMTP id x3so15001886wes.7
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 13:34:57 -0800 (PST)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id ey9si5487938wid.113.2015.02.26.13.34.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Feb 2015 13:34:56 -0800 (PST)
Received: by wghl2 with SMTP id l2so15052939wgh.9
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 13:34:53 -0800 (PST)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH] doc: add information about max_ptes_none
Date: Thu, 26 Feb 2015 23:34:36 +0200
Message-Id: <1424986476-6438-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: riel@redhat.com, mgorman@suse.de, hughd@google.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave@stgolabs.net, aulmcquad@gmail.com, sasha.levin@oracle.com, xemul@parallels.com, linux-kernel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>

max_ptes_none specifies how many extra small pages (that are
not already mapped) can be allocated when collapsing a group
of small pages into one large page.

/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none

A higher value leads to use additional memory for programs.
A lower value leads to gain less thp performance. Value of
max_ptes_none can waste cpu time very little, you can
ignore it.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 Documentation/vm/transhuge.txt | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 6b31cfb..8143b9e 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -159,6 +159,17 @@ for each pass:
 
 /sys/kernel/mm/transparent_hugepage/khugepaged/full_scans
 
+max_ptes_none specifies how many extra small pages (that are
+not already mapped) can be allocated when collapsing a group
+of small pages into one large page.
+
+/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none
+
+A higher value leads to use additional memory for programs.
+A lower value leads to gain less thp performance. Value of
+max_ptes_none can waste cpu time very little, you can
+ignore it.
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
