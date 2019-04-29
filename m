Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1B78C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:58:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81E432075E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:58:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="O7DKFuWY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81E432075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 848266B000A; Mon, 29 Apr 2019 15:58:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FA186B000C; Mon, 29 Apr 2019 15:58:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69CDC6B000D; Mon, 29 Apr 2019 15:58:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B10B6B000A
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 15:58:33 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l13so7807144pgp.3
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:58:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7Bip8Y5X/mEZXPj+LvDt3Chr3J9dT6n58JPfRJ35Uag=;
        b=kaayMn9Hlck/ABhP20dXz++WAeDZnp0ZBl0cUt6HNFeUt2+fFYOVHN9WlEwodsV/bl
         eWv8fRx/prqtbqwQ33JW8XMgIKUjHvePGiJXtBQ8iX0FF8LH4hpMxS5KgoBdpdx3Z3kO
         B9rdsJqVolIipw3D4R8NeNJ85VCj0zbx4vsam7V/kUglpqa/YVGyTnEdrVqWzKp1OH9E
         1nwoGDMzc8LUTuGWOLcRvkINyBiFlCCyQW67Lh71pqUZjPqjPIic8R5cW4hF6ZuzVcI4
         w6x/aeWE5MmBIyoOwBvoiwpV9+X8y3QNSbTWAq8Tr3RbHqAkoe/35YaXUv6f/D8eTl/V
         CdAQ==
X-Gm-Message-State: APjAAAW/ejqteuYIjcNaXI8GF01oYvGWW2Vadwq5lwjzVNhUcSsmPPoc
	/awnqIDDwdh2ppzVQscG4MajVwycTREGRwpw9kStdXZTw9gEOFTahLnKU1b3Xs8BcfJRvZP9m1H
	OhjdBhHyZORJPaKS0OSx2+mNwqS3b/zftXnKr7cRLkPTLZX2Zn98wuGTOnwr6QUSA4g==
X-Received: by 2002:a63:f817:: with SMTP id n23mr19614648pgh.302.1556567912823;
        Mon, 29 Apr 2019 12:58:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRsiM3cX/KY18sJcZUAytzSHAsg737jOhIIO75NfcpfE+YPqPvtHPau9PXNV8NTwXyT9n6
X-Received: by 2002:a63:f817:: with SMTP id n23mr19614532pgh.302.1556567911663;
        Mon, 29 Apr 2019 12:58:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556567911; cv=none;
        d=google.com; s=arc-20160816;
        b=MPoHhPOGhK07SeKFIXRuG3iSn0mIZacbTMA+yabcY/BnoJ/1UzXiM0qBexPQ7zlgOj
         b0DXxGfDxwoN8tElCjQUT1+QfUSX4ZB1s03S/Vf4UD5Qx8JV/WobiGzUYWRzP2sbBv6V
         Ac2UMD9piaqY+Y3AhcHyOtS8PXQMLSlnFy7rGtEbttvG8+WrooLCdaMDYwhmVmneVMlP
         iDSbFOFJ9rPo4+dBhl2pIV/ImnIQO0gjWG/dH8h0T22ogN0dij8xFVQK/r+cIW9NpOnX
         h1Ku3n6NTDKHWDuuEWekiRTHsW46VptfHCiTvgwaq1nMbuiRF1omb5RiERqnDavKkgSd
         1v7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:ironport-sdr:ironport-sdr
         :dkim-signature;
        bh=7Bip8Y5X/mEZXPj+LvDt3Chr3J9dT6n58JPfRJ35Uag=;
        b=zn+Osbev3uy/TYAQ65u8iQbSwJdBhtfzRmwLLrOiBSv/L8QswFEMr7MLJ7H6ExP9hn
         OMurEeD+OsKn+rDxQGNoULvRj/4Tfjya+p9kaeGEyjXYTkRoEG4OPGYJK+ux4/2WApan
         oodY2JZUkjV8a/KuCq4J054yGx+wc7q4GPokIo5VcuPj2eOegq+tPr5erIZRfOhVUeEM
         fMj+iGxq+K3+LBskgXDhBtLD+Zpa5vQOCuJJdY3zWZ9NIt6IGQl5eE3czYo9iTEba1FI
         0Tr1kN+vVCbrap98wmuT4i6I8DaWi7r9ItipfgIitju730rFEuKYpjUIb7Wh2154nXq3
         f8ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=O7DKFuWY;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 68.232.141.245 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa1.hgst.iphmx.com (esa1.hgst.iphmx.com. [68.232.141.245])
        by mx.google.com with ESMTPS id c3si34040478plo.243.2019.04.29.12.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 12:58:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 68.232.141.245 as permitted sender) client-ip=68.232.141.245;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=O7DKFuWY;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 68.232.141.245 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1556567911; x=1588103911;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=6yEgNpC7nkfK5Gt64tHVR1TWf8LgYKpoRswHlGybH9k=;
  b=O7DKFuWYml8vJpoTRORYQORsbSEYjSfwPFA+LajwawmCgWRz+2W9fcKo
   dOdbALnSU1azuu1Mjv8cMAkffDIispMdaOdPqfoSdXbv1JJon8eyTCCx6
   1Cl0u7o+535YRkoeLolsj0bw1Hmv6sN3384Og1l6W4/2JfMm0AG/ubNne
   wqKS8TkznyN2lGJWHHMocgdeAMWnI0JVuD0zzi6loarbCvk0U5vT7e0Jj
   GCt/YRAZ1WQPOvt7ukLFJY0Z6Ds+D5B0yDb1y0zYdSFbwuz2r18XTmi2P
   a8JG3+D2Aa/Wymm0u8MDMxE8t3CUtug8Jd8ULICwzfLT7zisgZufRQw/3
   w==;
