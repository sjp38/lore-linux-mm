Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFC54C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80E96206A3
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80E96206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 382B36B0288; Mon, 22 Apr 2019 15:00:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35F076B028A; Mon, 22 Apr 2019 15:00:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 110876B028B; Mon, 22 Apr 2019 15:00:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB9346B0288
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:00:40 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u191so4240130pgc.0
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:00:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=J/MHWg9P2bFxy449D6LfpA34veClVhAHFrMEACKVEKQ=;
        b=cGKkOfr4k6sIDmNnVF1cWv8V036u+FHyWprn8pyrVPM0XAkc6Fjsq8u2da3nItmiem
         snuTxUUjy2Gl7Xu2E5uf8zEC5M+aVjfSUkb8hMEeW1odvo4Tu8M1j0vIp25RmuCpRszV
         NYCWf7D9W7EuBETVZGQNRV+pY0q2eND77tFFw39bfcm5h4HAak+1ZYy/mAbz05zwoyp5
         qj1rdv+36xStJ1aVcr8ACt1OajVi+c120xnmLuX/PiuHbjcbgeITozjJtcrbdJc6ZvR0
         4PmugR6Qk0q8MWGuiK2VLEVthmSNNOAUO7bL2oiHm+q17VReo/SIC/pd67O7WefUCJ2H
         hNHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVUE4yyvKLyMN8Ck6iVM237KK+sU31lguhhNftTStRLrBfBW5L0
	Wbue5CRDJEGVOcDjr1JFwyCNGNLlsGFS9lqpZ7oYYQXnTOayfo/Vp83EIZD3YNyinewohonLjdw
	Uksu7vNDcMXNFfTu8Lp736iIa4HRasxeYSj9Neg1b4WJLndentyIoNyRp03Vq3rJnHw==
X-Received: by 2002:a63:d04b:: with SMTP id s11mr543375pgi.137.1555959640403;
        Mon, 22 Apr 2019 12:00:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxx0HAXuIu+BGxo+dbnTjKKleanyuE3SSyLzpk8Rjpw2tf5gzkN7+ECE2zge0CYgu3jeeQ
X-Received: by 2002:a63:d04b:: with SMTP id s11mr535019pgi.137.1555959524152;
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959524; cv=none;
        d=google.com; s=arc-20160816;
        b=1HtYURjTvetwS9dWPNZ51iR8WRU/Ju7Vuqv4xbCfmngD54tmabX8VxLftX+FD7uNER
         xUkgbpMMyCZL2CcG9beoie+V6nFotCFHFhpbFmCpv+G8cW8B/IblTTK2JYwhsaBwtYLJ
         87tfIVxHVz0n6Zx8PWZr3+e2jKRjmnoKGuI1CyeFCR2m0wGAs2f503lspgYtkt1SdzsJ
         8MAea5SmWtu0ZWgSKzgXRwkq4lCde1DVfDYu39F3eIKP7t4Gnl1XrJ2ybklJHQISyHbl
         g2CDGUYGPZKgsJdeu2yjLM7gDu2iwuxnhlEKBIscc/aF5aImW0C5prkK2METoRohZb7c
         5iMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=J/MHWg9P2bFxy449D6LfpA34veClVhAHFrMEACKVEKQ=;
        b=YZ20R2XnpasoD4b5tPOYXx8Oux8vnTmm5gVHToyPMuPgIapxZMPKSIOK9gR+rDuJCT
         ZMnRDXkIcoJSoNC8cg/CtlCb+o9agg8G3mnXiiHPZVFy1d8xPljj7G12JvjlcVZ798DK
         qbFVUtc0UGVnJuf+UAbrzGWJqrERr4HgAvYRCSM829Om2okE5F44y3NJ2MAR1GGC/Ysx
         nm/1LeRjcA8OKnnDt8CFGC0bqdDq0RPzE5vWywK8Syoz9+aCZeDNwz+nVKzXE9H2LYl4
         tl7hxQX33wuDgVTf/wTCJDal9SGxA+8OIq1PRTCtSuA8veEZofdzdYkyoDvS8BC7HjvQ
         8tog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a20si5314305pgb.421.2019.04.22.11.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417165"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:42 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v4 16/23] vmalloc: Add flag for free of special permsissions
