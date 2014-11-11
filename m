Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEA8280020
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 07:58:05 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id r20so1537429wiv.10
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 04:58:05 -0800 (PST)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id md18si6934216wic.8.2014.11.11.04.58.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 04:58:04 -0800 (PST)
Received: by mail-wi0-f175.google.com with SMTP id ex7so1530081wid.14
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 04:58:04 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH V3 4/4] KSM: mark_new_vma added to Documentation.
Date: Tue, 11 Nov 2014 15:57:36 +0300
Message-Id: <1415710656-29296-5-git-send-email-nefelim4ag@gmail.com>
In-Reply-To: <1415710656-29296-1-git-send-email-nefelim4ag@gmail.com>
References: <1415710656-29296-1-git-send-email-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nefelim4ag@gmail.com, marco.antonio.780@gmail.com, linux-kernel@vger.kernel.org, tonyb@cybernetics.com, killertofu@gmail.com

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
---
 Documentation/vm/ksm.txt | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
index f34a8ee..880fdbf 100644
--- a/Documentation/vm/ksm.txt
+++ b/Documentation/vm/ksm.txt
@@ -24,6 +24,8 @@ KSM only operates on those areas of address space which an application
 has advised to be likely candidates for merging, by using the madvise(2)
 system call: int madvise(addr, length, MADV_MERGEABLE).
 
+Also KSM can mark anonymous memory as mergeable, see below.
+
 The app may call int madvise(addr, length, MADV_UNMERGEABLE) to cancel
 that advice and restore unshared pages: whereupon KSM unmerges whatever
 it merged in that range.  Note: this unmerging call may suddenly require
@@ -73,6 +75,11 @@ merge_across_nodes - specifies if pages from different numa nodes can be merged.
                    merge_across_nodes, to remerge according to the new setting.
                    Default: 1 (merging across nodes as in earlier releases)
 
+mark_new_vma     - set 0 to disallow ksm marking every new allocated anonymous
+                   memory as mergeable.
+                   set 1 to allow ksm mark every new allocated anonymous memory
+                   as mergeable
+
 run              - set 0 to stop ksmd from running but keep merged pages,
                    set 1 to run ksmd e.g. "echo 1 > /sys/kernel/mm/ksm/run",
                    set 2 to stop ksmd and unmerge all pages currently merged,
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
