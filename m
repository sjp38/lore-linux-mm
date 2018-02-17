Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2FC16B0007
	for <linux-mm@kvack.org>; Sat, 17 Feb 2018 03:15:48 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id 102so1460854lft.15
        for <linux-mm@kvack.org>; Sat, 17 Feb 2018 00:15:48 -0800 (PST)
Received: from forwardcorp1j.cmail.yandex.net (forwardcorp1j.cmail.yandex.net. [2a02:6b8:0:1630::190])
        by mx.google.com with ESMTPS id z131si1476511lfa.463.2018.02.17.00.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Feb 2018 00:15:47 -0800 (PST)
Subject: [PATCH] Documentation/vm/pagemap.txt: document bit WAITERS
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Sat, 17 Feb 2018 11:15:43 +0300
Message-ID: <151885534363.17898.8456668269733387066.stgit@buzz>
In-Reply-To: <151834540184.176427.12174649162560874101.stgit@buzz>
References: <151834540184.176427.12174649162560874101.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 Documentation/vm/pagemap.txt |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index eafcefa15261..eaa46771fa30 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -71,6 +71,7 @@ There are four components to pagemap:
     23. BALLOON
     24. ZERO_PAGE
     25. IDLE
+    26. WAITERS
 
  * /proc/kpagecgroup.  This file contains a 64-bit inode number of the
    memory cgroup each page is charged to, indexed by PFN. Only available when
@@ -127,6 +128,13 @@ Short descriptions to the page flags:
     stale in case the page was accessed via a PTE. To make sure the flag
     is up-to-date one has to read /sys/kernel/mm/page_idle/bitmap first.
 
+26. WAITERS
+    Indicates tasks are waiting when bits LOCKED or WRITEBACK will be cleared.
+    They might be blocked by undergoing IO or by contention on page lock.
+    Bit WAITERS might be false-positive, in this case next clear of LOCKED or
+    WRITEBACK will clear WAITERS too. I.e. without LOCKED and WRITEBACK it's
+    false-positive for sure.
+
     [IO related page flags]
  1. ERROR     IO error occurred
  3. UPTODATE  page has up-to-date data

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
