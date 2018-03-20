Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2C46B0025
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 22:00:49 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a22so56866qkc.1
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:00:49 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y39si752311qtk.156.2018.03.19.19.00.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 19:00:48 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 11/15] mm/hmm: rename HMM_PFN_DEVICE_UNADDRESSABLE to HMM_PFN_DEVICE_PRIVATE
Date: Mon, 19 Mar 2018 22:00:33 -0400
Message-Id: <20180320020038.3360-12-jglisse@redhat.com>
In-Reply-To: <20180320020038.3360-1-jglisse@redhat.com>
References: <20180320020038.3360-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Make naming consistent across code, DEVICE_PRIVATE is the name use
outside HMM code so use that one.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
---
 include/linux/hmm.h | 4 ++--
 mm/hmm.c            | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index cf283db22106..e8515cad5a00 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -88,13 +88,13 @@ struct hmm;
  *      result of vm_insert_pfn() or vm_insert_page(). Therefore, it should not
  *      be mirrored by a device, because the entry will never have HMM_PFN_VALID
  *      set and the pfn value is undefined.
- * HMM_PFN_DEVICE_UNADDRESSABLE: unaddressable device memory (ZONE_DEVICE)
+ * HMM_PFN_DEVICE_PRIVATE: unaddressable device memory (ZONE_DEVICE)
  */
 #define HMM_PFN_VALID (1 << 0)
 #define HMM_PFN_WRITE (1 << 1)
 #define HMM_PFN_ERROR (1 << 2)
 #define HMM_PFN_SPECIAL (1 << 3)
-#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 4)
+#define HMM_PFN_DEVICE_PRIVATE (1 << 4)
 #define HMM_PFN_SHIFT 5
 
 /*
diff --git a/mm/hmm.c b/mm/hmm.c
index 52204037ad84..b4b8b89ee7bb 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -448,7 +448,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 					pfns[i] |= HMM_PFN_WRITE;
 				} else if (write_fault)
 					goto fault;
-				pfns[i] |= HMM_PFN_DEVICE_UNADDRESSABLE;
+				pfns[i] |= HMM_PFN_DEVICE_PRIVATE;
 			} else if (is_migration_entry(entry)) {
 				if (hmm_vma_walk->fault) {
 					pte_unmap(ptep);
-- 
2.14.3
