Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9F865280020
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 07:57:55 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id x12so11613156wgg.18
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 04:57:55 -0800 (PST)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id d6si35153956wja.178.2014.11.11.04.57.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 04:57:55 -0800 (PST)
Received: by mail-wi0-f180.google.com with SMTP id hi2so1524450wib.7
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 04:57:54 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH V3 3/4] KSM: Add config to control mark_new_vma
Date: Tue, 11 Nov 2014 15:57:35 +0300
Message-Id: <1415710656-29296-4-git-send-email-nefelim4ag@gmail.com>
In-Reply-To: <1415710656-29296-1-git-send-email-nefelim4ag@gmail.com>
References: <1415710656-29296-1-git-send-email-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nefelim4ag@gmail.com, marco.antonio.780@gmail.com, linux-kernel@vger.kernel.org, tonyb@cybernetics.com, killertofu@gmail.com

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
