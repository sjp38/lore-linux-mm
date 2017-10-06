Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 374B66B025F
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 07:39:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q18so2779648wmg.18
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 04:39:34 -0700 (PDT)
Received: from forwardcorp1j.cmail.yandex.net (forwardcorp1j.cmail.yandex.net. [5.255.227.106])
        by mx.google.com with ESMTPS id l13si586455lfi.245.2017.10.06.04.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 04:39:32 -0700 (PDT)
Subject: [PATCH] kmemleak: change /sys/kernel/debug/kmemleak permissions
 from 0444 to 0644
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 06 Oct 2017 14:39:25 +0300
Message-ID: <150728996582.744328.11541332857988399411.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>

Kmemleak could be tweaked in runtime by writing commands into debugfs file.
Root anyway can use it, but without write-bit this interface isn't obvious.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/kmemleak.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 7780cd83a495..fca3452e56c1 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -2104,7 +2104,7 @@ static int __init kmemleak_late_init(void)
 		return -ENOMEM;
 	}
 
-	dentry = debugfs_create_file("kmemleak", S_IRUGO, NULL, NULL,
+	dentry = debugfs_create_file("kmemleak", 0644, NULL, NULL,
 				     &kmemleak_fops);
 	if (!dentry)
 		pr_warn("Failed to create the debugfs kmemleak file\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
