Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE6C6B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 04:20:05 -0400 (EDT)
Received: by wiclp1 with SMTP id lp1so102262085wic.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 01:20:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jy3si7797076wid.81.2015.07.09.01.20.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jul 2015 01:20:03 -0700 (PDT)
Date: Thu, 9 Jul 2015 09:20:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/4] Documentation/features/vm: Add feature description and
 arch support status for batched TLB flush after unmap
Message-ID: <20150709082000.GW6812@suse.de>
References: <1436189996-7220-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1436189996-7220-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Ingo Molnar <mingo@kernel.org>
---
 Documentation/features/vm/TLB/arch-support.txt | 40 ++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/Documentation/features/vm/TLB/arch-support.txt b/Documentation/features/vm/TLB/arch-support.txt
new file mode 100644
index 000000000000..261b92e2fb1a
--- /dev/null
+++ b/Documentation/features/vm/TLB/arch-support.txt
@@ -0,0 +1,40 @@
+#
+# Feature name:          batch-unmap-tlb-flush
+#         Kconfig:       ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
+#         description:   arch supports deferral of TLB flush until multiple pages are unmapped
+#
+    -----------------------
+    |         arch |status|
+    -----------------------
+    |       alpha: | TODO |
+    |         arc: | TODO |
+    |         arm: | TODO |
+    |       arm64: | TODO |
+    |       avr32: |  ..  |
+    |    blackfin: | TODO |
+    |         c6x: |  ..  |
+    |        cris: |  ..  |
+    |         frv: |  ..  |
+    |       h8300: |  ..  |
+    |     hexagon: | TODO |
+    |        ia64: | TODO |
+    |        m32r: | TODO |
+    |        m68k: |  ..  |
+    |       metag: | TODO |
+    |  microblaze: |  ..  |
+    |        mips: | TODO |
+    |     mn10300: | TODO |
+    |       nios2: |  ..  |
+    |    openrisc: |  ..  |
+    |      parisc: | TODO |
+    |     powerpc: | TODO |
+    |        s390: | TODO |
+    |       score: |  ..  |
+    |          sh: | TODO |
+    |       sparc: | TODO |
+    |        tile: | TODO |
+    |          um: |  ..  |
+    |   unicore32: |  ..  |
+    |         x86: |  ok  |
+    |      xtensa: | TODO |
+    -----------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
