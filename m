Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id EC9386B025B
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:34:01 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id yy13so54358568pab.3
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:34:01 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id rd6si8352491pab.153.2016.01.30.01.34.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:34:01 -0800 (PST)
Date: Sat, 30 Jan 2016 01:32:50 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-f0f4711aa16b82016c0b6e59871934bbd71258da@git.kernel.org>
Reply-To: hpa@zytor.com, mcgrof@suse.com, bp@alien8.de, brgerst@gmail.com,
        dyoung@redhat.com, bp@suse.de, mnfhuang@gmail.com,
        ross.zwisler@linux.intel.com, dvlasenk@redhat.com,
        torvalds@linux-foundation.org, mingo@kernel.org, linux-mm@kvack.org,
        joeyli.kernel@gmail.com, dzickus@redhat.com, luto@kernel.org,
        peterz@infradead.org, akpm@linux-foundation.org, luto@amacapital.net,
        tglx@linutronix.de, toshi.kani@hpe.com, linux-kernel@vger.kernel.org,
        dan.j.williams@intel.com, toshi.kani@hp.com, sfr@canb.auug.org.au,
        indou.takao@jp.fujitsu.com
In-Reply-To: <1453841853-11383-15-git-send-email-bp@alien8.de>
References: <1453841853-11383-15-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] x86, kexec, nvdimm: Use walk_iomem_res_desc(
 ) for iomem search
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: toshi.kani@hpe.com, toshi.kani@hp.com, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, sfr@canb.auug.org.au, indou.takao@jp.fujitsu.com, linux-mm@kvack.org, mingo@kernel.org, dvlasenk@redhat.com, torvalds@linux-foundation.org, luto@kernel.org, joeyli.kernel@gmail.com, dzickus@redhat.com, akpm@linux-foundation.org, peterz@infradead.org, luto@amacapital.net, tglx@linutronix.de, brgerst@gmail.com, bp@suse.de, dyoung@redhat.com, ross.zwisler@linux.intel.com, mnfhuang@gmail.com, hpa@zytor.com, mcgrof@suse.com, bp@alien8.de

Commit-ID:  f0f4711aa16b82016c0b6e59871934bbd71258da
Gitweb:     http://git.kernel.org/tip/f0f4711aa16b82016c0b6e59871934bbd71258da
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:30 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:59 +0100

x86, kexec, nvdimm: Use walk_iomem_res_desc() for iomem search

Change the callers of walk_iomem_res() scanning for the
following resources by name to use walk_iomem_res_desc()
instead.

 "ACPI Tables"
 "ACPI Non-volatile Storage"
 "Persistent Memory (legacy)"
 "Crash kernel"

Note, the caller of walk_iomem_res() with "GART" will be removed
in a later patch.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Dave Young <dyoung@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Chun-Yi <joeyli.kernel@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Don Zickus <dzickus@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Lee, Chun-Yi <joeyli.kernel@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Minfei Huang <mnfhuang@gmail.com>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Takao Indoh <indou.takao@jp.fujitsu.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: kexec@lists.infradead.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Link: http://lkml.kernel.org/r/1453841853-11383-15-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/kernel/crash.c | 4 ++--
 arch/x86/kernel/pmem.c  | 4 ++--
 drivers/nvdimm/e820.c   | 2 +-
 kernel/kexec_file.c     | 8 ++++----
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/x86/kernel/crash.c b/arch/x86/kernel/crash.c
index 58f3431..35e152e 100644
--- a/arch/x86/kernel/crash.c
+++ b/arch/x86/kernel/crash.c
@@ -599,12 +599,12 @@ int crash_setup_memmap_entries(struct kimage *image, struct boot_params *params)
 	/* Add ACPI tables */
 	cmd.type = E820_ACPI;
 	flags = IORESOURCE_MEM | IORESOURCE_BUSY;
-	walk_iomem_res("ACPI Tables", flags, 0, -1, &cmd,
+	walk_iomem_res_desc(IORES_DESC_ACPI_TABLES, flags, 0, -1, &cmd,
 		       memmap_entry_callback);
 
 	/* Add ACPI Non-volatile Storage */
 	cmd.type = E820_NVS;
-	walk_iomem_res("ACPI Non-volatile Storage", flags, 0, -1, &cmd,
+	walk_iomem_res_desc(IORES_DESC_ACPI_NV_STORAGE, flags, 0, -1, &cmd,
 			memmap_entry_callback);
 
 	/* Add crashk_low_res region */
diff --git a/arch/x86/kernel/pmem.c b/arch/x86/kernel/pmem.c
index 14415af..92f7014 100644
--- a/arch/x86/kernel/pmem.c
+++ b/arch/x86/kernel/pmem.c
@@ -13,11 +13,11 @@ static int found(u64 start, u64 end, void *data)
 
 static __init int register_e820_pmem(void)
 {
-	char *pmem = "Persistent Memory (legacy)";
 	struct platform_device *pdev;
 	int rc;
 
-	rc = walk_iomem_res(pmem, IORESOURCE_MEM, 0, -1, NULL, found);
+	rc = walk_iomem_res_desc(IORES_DESC_PERSISTENT_MEMORY_LEGACY,
+				 IORESOURCE_MEM, 0, -1, NULL, found);
 	if (rc <= 0)
 		return 0;
 
diff --git a/drivers/nvdimm/e820.c b/drivers/nvdimm/e820.c
index b0045a5..95825b3 100644
--- a/drivers/nvdimm/e820.c
+++ b/drivers/nvdimm/e820.c
@@ -55,7 +55,7 @@ static int e820_pmem_probe(struct platform_device *pdev)
 	for (p = iomem_resource.child; p ; p = p->sibling) {
 		struct nd_region_desc ndr_desc;
 
-		if (strncmp(p->name, "Persistent Memory (legacy)", 26) != 0)
+		if (p->desc != IORES_DESC_PERSISTENT_MEMORY_LEGACY)
 			continue;
 
 		memset(&ndr_desc, 0, sizeof(ndr_desc));
diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
index 2bfcdc0..56b18eb 100644
--- a/kernel/kexec_file.c
+++ b/kernel/kexec_file.c
@@ -524,10 +524,10 @@ int kexec_add_buffer(struct kimage *image, char *buffer, unsigned long bufsz,
 
 	/* Walk the RAM ranges and allocate a suitable range for the buffer */
 	if (image->type == KEXEC_TYPE_CRASH)
-		ret = walk_iomem_res("Crash kernel",
-				     IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY,
-				     crashk_res.start, crashk_res.end, kbuf,
-				     locate_mem_hole_callback);
+		ret = walk_iomem_res_desc(crashk_res.desc,
+				IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY,
+				crashk_res.start, crashk_res.end, kbuf,
+				locate_mem_hole_callback);
 	else
 		ret = walk_system_ram_res(0, -1, kbuf,
 					  locate_mem_hole_callback);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
