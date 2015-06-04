Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id CE15F900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 09:14:39 -0400 (EDT)
Received: by obbgp2 with SMTP id gp2so9732704obb.2
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 06:14:39 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id j184si1622657oig.140.2015.06.04.06.14.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 06:14:39 -0700 (PDT)
Message-ID: <55704C9B.6010809@huawei.com>
Date: Thu, 4 Jun 2015 21:03:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH 09/12] mm: enable allocate mirrored memory at boot time
References: <55704A7E.5030507@huawei.com>
In-Reply-To: <55704A7E.5030507@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Add a boot option called "mirrorable" to allocate mirrored memory at boot time
(after bootmem free).

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 63b90ca..d4d2066 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -213,6 +213,13 @@ int user_min_free_kbytes = -1;
 #ifdef CONFIG_MEMORY_MIRROR
 struct mirror_info mirror_info;
 int sysctl_mirrorable = 0;
+
+static int __init set_mirrorable(char *p)
+{
+	sysctl_mirrorable = 1;
+	return 0;
+}
+early_param("mirrorable", set_mirrorable);
 #endif
 
 static unsigned long __meminitdata nr_kernel_pages;
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
