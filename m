Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0CD6B0035
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 20:30:31 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so2615304iec.33
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 17:30:30 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id l15si10012298igk.10.2014.07.30.17.30.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 17:30:30 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id r2so607963igi.0
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 17:30:30 -0700 (PDT)
Date: Wed, 30 Jul 2014 17:30:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] kexec: export free_huge_page to VMCOREINFO fix
In-Reply-To: <53d98399.wRC4T5IRh+/QWqVO%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.02.1407301727300.12181@chino.kir.corp.google.com>
References: <53d98399.wRC4T5IRh+/QWqVO%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Cc: kbuild test robot <fengguang.wu@intel.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

free_huge_page() is undefined without CONFIG_HUGETLBFS and there's no need 
to filter PageHuge() page is such a configuration either.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 To be folded into kexec-export-free_huge_page-to-vmcoreinfo.patch.

 kernel/kexec.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/kexec.c b/kernel/kexec.c
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -1994,7 +1994,9 @@ static int __init crash_save_vmcoreinfo_init(void)
 #endif
 	VMCOREINFO_NUMBER(PG_head_mask);
 	VMCOREINFO_NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE);
+#ifdef CONFIG_HUGETLBFS
 	VMCOREINFO_SYMBOL(free_huge_page);
+#endif
 
 	arch_crash_save_vmcoreinfo();
 	update_vmcoreinfo_note();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
