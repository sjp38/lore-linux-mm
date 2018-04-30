Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4D56B0007
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 05:42:50 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 39so6539074qkx.0
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 02:42:50 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 62-v6si2691986qvc.255.2018.04.30.02.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 02:42:49 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RCFv2 2/7] kdump: include PAGE_OFFLINE_MAPCOUNT_VALUE in ELF info
Date: Mon, 30 Apr 2018 11:42:31 +0200
Message-Id: <20180430094236.29056-3-david@redhat.com>
In-Reply-To: <20180430094236.29056-1-david@redhat.com>
References: <20180430094236.29056-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This allows dump tools to skip pages that are offline.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Young <dyoung@redhat.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 kernel/crash_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/crash_core.c b/kernel/crash_core.c
index f7674d676889..c0a45e9ba84e 100644
--- a/kernel/crash_core.c
+++ b/kernel/crash_core.c
@@ -464,6 +464,7 @@ static int __init crash_save_vmcoreinfo_init(void)
 #ifdef CONFIG_HUGETLB_PAGE
 	VMCOREINFO_NUMBER(HUGETLB_PAGE_DTOR);
 #endif
+	VMCOREINFO_NUMBER(PAGE_OFFLINE_MAPCOUNT_VALUE);
 
 	arch_crash_save_vmcoreinfo();
 	update_vmcoreinfo_note();
-- 
2.14.3