X-IronPort-AV: E=Sophos;i="5.60,410,1549900800"; 
   d="scan'208";a="212999887"
Received: from h199-255-45-14.hgst.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 30 Apr 2019 03:58:12 +0800
IronPort-SDR: 9R/3UsBlEX8q3Lm/gyzN3lfy9sq9BJ3QxRrhYSNxfkthtv/S2z0bqegVlyOgb2qoZbDwwWg4MI
 6d98nyVrNTqGzlrLSihxxPfHkzDex9K+1acs1bVxD9YHBQg7/rwGu/75t4N85h+SxZLO6D7ych
 ThjZsKLMCgMQsxr2Nza0FG1ODnayjaUI+V18OYuEt4miSJI90qCkBpyyhdxNIBxPpAWLVgdynA
 GT1ZCgKuq2UfhkzsRb+pqAi6QrQ+wrVkIO2iz2TbPckhSoDxWpD1zGLlAX2hSQTt2I6NOBH0GS
 K/t+PJZXaBCtlYkLxmWx2wCU
Received: from uls-op-cesaip01.wdc.com ([10.248.3.36])
  by uls-op-cesaep01.wdc.com with ESMTP; 29 Apr 2019 12:34:35 -0700
IronPort-SDR: UFWPaNgFKiyS+kM5SJyaKOUbUteycQhA9GHu35ZdcqxcIAwpMq8jMx6cNKm2y61EvnKQIFA4g6
 adyt71wuZeOe/j/KIJZpFB2cH7aaoEu+AewDQCjkARDNK6tKK3Ss/l+or3zUgnpe45r8pEQkIk
 Y4X8GvyOZtE6EMtIew7DWbZqn+xPD9yVsW1Tg3JnbklQSamvfjNHbVdnBrVnlis/LKUG2/sMoI
 J22J0Ee7szjf8iEwrssNPsTdXyQfMfR6jgh0cXur2FRS7yIgCImTKqhsa+TrLQ0cRGszY6tVQd
 xPQ=
Received: from jedi-01.sdcorp.global.sandisk.com (HELO jedi-01.int.fusionio.com) ([10.11.143.218])
  by uls-op-cesaip01.wdc.com with ESMTP; 29 Apr 2019 12:58:12 -0700
From: Atish Patra <atish.patra@wdc.com>
To: linux-kernel@vger.kernel.org
Cc: Atish Patra <atish.patra@wdc.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anup Patel <anup@brainfault.org>,
	Borislav Petkov <bp@alien8.de>,
	Changbin Du <changbin.du@intel.com>,
	Gary Guo <gary@garyguo.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	linux-mm@kvack.org,
	linux-riscv@lists.infradead.org,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Palmer Dabbelt <palmer@sifive.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	x86@kernel.org (maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)),
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v2 3/3] RISC-V: Update tlb flush counters
Date: Mon, 29 Apr 2019 12:57:59 -0700
Message-Id: <20190429195759.18330-4-atish.patra@wdc.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190429195759.18330-1-atish.patra@wdc.com>
References: <20190429195759.18330-1-atish.patra@wdc.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The TLB flush counters under vmstat seems to be very helpful while
debugging TLB flush performance in RISC-V.

