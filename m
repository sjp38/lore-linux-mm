Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EFE6C04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:28:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DB19216FD
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:28:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="qcGNRUGC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DB19216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD9656B0007; Mon, 29 Apr 2019 17:27:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAE796B000C; Mon, 29 Apr 2019 17:27:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9DD56B000D; Mon, 29 Apr 2019 17:27:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70F5A6B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 17:27:59 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g6so6066744plp.18
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:27:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7Bip8Y5X/mEZXPj+LvDt3Chr3J9dT6n58JPfRJ35Uag=;
        b=rRJfrKoq27jOi8LBQZ8ykc7aQUduW+Fhf9JUODCXb2G+sTGmoQWufUwZhcQxzc/DnO
         ioVDDaAbBMQ8PRtKC9fB+KFGDA6JUaMrt2SzCQez6ujED4LZHNuDoFhYbgBHVotDq1B+
         jtChb5+0ax69BT5KVkyPnN0W9fv/Ak0Rx0TCYROQVvzk9tUFYzPsh9XuojZ2HuxQFdsg
         JrYKUovnAJeqGT5xB2Lfq0NQfp/NKdaielpwMHpDsgscb+qrwMavwMsnCThQjSPRR375
         Pq+/bY83UGMPLUebFNrFihZTt8wZ9/sqhi0kU7HqpRegHe+OXnfRJCG8JrtxCoMGU6rn
         BRxg==
X-Gm-Message-State: APjAAAV4LmeCXXNG/jUbwQNd0V8GXt9kDlHnoGmw9xDjkN3uoCZqo4Eo
	DDXHlhfRVjd06zs/UoO5rJJ3L7dQiOu4i3kAlfdegcwcbrJsN3h3nMTvirnzoE61o5v968AYMSk
	WgQHF3uWez+oPAczBYHw/8+c1O6jy1AfPo+INpwHwsUdFVf8dlgWn3VjyejEBrXyixg==
X-Received: by 2002:a63:a18:: with SMTP id 24mr60014638pgk.332.1556573278926;
        Mon, 29 Apr 2019 14:27:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwB30S5naGbvX35RSqtizIiKkcERY46F1vIML+NpwmzvQ/ipRXCV0hedA9dljs47er8VSTG
X-Received: by 2002:a63:a18:: with SMTP id 24mr60014563pgk.332.1556573277695;
        Mon, 29 Apr 2019 14:27:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556573277; cv=none;
        d=google.com; s=arc-20160816;
        b=sLUTqv9N2o0xWUqBaKCkokbLVkE3d+GgBvtHj8+5liw0Wpw1gXC7nXawkwHS/hD3Pm
         kMAnBD3GImbcohTf5cZbdpT0hP6NUm5lY+KzJORG4q0kCmoyKJeESfM8J+CoPwMGHuvs
         YWC2PF+DqWGgM8FTaWe+dxdIkB6dGm5zua0J9rDUhgy8/mSsslKPLPdx5pvAIAD8KQH6
         xVSisyyiThpioIXkpwllrXjGwRknoxmdnL5oUJqJ3Cm8zcViW8zE4hkNiOmsWH9DHibJ
         6lBJnqzOrpi8FP2vdfPkYtalcCF44nqIWR9lVmflBRIFgDewy8nJ9PFKllDl2HHhgbRN
         7HRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:ironport-sdr:ironport-sdr
         :dkim-signature;
        bh=7Bip8Y5X/mEZXPj+LvDt3Chr3J9dT6n58JPfRJ35Uag=;
        b=bGYBnaOMoZQRgYMQQgFlgk9MdB5HH1DjLJpBMHYwIJAfX3SDv3KFPBgGZPKhJj7Ehu
         AH0s/LpXy/9duCOOLsnaWq3AhDRHsF9qbq7GiwE5Lbe847Jy1q1BXDw0wnMHFU8QngsU
         3VpGieVqyIOd9htnj/ZFs3MkGgDw6nD1a+PG9PtGJeKk45DGwIA9jts7JziHN2qCC4Us
         ktC4DXS4eWY1oyBHA/HIDJ3iYK4FKSfPsw0Nm2+po3NTZmk27fUt9AT2ve7lL113MQj7
         XOsEDcTWGqPVUDceaGhQUENkNm7Tur5NGp9WuJQLGef4O9xyhQwhPk+/roNpwMORKwxY
         SQ/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=qcGNRUGC;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa3.hgst.iphmx.com (esa3.hgst.iphmx.com. [216.71.153.141])
        by mx.google.com with ESMTPS id n21si26173197pgl.233.2019.04.29.14.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 14:27:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) client-ip=216.71.153.141;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=qcGNRUGC;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1556573277; x=1588109277;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=6yEgNpC7nkfK5Gt64tHVR1TWf8LgYKpoRswHlGybH9k=;
  b=qcGNRUGC/qaKCkDCmcQRhzubYkiKHmiWg9SoKiGYiFXDiJMNMh5Uib5l
   Yp6TkwXCq8FPRt+ooSGRK8yLJ9EA2t418xxeAi7SZ6Yz3fPawhvOBOSVG
   8U0pPgNIQhku+mblTUHpzrcNoiSVJgt2OlFi/DhODWrrI7MrSIGJMHOlX
   5+RCtkmUsuU0fKexN/jJQ7b4qNA8RWpgWZSC6wZ8gnEXBVCaC5agf3l0K
   4piTTLy9ItjSBNY0A9advUGFncLQdA3SfDBpgaF9A0C15sfXZlzFor/Dl
   ZhmMVSJ+jnFok8/ZRwzTuGOGHWz1VFCIzXPVZq8qAjeJr5u5mWSbpqYWs
   Q==;
