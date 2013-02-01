Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 43CD56B002B
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 15:23:38 -0500 (EST)
Received: by mail-ve0-f173.google.com with SMTP id oz10so3310281veb.32
        for <linux-mm@kvack.org>; Fri, 01 Feb 2013 12:23:37 -0800 (PST)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 15/15] xen/tmem: Add missing %s in the printk statement.
Date: Fri,  1 Feb 2013 15:23:04 -0500
Message-Id: <1359750184-23408-16-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
References: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Seems that it got lost.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/xen/tmem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index 2f939e5..4f3ff99 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -401,7 +401,7 @@ static int xen_tmem_init(void)
 			s = " (WARNING: frontswap_ops overridden)";
 		}
 		printk(KERN_INFO "frontswap enabled, RAM provided by "
-				 "Xen Transcendent Memory\n");
+				 "Xen Transcendent Memory%s\n", s);
 	}
 #endif
 #ifdef CONFIG_CLEANCACHE
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