Update the counters in every TLB flush methods respectively.

Signed-off-by: Atish Patra <atish.patra@wdc.com>
---
 arch/riscv/include/asm/tlbflush.h |  5 +++++
 arch/riscv/mm/tlbflush.c          | 12 ++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/arch/riscv/include/asm/tlbflush.h b/arch/riscv/include/asm/tlbflush.h
index 29a780ca232a..19779a083f52 100644
--- a/arch/riscv/include/asm/tlbflush.h
+++ b/arch/riscv/include/asm/tlbflush.h
@@ -9,6 +9,7 @@
 #define _ASM_RISCV_TLBFLUSH_H
 
 #include <linux/mm_types.h>
+#include <linux/vmstat.h>
 
 /*
  * Flush entire local TLB.  'sfence.vma' implicitly fences with the instruction
@@ -16,11 +17,13 @@
  */
 static inline void local_flush_tlb_all(void)
 {
+	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 	__asm__ __volatile__ ("sfence.vma" : : : "memory");
 }
 
 static inline void local_flush_tlb_mm(struct mm_struct *mm)
 {
+	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 	/* Flush ASID 0 so that global mappings are not affected */
 	__asm__ __volatile__ ("sfence.vma x0, %0" : : "r" (0) : "memory");
 }
@@ -28,6 +31,7 @@ static inline void local_flush_tlb_mm(struct mm_struct *mm)
 static inline void local_flush_tlb_page(struct vm_area_struct *vma,
 	unsigned long addr)
 {
+	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
 	__asm__ __volatile__ ("sfence.vma %0, %1"
 			      : : "r" (addr), "r" (0)
 			      : "memory");
@@ -35,6 +39,7 @@ static inline void local_flush_tlb_page(struct vm_area_struct *vma,
 
 static inline void local_flush_tlb_kernel_page(unsigned long addr)
 {
+	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
 	__asm__ __volatile__ ("sfence.vma %0" : : "r" (addr) : "memory");
 }
 
diff --git a/arch/riscv/mm/tlbflush.c b/arch/riscv/mm/tlbflush.c
index ceee76f14a0a..8072d7da32bb 100644
--- a/arch/riscv/mm/tlbflush.c
+++ b/arch/riscv/mm/tlbflush.c
@@ -4,6 +4,8 @@
  */
 
 #include <linux/mm.h>
+#include <linux/vmstat.h>
+#include <linux/cpumask.h>
 #include <asm/sbi.h>
 
 #define SFENCE_VMA_FLUSH_ALL ((unsigned long) -1)
@@ -110,6 +112,7 @@ static void ipi_remote_sfence_vma(void *info)
 	unsigned long size = data->size;
 	unsigned long i;
 
+	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	if (size == SFENCE_VMA_FLUSH_ALL) {
 		local_flush_tlb_all();
 	}
@@ -129,6 +132,8 @@ static void ipi_remote_sfence_vma_asid(void *info)
 	unsigned long size = data->size;
 	unsigned long i;
 
+	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
+	/* Flush entire MM context */
 	if (size == SFENCE_VMA_FLUSH_ALL) {
 		__asm__ __volatile__ ("sfence.vma x0, %0"
 				      : : "r" (asid)
@@ -158,6 +163,13 @@ static void remote_sfence_vma(unsigned long start, unsigned long size)
 static void remote_sfence_vma_asid(cpumask_t *mask, unsigned long start,
 				   unsigned long size, unsigned long asid)
 {
+	int cpuid = smp_processor_id();
+
+	if (cpumask_equal(mask, cpumask_of(cpuid)))
+		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
+	else
+		count_vm_tlb_event(NR_TLB_REMOTE_FLUSH);
+
 	if (tlbi_ipi) {
 		struct tlbi info = {
 			.start = start,
-- 
2.21.0

