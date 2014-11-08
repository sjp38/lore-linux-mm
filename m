Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0F80582BEF
	for <linux-mm@kvack.org>; Sat,  8 Nov 2014 18:01:54 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id n12so6460284wgh.41
        for <linux-mm@kvack.org>; Sat, 08 Nov 2014 15:01:53 -0800 (PST)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id bq18si10059602wib.25.2014.11.08.15.01.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 08 Nov 2014 15:01:53 -0800 (PST)
Received: by mail-wg0-f54.google.com with SMTP id n12so6187836wgh.13
        for <linux-mm@kvack.org>; Sat, 08 Nov 2014 15:01:53 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH v2 3/3] KSM: Add config to control mark_new_vma
Date: Sun,  9 Nov 2014 02:01:43 +0300
Message-Id: <1415487703-1824-4-git-send-email-nefelim4ag@gmail.com>
In-Reply-To: <1415487703-1824-1-git-send-email-nefelim4ag@gmail.com>
References: <1415487703-1824-1-git-send-email-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: nefelim4ag@gmail.com, marco.antonio.780@gmail.com

Allowing to control mark_new_vma default value
Allowing work ksm on early allocated vmas

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
---
 mm/Kconfig | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 1d1ae6b..90f40a6 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -340,6 +340,13 @@ config KSM
 	  until a program has madvised that an area is MADV_MERGEABLE, and
 	  root has set /sys/kernel/mm/ksm/run to 1 (if CONFIG_SYSFS is set).
 
+config KSM_MARK_NEW_VMA
+	int "Marking new vma pages as VM_MERGEABLE"
+	depends on KSM
+	default 0
+	range 0 1
+	help
+
 config DEFAULT_MMAP_MIN_ADDR
         int "Low address space to protect from user allocation"
 	depends on MMU
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
