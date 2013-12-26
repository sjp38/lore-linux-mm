Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id B63CA6B0035
	for <linux-mm@kvack.org>; Thu, 26 Dec 2013 07:33:14 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id i17so7527766qcy.23
        for <linux-mm@kvack.org>; Thu, 26 Dec 2013 04:33:14 -0800 (PST)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id f1si23630253qej.126.2013.12.26.04.33.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Dec 2013 04:33:13 -0800 (PST)
Received: by mail-pd0-f169.google.com with SMTP id v10so8036537pde.28
        for <linux-mm@kvack.org>; Thu, 26 Dec 2013 04:33:12 -0800 (PST)
From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] mm: zswap: Add kernel parameters for zswap in kernel-parameters.txt
Date: Thu, 26 Dec 2013 21:32:59 +0900
Message-Id: <1388061179-26624-1-git-send-email-standby24x7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sjenning@linux.vnet.ibm.com, linux-mm@kvack.org
Cc: Masanari Iida <standby24x7@gmail.com>

This patch adds kernel parameters for zswap.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/kernel-parameters.txt | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 60a822b..209730af 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -3549,6 +3549,19 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			Format:
 			<irq>,<irq_mask>,<io>,<full_duplex>,<do_sound>,<lockup_hack>[,<irq2>[,<irq3>[,<irq4>]]]
 
+	zswap.compressor= [KNL]
+			Specify compressor algorithm.
+			By default, set to lzo.
+
+	zswap.enabled=	[KNL]
+			Format: <0|1>
+			0: Disable zswap (default)
+			1: Enable zswap
+			See more information, Documentations/vm/zswap.txt
+
+	zswap.max_pool_percent=	[KNL]
+			The maximum percentage of memory that the compressed
+			pool can occupy. By default, set to 20.
 ______________________________________________________________________
 
 TODO:
-- 
1.8.5.2.192.g7794a68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
