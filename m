Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 64E5A6B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:35:58 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b123so26645839itb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:35:58 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j73si3521244ita.122.2016.12.16.10.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:35:57 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 01/14] sparc64: placeholder for needed mmu shared context patching
Date: Fri, 16 Dec 2016 10:35:24 -0800
Message-Id: <1481913337-9331-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

MMU shared context patching will be supported on Sun4V platforms with
Niagara 2 or later processors.  There will be a need for kernel patching
based on this criteria.  This 'patch' simply adds a comment as a reminder
and placeholder to add that support.

For now, MMU shared context support will be determined at follows:
- sun4v patching will be used for shared context support.  This is too
  general as most but not all sun4v platforms contain the required
  processors.
- A new config option (CONFIG_SHARED_MMU_CTX) is added

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/sparc/kernel/setup_64.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/sparc/kernel/setup_64.c b/arch/sparc/kernel/setup_64.c
index 6b7331d..ffda69b 100644
--- a/arch/sparc/kernel/setup_64.c
+++ b/arch/sparc/kernel/setup_64.c
@@ -276,6 +276,17 @@ void sun_m7_patch_2insn_range(struct sun4v_2insn_patch_entry *start,
 	}
 }
 
+/*
+ * FIXME - TODO
+ *
+ * Shared MMU context support will only be provided on sun4v platforms
+ * with Niagara 2 or later processors.  A patching mechanism for this
+ * this type of support will need to be implemented.  For now, the code
+ * is making the too general assumption of supporting shared context on
+ * all sun4v platforms.  This is a placeholder to add correct support
+ * at a later time.
+ */
+
 static void __init sun4v_patch(void)
 {
 	extern void sun4v_hvapi_init(void);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
