Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D0CD76B0038
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 13:49:22 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g8so11286287pgs.14
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 10:49:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor4594910plq.100.2017.12.18.10.49.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Dec 2017 10:49:21 -0800 (PST)
From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH] mm: don't use the same value for MAP_FIXED_SAFE and MAP_SYNC
Date: Mon, 18 Dec 2017 10:49:16 -0800
Message-Id: <20171218184916.24445-1-avagin@openvz.org>
In-Reply-To: <20171218091302.GL16951@dhcp22.suse.cz>
References: <20171218091302.GL16951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andrei Vagin <avagin@openvz.org>, Michal Hocko <mhocko@kernel.org>

Cc: Michal Hocko <mhocko@kernel.org>
Fixes: ("fs, elf: drop MAP_FIXED usage from elf_map")
Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 include/uapi/asm-generic/mman-common.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index b37502cbbef7..2db3fa287274 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -26,7 +26,9 @@
 #else
 # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
 #endif
-#define MAP_FIXED_SAFE	0x80000		/* MAP_FIXED which doesn't unmap underlying mapping */
+
+/* 0x0100 - 0x80000 flags are defined in asm-generic/mman.h */
+#define MAP_FIXED_SAFE	0x100000		/* MAP_FIXED which doesn't unmap underlying mapping */
 
 /*
  * Flags for mlock
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
