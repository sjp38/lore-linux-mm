Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA7996B0069
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 10:52:12 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so101963635pfx.1
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:52:12 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u3si7209374plj.76.2017.01.20.07.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 07:52:11 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0KFnVxn100371
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 10:52:11 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2833bgg0fk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 10:52:10 -0500
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <imbrenda@linux.vnet.ibm.com>;
	Fri, 20 Jan 2017 15:52:07 -0000
From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: [PATCH v3 1/1] mm/ksm: documentation for coloured zero pages deduplication
Date: Fri, 20 Jan 2017 16:52:02 +0100
Message-Id: <1484927522-1964-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: borntraeger@de.ibm.com, hughd@google.com, aarcange@redhat.com, chrisw@sous-sol.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

This patch adds the needed documentation for the use_zero_pages property.

Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
---
 Documentation/vm/ksm.txt | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
index f34a8ee..0c64a81d 100644
--- a/Documentation/vm/ksm.txt
+++ b/Documentation/vm/ksm.txt
@@ -80,6 +80,20 @@ run              - set 0 to stop ksmd from running but keep merged pages,
                    Default: 0 (must be changed to 1 to activate KSM,
                                except if CONFIG_SYSFS is disabled)
 
+use_zero_pages   - specifies whether empty pages (i.e. allocated pages
+                   that only contain zeroes) should be treated specially.
+                   When set to 1, empty pages are merged with the kernel
+                   zero page(s) instead of with each other as it would
+                   happen normally. This can improve the performance on
+                   architectures with coloured zero pages, depending on
+                   the workload. Care should be taken when enabling this
+                   setting, as it can potentially degrade the performance
+                   of KSM for some workloads, for example if the checksums
+                   of pages candidate for merging match the checksum of
+                   an empty page. This setting can be changed at any time,
+                   it is only effective for pages merged after the change.
+                   Default: 0 (normal KSM behaviour as in earlier releases)
+
 The effectiveness of KSM and MADV_MERGEABLE is shown in /sys/kernel/mm/ksm/:
 
 pages_shared     - how many shared pages are being used
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