Date: Mon, 22 Apr 2019 11:57:58 -0700
Message-Id: <20190422185805.1169-17-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a new flag VM_FLUSH_RESET_PERMS, for enabling vfree operations to
immediately clear executable TLB entries before freeing pages, and handle
resetting permissions on the directmap. This flag is useful for any kind
of memory with elevated permissions, or where there can be related
permissions changes on the directmap. Today this is RO+X and RO memory.

Although this enables directly vfreeing non-writeable memory now,
non-writable memory cannot be freed in an interrupt because the allocation
itself is used as a node on deferred free list. So when RO memory needs to
be freed in an interrupt the code doing the vfree needs to have its own
work queue, as was the case before the deferred vfree list was added to
vmalloc.

For architectures with set_direct_map_ implementations this whole operation
can be done with one TLB flush when centralized like this. For others with
directmap permissions, currently only arm64, a backup method using
set_memory functions is used to reset the directmap. When arm64 adds
set_direct_map_ functions, this backup can be removed.

When the TLB is flushed to both remove TLB entries for the vmalloc range
mapping and the direct map permissions, the lazy purge operation could be
done to try to save a TLB flush later. However today vm_unmap_aliases
could flush a TLB range that does not include the directmap. So a helper
is added with extra parameters that can allow both the vmalloc address and
the direct mapping to be flushed during this operation. The behavior of the
normal vm_unmap_aliases function is unchanged.

Cc: Borislav Petkov <bp@alien8.de>
Suggested-by: Dave Hansen <dave.hansen@intel.com>
Suggested-by: Andy Lutomirski <luto@kernel.org>
Suggested-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/vmalloc.h |  15 ++++++
 mm/vmalloc.c            | 113 +++++++++++++++++++++++++++++++++-------
 2 files changed, 109 insertions(+), 19 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..c6eebb839552 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -21,6 +21,11 @@ struct notifier_block;		/* in notifier.h */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
+/*
+ * Memory with VM_FLUSH_RESET_PERMS cannot be freed in an interrupt or with
+ * vfree_atomic().
+ */
+#define VM_FLUSH_RESET_PERMS	0x00000100      /* Reset direct map and flush TLB on unmap */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
@@ -142,6 +147,13 @@ extern int map_kernel_range_noflush(unsigned long start, unsigned long size,
 				    pgprot_t prot, struct page **pages);
 extern void unmap_kernel_range_noflush(unsigned long addr, unsigned long size);
 extern void unmap_kernel_range(unsigned long addr, unsigned long size);
+static inline void set_vm_flush_reset_perms(void *addr)
+{
+	struct vm_struct *vm = find_vm_area(addr);
+
+	if (vm)
+		vm->flags |= VM_FLUSH_RESET_PERMS;
+}
 #else
 static inline int
 map_kernel_range_noflush(unsigned long start, unsigned long size,
@@ -157,6 +169,9 @@ static inline void
 unmap_kernel_range(unsigned long addr, unsigned long size)
 {
 }
+static inline void set_vm_flush_reset_perms(void *addr)
+{
+}
 #endif
 
 /* Allocate/destroy a 'vmalloc' VM area. */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index e86ba6e74b50..e5e9e1fcac01 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -18,6 +18,7 @@
 #include <linux/interrupt.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <linux/set_memory.h>
 #include <linux/debugobjects.h>
 #include <linux/kallsyms.h>
 #include <linux/list.h>
@@ -1059,24 +1060,9 @@ static void vb_free(const void *addr, unsigned long size)
 		spin_unlock(&vb->lock);
 }
 
-/**
- * vm_unmap_aliases - unmap outstanding lazy aliases in the vmap layer
- *
- * The vmap/vmalloc layer lazily flushes kernel virtual mappings primarily
- * to amortize TLB flushing overheads. What this means is that any page you
- * have now, may, in a former life, have been mapped into kernel virtual
- * address by the vmap layer and so there might be some CPUs with TLB entries
- * still referencing that page (additional to the regular 1:1 kernel mapping).
- *
- * vm_unmap_aliases flushes all such lazy mappings. After it returns, we can
- * be sure that none of the pages we have control over will have any aliases
- * from the vmap layer.
- */
-void vm_unmap_aliases(void)
+static void _vm_unmap_aliases(unsigned long start, unsigned long end, int flush)
 {
-	unsigned long start = ULONG_MAX, end = 0;
 	int cpu;
-	int flush = 0;
 
 	if (unlikely(!vmap_initialized))
 		return;
@@ -1113,6 +1099,27 @@ void vm_unmap_aliases(void)
 		flush_tlb_kernel_range(start, end);
 	mutex_unlock(&vmap_purge_lock);
 }
