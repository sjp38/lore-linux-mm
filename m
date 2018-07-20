Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DA596B026F
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 08:34:41 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q3-v6so9288771qki.4
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:34:41 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l21-v6si1727536qtf.198.2018.07.20.05.34.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 05:34:40 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 2/2] kdump: include PG_reserved value in VMCOREINFO
Date: Fri, 20 Jul 2018 14:34:22 +0200
Message-Id: <20180720123422.10127-3-david@redhat.com>
In-Reply-To: <20180720123422.10127-1-david@redhat.com>
References: <20180720123422.10127-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@kernel.org>

PG_reserved pages should never be touched by enybody except their owner.
Let's allow dumping tools to skip these pages.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Young <dyoung@redhat.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 kernel/crash_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/crash_core.c b/kernel/crash_core.c
index b66aced5e8c2..ab216accf96a 100644
--- a/kernel/crash_core.c
+++ b/kernel/crash_core.c
@@ -451,6 +451,7 @@ static int __init crash_save_vmcoreinfo_init(void)
 	log_buf_vmcoreinfo_setup();
 	VMCOREINFO_LENGTH(free_area.free_list, MIGRATE_TYPES);
 	VMCOREINFO_NUMBER(NR_FREE_PAGES);
+	VMCOREINFO_NUMBER(PG_reserved);
 	VMCOREINFO_NUMBER(PG_lru);
 	VMCOREINFO_NUMBER(PG_private);
 	VMCOREINFO_NUMBER(PG_swapcache);
-- 
2.17.1
