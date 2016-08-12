Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D438C6B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 10:26:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so50583781pfd.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 07:26:41 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id y130si9190159pfg.217.2016.08.12.07.26.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 07:26:41 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id i6so1633685pfe.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 07:26:41 -0700 (PDT)
From: Ronit Halder <ronit.crj@gmail.com>
Subject: [RFC 3/4] Adding a new kernel configuration to enable the feature
Date: Fri, 12 Aug 2016 19:55:50 +0530
Message-Id: <20160812142550.6231-1-ronit.crj@gmail.com>
In-Reply-To: <20160812141838.5973-1-ronit.crj@gmail.com>
References: <20160812141838.5973-1-ronit.crj@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, dyoung@redhat.com, jroedel@suse.de, krzysiek@podlesie.net, msalter@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, bhe@redhat.com, vgoyal@redhat.com, mnfhuang@gmail.com, kexec@lists.infradead.org, kirill.shutemov@linux.intel.com, mchehab@osg.samsung.com, aarcange@redhat.com, vdavydov@parallels.com, dan.j.williams@intel.com, jack@suse.cz, linux-mm@kvack.org, Ronit Halder <ronit.crj@gmail.com>

Kernel configuration option added to enable run time memory reservation
feature for kexec.

Signed-off-by: Ronit Halder <ronit.crj@gmail.com>

---
 mm/Kconfig | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 97a4e06..8b1533d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -668,3 +668,9 @@ config ZONE_DEVICE
 
 config FRAME_VECTOR
 	bool
+config KEXEC_CMA
+	bool "Use CMA for Kexec crash kernel"
+	depends on CMA
+	help
+	  This configuration option is to use CMA for Kexec.
+	  CMA helps us to allocate memory for crash kernel at runtime.
\ No newline at end of file
-- 
2.9.0.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