+
+/**
+ * vm_unmap_aliases - unmap outstanding lazy aliases in the vmap layer
+ *
+ * The vmap/vmalloc layer lazily flushes kernel virtual mappings primarily
+ * to amortize TLB flushing overheads. What this means is that any page you
+ * have now, may, in a former life, have been mapped into kernel virtual
+ * address by the vmap layer and so there might be some CPUs with TLB entries
+ * still referencing that page (additional to the regular 1:1 kernel mapping).
+ *
+ * vm_unmap_aliases flushes all such lazy mappings. After it returns, we can
+ * be sure that none of the pages we have control over will have any aliases
+ * from the vmap layer.
+ */
+void vm_unmap_aliases(void)
+{
+	unsigned long start = ULONG_MAX, end = 0;
+	int flush = 0;
+
+	_vm_unmap_aliases(start, end, flush);
+}
 EXPORT_SYMBOL_GPL(vm_unmap_aliases);
 
 /**
@@ -1505,6 +1512,72 @@ struct vm_struct *remove_vm_area(const void *addr)
 	return NULL;
 }
 
+static inline void set_area_direct_map(const struct vm_struct *area,
+				       int (*set_direct_map)(struct page *page))
+{
+	int i;
+
+	for (i = 0; i < area->nr_pages; i++)
+		if (page_address(area->pages[i]))
+			set_direct_map(area->pages[i]);
+}
+
+/* Handle removing and resetting vm mappings related to the vm_struct. */
+static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
+{
+	unsigned long addr = (unsigned long)area->addr;
+	unsigned long start = ULONG_MAX, end = 0;
+	int flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
+	int i;
+
+	/*
+	 * The below block can be removed when all architectures that have
+	 * direct map permissions also have set_direct_map_() implementations.
+	 * This is concerned with resetting the direct map any an vm alias with
+	 * execute permissions, without leaving a RW+X window.
+	 */
+	if (flush_reset && !IS_ENABLED(CONFIG_ARCH_HAS_SET_DIRECT_MAP)) {
+		set_memory_nx(addr, area->nr_pages);
+		set_memory_rw(addr, area->nr_pages);
+	}
+
+	remove_vm_area(area->addr);
+
+	/* If this is not VM_FLUSH_RESET_PERMS memory, no need for the below. */
+	if (!flush_reset)
+		return;
+
+	/*
+	 * If not deallocating pages, just do the flush of the VM area and
+	 * return.
+	 */
+	if (!deallocate_pages) {
+		vm_unmap_aliases();
+		return;
+	}
+
+	/*
+	 * If execution gets here, flush the vm mapping and reset the direct
+	 * map. Find the start and end range of the direct mappings to make sure
+	 * the vm_unmap_aliases() flush includes the direct map.
+	 */
+	for (i = 0; i < area->nr_pages; i++) {
+		if (page_address(area->pages[i])) {
+			start = min(addr, start);
+			end = max(addr, end);
+		}
+	}
+
+	/*
+	 * Set direct map to something invalid so that it won't be cached if
+	 * there are any accesses after the TLB flush, then flush the TLB and
+	 * reset the direct map permissions to the default.
+	 */
+	set_area_direct_map(area, set_direct_map_invalid_noflush);
+	_vm_unmap_aliases(start, end, 1);
+	set_area_direct_map(area, set_direct_map_default_noflush);
+}
+
 static void __vunmap(const void *addr, int deallocate_pages)
 {
 	struct vm_struct *area;
@@ -1526,7 +1599,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
 	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
 
-	remove_vm_area(addr);
+	vm_remove_mappings(area, deallocate_pages);
+
 	if (deallocate_pages) {
 		int i;
 
@@ -1961,8 +2035,9 @@ EXPORT_SYMBOL(vzalloc_node);
  */
 void *vmalloc_exec(unsigned long size)
 {
-	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL_EXEC,
-			      NUMA_NO_NODE, __builtin_return_address(0));
+	return __vmalloc_node_range(size, 1, VMALLOC_START, VMALLOC_END,
+			GFP_KERNEL, PAGE_KERNEL_EXEC, VM_FLUSH_RESET_PERMS,
+			NUMA_NO_NODE, __builtin_return_address(0));
 }
 
 #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
-- 
2.17.1

