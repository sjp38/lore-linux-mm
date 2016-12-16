Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6C256B0271
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:36:11 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 51so45229796uai.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:36:11 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 52si2481782uaf.90.2016.12.16.10.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:36:11 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 14/14] sparc64: add SHARED_MMU_CTX Kconfig option
Date: Fri, 16 Dec 2016 10:35:37 -0800
Message-Id: <1481913337-9331-15-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Depends on SPARC64 && HUGETLB_PAGE

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/sparc/Kconfig | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 165ecdd..f39dcdf 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -155,6 +155,9 @@ config PGTABLE_LEVELS
 	default 4 if 64BIT
 	default 3
 
+config SHARED_MMU_CTX
+	def_bool y if SPARC64 && HUGETLB_PAGE
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
