Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF8D6B46E5
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:57:43 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x85-v6so1067675pfe.13
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:57:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e14-v6si1078299pfi.184.2018.08.28.07.57.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 07:57:42 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 06/10] mm: Remove references to vm_insert_pfn
Date: Tue, 28 Aug 2018 07:57:24 -0700
Message-Id: <20180828145728.11873-7-willy@infradead.org>
In-Reply-To: <20180828145728.11873-1-willy@infradead.org>
References: <20180828145728.11873-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Documentation and comments.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 Documentation/x86/pat.txt     | 4 ++--
 include/asm-generic/pgtable.h | 4 ++--
 include/linux/hmm.h           | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/Documentation/x86/pat.txt b/Documentation/x86/pat.txt
index 2a4ee6302122..481d8d8536ac 100644
--- a/Documentation/x86/pat.txt
+++ b/Documentation/x86/pat.txt
@@ -90,12 +90,12 @@ pci proc               |    --    |    --      |       WC         |
 Advanced APIs for drivers
 -------------------------
 A. Exporting pages to users with remap_pfn_range, io_remap_pfn_range,
-vm_insert_pfn
+vmf_insert_pfn
 
 Drivers wanting to export some pages to userspace do it by using mmap
 interface and a combination of
 1) pgprot_noncached()
-2) io_remap_pfn_range() or remap_pfn_range() or vm_insert_pfn()
+2) io_remap_pfn_range() or remap_pfn_range() or vmf_insert_pfn()
 
 With PAT support, a new API pgprot_writecombine is being added. So, drivers can
 continue to use the above sequence, with either pgprot_noncached() or
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 88ebc6102c7c..5657a20e0c59 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -757,7 +757,7 @@ static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
 /*
  * Interfaces that can be used by architecture code to keep track of
  * memory type of pfn mappings specified by the remap_pfn_range,
- * vm_insert_pfn.
+ * vmf_insert_pfn.
  */
 
 /*
@@ -773,7 +773,7 @@ static inline int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 
 /*
  * track_pfn_insert is called when a _new_ single pfn is established
- * by vm_insert_pfn().
+ * by vmf_insert_pfn().
  */
 static inline void track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
 				    pfn_t pfn)
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 4c92e3ba3e16..dde947083d4e 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -107,7 +107,7 @@ enum hmm_pfn_flag_e {
  * HMM_PFN_ERROR: corresponding CPU page table entry points to poisoned memory
  * HMM_PFN_NONE: corresponding CPU page table entry is pte_none()
  * HMM_PFN_SPECIAL: corresponding CPU page table entry is special; i.e., the
- *      result of vm_insert_pfn() or vm_insert_page(). Therefore, it should not
+ *      result of vmf_insert_pfn() or vm_insert_page(). Therefore, it should not
  *      be mirrored by a device, because the entry will never have HMM_PFN_VALID
  *      set and the pfn value is undefined.
  *
-- 
2.18.0