X-IronPort-AV: E=Sophos;i="5.60,411,1549900800"; 
   d="scan'208";a="112062161"
Received: from h199-255-45-14.hgst.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 30 Apr 2019 05:27:57 +0800
IronPort-SDR: aEh0uSR70EmpEiWeSOczbANInjXpS3hUWc+9eRf9No16N+h0IbGlMS3o+RZ/XhyXrQY2atZVKj
 ZQs/SUR6uxXlri9azYL5KM/AUms1aGarT8Tu/VmQTC9x9LXUuZ6fH9DshLYGGiiK6UhQwxj20k
 LF4xWQFUsJrd/7FbuEE0mbtBlQHutXGRvz/KdDyM8RkiecJCIkLWLBXB71Of4mO722RAJ2Q4UP
 w6tp/zi9LEPJHhhcVNSuU5ltnDyL8a1BiAKKF4+i4vY6JkkAgaU/T66knVu6JzBgTn8GaGxYgi
 4xqr+zqr3iA+kW1CCQmdjRIy
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep01.wdc.com with ESMTP; 29 Apr 2019 14:04:19 -0700
IronPort-SDR: AeMSfyunL2LsJhLHPw2d6fgcuYcVNj32UjjthqEnf0K3EjrF0GfZMDuDh2OiloNPAlz1aVw0i+
 rx3dfrB4ctlfgfcrvEiWMY+xU/qL+lKYERo0bkL1QP8bZFPZXWNmK7AHG7clayjGa0Lj8ENMyx
 1wOmvOtnbDL3ngbhjQJ8wQKU3EyfHbxJyNq4JwOyOf6ZFZT8aE5nKv3MOFwnA7Y9OWIXRSIzTU
 D9skxvS/yaP+Q4I3XwxKDgiOXhch58PXoMJmzb/ezPJ2i0WDiO2HBIWmE1psz19MgvK5WqcNgm
 V3M=
Received: from jedi-01.sdcorp.global.sandisk.com (HELO jedi-01.int.fusionio.com) ([10.11.143.218])
  by uls-op-cesaip02.wdc.com with ESMTP; 29 Apr 2019 14:27:57 -0700
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
Subject: [PATCH v3 3/3] RISC-V: Update tlb flush counters
Date: Mon, 29 Apr 2019 14:27:50 -0700
Message-Id: <20190429212750.26165-4-atish.patra@wdc.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190429212750.26165-1-atish.patra@wdc.com>
References: <20190429212750.26165-1-atish.patra@wdc.com>
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

