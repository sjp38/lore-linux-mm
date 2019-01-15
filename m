Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3968E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 11:44:52 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id r15so1289439ota.0
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 08:44:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e39sor2603785otb.132.2019.01.15.08.44.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 08:44:51 -0800 (PST)
From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] mm: Make CONFIG_FRAME_VECTOR a visible option
Date: Tue, 15 Jan 2019 08:44:35 -0800
Message-Id: <20190115164435.8423-1-olof@lixom.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Olof Johansson <olof@lixom.net>

CONFIG_FRAME_VECTOR was made an option to avoid including the bloat on
platforms that try to keep footprint down, which makes sense.

The problem with this is external modules that aren't built in-tree.
Since they don't have in-tree Kconfig, whether they can be loaded now
depends on whether your kernel config enabled some completely unrelated
driver that happened to select it. That's a weird and unpredictable
situation, and makes for some awkward requirements for the standalone
modules.

For these reasons, give someone the option to manually enable this when
configuring the kernel.

Signed-off-by: Olof Johansson <olof@lixom.net>
---
 mm/Kconfig | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb8a7dbd..0d80d06d3715b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -731,7 +731,10 @@ config DEVICE_PUBLIC
 	  the CPU
 
 config FRAME_VECTOR
-	bool
+	bool "Frame vector helper functions"
+	help
+	  Provide some helper functions for frame vectors, to be used
+	  by drivers who operate on userspace memory for DMA.
 
 config ARCH_USES_HIGH_VMA_FLAGS
 	bool
-- 
2.11.0
