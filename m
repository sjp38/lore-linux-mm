Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F11296B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 20:33:31 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id qs7so69841582wjc.4
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 17:33:31 -0800 (PST)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id cg2si64183172wjc.103.2017.01.05.17.33.30
        for <linux-mm@kvack.org>;
        Thu, 05 Jan 2017 17:33:30 -0800 (PST)
From: James Hogan <james.hogan@imgtec.com>
Subject: [PATCH 1/30] mm: Export init_mm for MIPS KVM use of pgd_alloc()
Date: Fri, 6 Jan 2017 01:32:33 +0000
Message-ID: <a8df39719fb0570cb38e3fbb5c128fe2618e92d6.1483665879.git-series.james.hogan@imgtec.com>
MIME-Version: 1.0
In-Reply-To: <cover.d6d201de414322ed2c1372e164254e6055ef7db9.1483665879.git-series.james.hogan@imgtec.com>
References: <cover.d6d201de414322ed2c1372e164254e6055ef7db9.1483665879.git-series.james.hogan@imgtec.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mips@linux-mips.org
Cc: James Hogan <james.hogan@imgtec.com>, linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org

Export the init_mm symbol to GPL modules so that MIPS KVM can use
pgd_alloc() to create GVA page directory tables for trap & emulate mode,
which runs guest code in user mode. On MIPS pgd_alloc() is implemented
inline and refers to init_mm in order to copy kernel address space
mappings into the new page directory.

Signed-off-by: James Hogan <james.hogan@imgtec.com>
Cc: linux-mm@kvack.org
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: "Radim KrA?mA!A?" <rkrcmar@redhat.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-mips@linux-mips.org
Cc: kvm@vger.kernel.org
---
 mm/init-mm.c | 2 ++
 1 file changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/init-mm.c b/mm/init-mm.c
index 975e49f00f34..94aae08b41e1 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -1,3 +1,4 @@
+#include <linux/export.h>
 #include <linux/mm_types.h>
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
@@ -25,3 +26,4 @@ struct mm_struct init_mm = {
 	.user_ns	= &init_user_ns,
 	INIT_MM_CONTEXT(init_mm)
 };
+EXPORT_SYMBOL_GPL(init_mm);
-- 
git-series 0.8.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
