Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D67046B02AC
	for <linux-mm@kvack.org>; Wed, 23 May 2018 11:12:19 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t143-v6so13104523qke.18
        for <linux-mm@kvack.org>; Wed, 23 May 2018 08:12:19 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d7-v6si3115973qka.61.2018.05.23.08.12.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 08:12:19 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 04/10] kdump: include PAGE_OFFLINE_MAPCOUNT_VALUE in VMCOREINFO
Date: Wed, 23 May 2018 17:11:45 +0200
Message-Id: <20180523151151.6730-5-david@redhat.com>
In-Reply-To: <20180523151151.6730-1-david@redhat.com>
References: <20180523151151.6730-1-david@redhat.com>
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
2.17.0
