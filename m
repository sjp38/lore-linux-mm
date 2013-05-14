Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id B6AAB6B003A
	for <linux-mm@kvack.org>; Tue, 14 May 2013 14:20:49 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id 14so1038278vea.15
        for <linux-mm@kvack.org>; Tue, 14 May 2013 11:20:48 -0700 (PDT)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 4/9] xen/tmem: Fix compile warning.
Date: Tue, 14 May 2013 14:09:21 -0400
Message-Id: <1368554966-30469-5-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
References: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bob.liu@oracle.com, dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xen-devel@lists.xensource.com
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

We keep on getting:
drivers/xen/tmem.c:65:13: warning: a??disable_frontswap_selfshrinkinga?? defined but not used [-Wunused-variable]

if CONFIG_FRONTSWAP=y and # CONFIG_CLEANCACHE is not set

Found by 0 day test project

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/xen/tmem.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index c2ee188..30bf974 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -61,14 +61,12 @@ __setup("nofrontswap", no_frontswap);
 #endif
 #endif /* CONFIG_FRONTSWAP */
 
-#ifdef CONFIG_FRONTSWAP
+#ifdef CONFIG_XEN_SELFBALLOONING
 static bool disable_frontswap_selfshrinking __read_mostly;
 #ifdef CONFIG_XEN_TMEM_MODULE
 module_param(disable_frontswap_selfshrinking, bool, S_IRUGO);
-#else
-#define disable_frontswap_selfshrinking 1
 #endif
-#endif /* CONFIG_FRONTSWAP */
+#endif /* CONFIG_XEN_SELFBALLOONING */
 
 #define TMEM_CONTROL               0
 #define TMEM_NEW_POOL              1
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
