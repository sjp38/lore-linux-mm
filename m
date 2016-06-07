Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94D3F6B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 16:56:35 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id jt9so1796834obc.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 13:56:35 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0055.outbound.protection.outlook.com. [157.56.112.55])
        by mx.google.com with ESMTPS id e76si12489399oib.170.2016.06.07.13.56.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Jun 2016 13:56:34 -0700 (PDT)
From: Chris Metcalf <cmetcalf@mellanox.com>
Subject: [PATCH] tile: allow disabling CONFIG_EARLY_PRINTK
Date: Tue, 7 Jun 2016 16:56:27 -0400
Message-ID: <1465332987-28114-1-git-send-email-cmetcalf@mellanox.com>
In-Reply-To: <20160607125245.79a26fd3fee40afaa8ca04ff@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kbuild-all@01.org, kbuild test robot <fengguang.wu@intel.com>, Dan Williams <dan.j.williams@intel.com>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Chris Metcalf <cmetcalf@mellanox.com>

In that case, any users of early_panic() end up calling panic().

Signed-off-by: Chris Metcalf <cmetcalf@mellanox.com>
---
I don't think this is a recent breakage, and it doesn't feel too
critical, so I'll just push it in the next merge window.

 arch/tile/include/asm/setup.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/tile/include/asm/setup.h b/arch/tile/include/asm/setup.h
index e98909033e5b..2a0347af0702 100644
--- a/arch/tile/include/asm/setup.h
+++ b/arch/tile/include/asm/setup.h
@@ -25,7 +25,12 @@
 #define MAXMEM_PFN	PFN_DOWN(MAXMEM)
 
 int tile_console_write(const char *buf, int count);
+
+#ifdef CONFIG_EARLY_PRINTK
 void early_panic(const char *fmt, ...);
+#else
+#define early_panic panic
+#endif
 
 /* Init-time routine to do tile-specific per-cpu setup. */
 void setup_cpu(int boot);
-- 
2.7.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
