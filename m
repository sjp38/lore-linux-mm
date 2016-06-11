Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A75AF6B025F
	for <linux-mm@kvack.org>; Sat, 11 Jun 2016 15:16:20 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u74so43099280lff.0
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 12:16:20 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id s20si6169327wmb.51.2016.06.11.12.16.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jun 2016 12:16:19 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id k184so5821004wme.2
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 12:16:19 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC PATCH 3/3] doc: add information about min_ptes_young
Date: Sat, 11 Jun 2016 22:16:01 +0300
Message-Id: <1465672561-29608-4-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1465672561-29608-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1465672561-29608-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

min_ptes_young specifies at least how many young pages needed
to create a THP. This threshold also effects when making swapin
readahead (if needed) to create a THP. We decide whether to make
swapin readahed wortwhile looking the value.

/sys/kernel/mm/transparent_hugepage/khugepaged/min_ptes_young

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
---
 Documentation/vm/transhuge.txt | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 2ec6adb..0ae713b 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -193,6 +193,13 @@ memory. A lower value can prevent THPs from being
 collapsed, resulting fewer pages being collapsed into
 THPs, and lower memory access performance.
 
+min_ptes_young specifies at least how many young pages needed
+to create a THP. This threshold also effects when making swapin
+readahead (if needed) to create a THP. We decide whether to make
+swapin readahed wortwhile looking the value.
+
+/sys/kernel/mm/transparent_hugepage/khugepaged/min_ptes_young
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
