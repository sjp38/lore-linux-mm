Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4EE3C282CB
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:15:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6557F2175B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:15:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L7X4qKJ6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6557F2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BD7A8E0050; Mon,  4 Feb 2019 13:15:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 070588E001C; Mon,  4 Feb 2019 13:15:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9FBE8E0050; Mon,  4 Feb 2019 13:15:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A59188E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 13:15:49 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id y88so494537pfi.9
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 10:15:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=nq0LeNkhaffr3QT/wk9IUrhhpxaGavdHfyKoMsgvjdo=;
        b=lEsjSoxIL7xTLEfU7JH+Gt/xE5cJaxlcnHok9CP/5Xth1FdA5+lj7kiRzDIjDMbtOr
         osP7VijmYfVyMuH25xZEivfqtFkV/tlyUV0FKiZhwJpfBoNzwKlkT6mkzyiUCH/OUMrq
         EbIocBAiMJYB90giI1OlZD3Fw7u9Hmr4vQ5fLs+RmHSEbqDbYwSVB7JCdjtsaSFX/ufw
         tdIt6Mf3BwM24jBuCem6VGeVxR72s/9UaWVkVnuuTUkXbt8dMDJ4Z8q7vRhpOQ33qrVZ
         EPSTtoS92P2Ydl7I5B/DaZ7smsTbgMUTjq+7yFeYaKsYUJchAXjUXdULzyQdTtyXcBPt
         HMGw==
X-Gm-Message-State: AHQUAuaTnnP62NoTLod/eIPfm3YtWrFqjBpwvfwCMbyZ8bjnuthQM8Gw
	N8UEc4sjBLOVNesTFyKtunniw/Mmh1tLBfGyyxH+lcvxH+qufzzbelcUeIQhYxgK4G6JDLCFwpO
	B/zja6oQ3bVTvoLWa542Po93UyZesVHh31HXQawOkKqi+ykMTn+I4V3/I4axS7MtCdXf6YfcJkz
	GhW0puCiPJHw2+2zi+iz7zt6cQLxDwvcv7/0ZAb9siBn54/9P1n5lGR4PAw3ij83iRJWXdDhvAD
	b4bapgXkQNjSlvHv/50ChDbs0gKsifSWFuJlGxWu9XJElvSupiIeusAse8/8u+GkBlHk/2j9Y9y
	G7T6UlwZVeWtniEsswEtLP7U2vZ7zpniOQKHo0jfcda7LR4rQaOU7eOofwR3fDgXujLVjKfqYBE
	t
X-Received: by 2002:a63:2303:: with SMTP id j3mr583044pgj.391.1549304149247;
        Mon, 04 Feb 2019 10:15:49 -0800 (PST)
X-Received: by 2002:a63:2303:: with SMTP id j3mr582967pgj.391.1549304148192;
        Mon, 04 Feb 2019 10:15:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549304148; cv=none;
        d=google.com; s=arc-20160816;
        b=igWKkir2XH2YiKYUJkiCml6TYIgB/DHavavEnYkYSm2LXJAELm44hourFId1Qu0Rk0
         UneVzoKRy++EoHt5ZF7oOQgbBH2Wgc1kzXB9A18vf7mnrntNpY+ngQVrWPHR++ndGj18
         bwGYeZ6TaSlzSiKorAOjZkm16tMavY4Q+3TdIBujayKFLrjtANrl8KhlEeZ4SX7WAYtW
         OWv5RE0aYRdd3Tav+RAol0Ce6AyF4JjuZJaOnm6/w6QTzY+8ZMBuD97DJvWJsplHQbjK
         wnusWpPJvwsfV/jJhNClYHqdt5y0Kt49obRZOv91KFIlhDbEUxJy3+nv4LAUSy3xE2eG
         1EPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=nq0LeNkhaffr3QT/wk9IUrhhpxaGavdHfyKoMsgvjdo=;
        b=ohcu0QtTeU+aBm1aqDCWNWqdUH+F86pIo3byNJEKRu3SqwObsFmZu3J6pEy0rXfL2e
         6vARF+YJreUw0oCeeEq+zcmAVNZZeu776TuBOGXDYXxYnnPlAZiY8bvWGeps2eMb8LV1
         u8RWY++vku/8VhJ2GzbZYWARi8BD1PSd/z5cj/eXCJIZmHwSOabYhkYLhQRdPsPFdmpk
         VMmZBMvk5n582uIbj+/Ma8on86ch0WZYzEFlvb4w84MBx3n4CvXJ1HanX8ec4Vz5WRpX
         B2ZvI90OfUq6cAiHw2joGpqm3oOE1SATeDRxrI1UNXqlbxiGcCCXfGTPHcyQBNSx6iv2
         Ws9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=L7X4qKJ6;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k37sor1311832pgb.78.2019.02.04.10.15.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 10:15:48 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=L7X4qKJ6;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=nq0LeNkhaffr3QT/wk9IUrhhpxaGavdHfyKoMsgvjdo=;
        b=L7X4qKJ6GtgkMcoLCzJQFQp5YQflLDPqBeUBgAQS/WXNVw9NqiYnEdhx6yzV/spFHf
         7L6vF0PKeQfrqkdqNkzH3QVdqEBRrkySxTix4y/7CmVOEzkdHP528G8v2K4DbX4S0WV2
         AhSF+d4Gsnd8UxoIwWQ8vQD/e9fxTkgZdr562N5/FfkuEGVN08h77ixyK50tK0aEZWUz
         S3qkPFlc6MIeg2bP73mBpc4Z++3TXyhuw9NU68HOgeGg+81CIb7tNpBUAAWspG1rQu+J
         wp+8/e5Z5znfNnx7la1axnMHEZ93SPljoKMEtbwXuayDg+bCSFIS50QchxDi7o75IWLR
         nAKA==
X-Google-Smtp-Source: AHgI3IaZMHStqmgitk+Th2B3stPdDyvz8KaztFDV/2BXNVgK22LkFei1Bc7H+nadwdx82aStWOarZQ==
X-Received: by 2002:a63:4665:: with SMTP id v37mr575190pgk.425.1549304147758;
        Mon, 04 Feb 2019 10:15:47 -0800 (PST)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id x11sm1092934pfe.72.2019.02.04.10.15.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 10:15:47 -0800 (PST)
Subject: [RFC PATCH 2/4] kvm: Add host side support for free memory hints
From: Alexander Duyck <alexander.duyck@gmail.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org
Date: Mon, 04 Feb 2019 10:15:46 -0800
Message-ID: <20190204181546.12095.81356.stgit@localhost.localdomain>
In-Reply-To: <20190204181118.12095.38300.stgit@localhost.localdomain>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Add the host side of the KVM memory hinting support. With this we expose a
feature bit indicating that the host will pass the messages along to the
new madvise function.

This functionality is mutually exclusive with device assignment. If a
device is assigned we will disable the functionality as it could lead to a
potential memory corruption if a device writes to a page after KVM has
flagged it as not being used.

The logic as it is currently defined limits the hint to only supporting a
hugepage or larger notifications. This is meant to help prevent us from
potentially breaking up huge pages by hinting that only a portion of the
page is not needed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 Documentation/virtual/kvm/cpuid.txt      |    4 +++
 Documentation/virtual/kvm/hypercalls.txt |   14 ++++++++++++
 arch/x86/include/uapi/asm/kvm_para.h     |    3 +++
 arch/x86/kvm/cpuid.c                     |    6 ++++-
 arch/x86/kvm/x86.c                       |   35 ++++++++++++++++++++++++++++++
 include/uapi/linux/kvm_para.h            |    1 +
 6 files changed, 62 insertions(+), 1 deletion(-)

diff --git a/Documentation/virtual/kvm/cpuid.txt b/Documentation/virtual/kvm/cpuid.txt
index 97ca1940a0dc..fe3395a58b7e 100644
--- a/Documentation/virtual/kvm/cpuid.txt
+++ b/Documentation/virtual/kvm/cpuid.txt
@@ -66,6 +66,10 @@ KVM_FEATURE_PV_SEND_IPI            ||    11 || guest checks this feature bit
                                    ||       || before using paravirtualized
                                    ||       || send IPIs.
 ------------------------------------------------------------------------------
+KVM_FEATURE_PV_UNUSED_PAGE_HINT    ||    12 || guest checks this feature bit
+                                   ||       || before using paravirtualized
+                                   ||       || unused page hints.
+------------------------------------------------------------------------------
 KVM_FEATURE_CLOCKSOURCE_STABLE_BIT ||    24 || host will warn if no guest-side
                                    ||       || per-cpu warps are expected in
                                    ||       || kvmclock.
diff --git a/Documentation/virtual/kvm/hypercalls.txt b/Documentation/virtual/kvm/hypercalls.txt
index da24c138c8d1..b374678ac1f9 100644
--- a/Documentation/virtual/kvm/hypercalls.txt
+++ b/Documentation/virtual/kvm/hypercalls.txt
@@ -141,3 +141,17 @@ a0 corresponds to the APIC ID in the third argument (a2), bit 1
 corresponds to the APIC ID a2+1, and so on.
 
 Returns the number of CPUs to which the IPIs were delivered successfully.
+
+7. KVM_HC_UNUSED_PAGE_HINT
+------------------------
+Architecture: x86
+Status: active
+Purpose: Send unused page hint to host
+
+a0: physical address of region unused, page aligned
+a1: size of unused region, page aligned
+
+The hypercall lets a guest send notifications to the host that it will no
+longer be using a given page in memory. Multiple pages can be hinted at by
+using the size field to hint that a higher order page is available by
+specifying the higher order page size.
diff --git a/arch/x86/include/uapi/asm/kvm_para.h b/arch/x86/include/uapi/asm/kvm_para.h
index 19980ec1a316..f066c23060df 100644
--- a/arch/x86/include/uapi/asm/kvm_para.h
+++ b/arch/x86/include/uapi/asm/kvm_para.h
@@ -29,6 +29,7 @@
 #define KVM_FEATURE_PV_TLB_FLUSH	9
 #define KVM_FEATURE_ASYNC_PF_VMEXIT	10
 #define KVM_FEATURE_PV_SEND_IPI	11
+#define KVM_FEATURE_PV_UNUSED_PAGE_HINT	12
 
 #define KVM_HINTS_REALTIME      0
 
@@ -119,4 +120,6 @@ struct kvm_vcpu_pv_apf_data {
 #define KVM_PV_EOI_ENABLED KVM_PV_EOI_MASK
 #define KVM_PV_EOI_DISABLED 0x0
 
+#define KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER	HUGETLB_PAGE_ORDER
+
 #endif /* _UAPI_ASM_X86_KVM_PARA_H */
diff --git a/arch/x86/kvm/cpuid.c b/arch/x86/kvm/cpuid.c
index bbffa6c54697..b82bcbfbc420 100644
--- a/arch/x86/kvm/cpuid.c
+++ b/arch/x86/kvm/cpuid.c
@@ -136,6 +136,9 @@ int kvm_update_cpuid(struct kvm_vcpu *vcpu)
 	if (kvm_hlt_in_guest(vcpu->kvm) && best &&
 		(best->eax & (1 << KVM_FEATURE_PV_UNHALT)))
 		best->eax &= ~(1 << KVM_FEATURE_PV_UNHALT);
+	if (kvm_arch_has_assigned_device(vcpu->kvm) && best &&
+		(best->eax & KVM_FEATURE_PV_UNUSED_PAGE_HINT))
+		best->eax &= ~(1 << KVM_FEATURE_PV_UNUSED_PAGE_HINT);
 
 	/* Update physical-address width */
 	vcpu->arch.maxphyaddr = cpuid_query_maxphyaddr(vcpu);
@@ -637,7 +640,8 @@ static inline int __do_cpuid_ent(struct kvm_cpuid_entry2 *entry, u32 function,
 			     (1 << KVM_FEATURE_PV_UNHALT) |
 			     (1 << KVM_FEATURE_PV_TLB_FLUSH) |
 			     (1 << KVM_FEATURE_ASYNC_PF_VMEXIT) |
-			     (1 << KVM_FEATURE_PV_SEND_IPI);
+			     (1 << KVM_FEATURE_PV_SEND_IPI) |
+			     (1 << KVM_FEATURE_PV_UNUSED_PAGE_HINT);
 
 		if (sched_info_on())
 			entry->eax |= (1 << KVM_FEATURE_STEAL_TIME);
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 3d27206f6c01..3ec75ab849e2 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -55,6 +55,7 @@
 #include <linux/irqbypass.h>
 #include <linux/sched/stat.h>
 #include <linux/mem_encrypt.h>
+#include <linux/mm.h>
 
 #include <trace/events/kvm.h>
 
@@ -7052,6 +7053,37 @@ void kvm_vcpu_deactivate_apicv(struct kvm_vcpu *vcpu)
 	kvm_x86_ops->refresh_apicv_exec_ctrl(vcpu);
 }
 
+static int kvm_pv_unused_page_hint_op(struct kvm *kvm, gpa_t gpa, size_t len)
+{
+	unsigned long start;
+
+	/*
+	 * Guarantee the following:
+	 *	len meets minimum size
+	 *	len is a power of 2
+	 *	gpa is aligned to len
+	 */
+	if (len < (PAGE_SIZE << KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER))
+		return -KVM_EINVAL;
+	if (!is_power_of_2(len) || !IS_ALIGNED(gpa, len))
+		return -KVM_EINVAL;
+
+	/*
+	 * If a device is assigned we cannot use use madvise as memory
+	 * is shared with the device and could lead to memory corruption
+	 * if the device writes to it after free.
+	 */
+	if (kvm_arch_has_assigned_device(kvm))
+		return -KVM_EOPNOTSUPP;
+
+	start = gfn_to_hva(kvm, gpa_to_gfn(gpa));
+
+	if (kvm_is_error_hva(start + len))
+		return -KVM_EFAULT;
+
+	return do_madvise_dontneed(start, len);
+}
+
 int kvm_emulate_hypercall(struct kvm_vcpu *vcpu)
 {
 	unsigned long nr, a0, a1, a2, a3, ret;
@@ -7098,6 +7130,9 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu)
 	case KVM_HC_SEND_IPI:
 		ret = kvm_pv_send_ipi(vcpu->kvm, a0, a1, a2, a3, op_64_bit);
 		break;
+	case KVM_HC_UNUSED_PAGE_HINT:
+		ret = kvm_pv_unused_page_hint_op(vcpu->kvm, a0, a1);
+		break;
 	default:
 		ret = -KVM_ENOSYS;
 		break;
diff --git a/include/uapi/linux/kvm_para.h b/include/uapi/linux/kvm_para.h
index 6c0ce49931e5..75643b862a4e 100644
--- a/include/uapi/linux/kvm_para.h
+++ b/include/uapi/linux/kvm_para.h
@@ -28,6 +28,7 @@
 #define KVM_HC_MIPS_CONSOLE_OUTPUT	8
 #define KVM_HC_CLOCK_PAIRING		9
 #define KVM_HC_SEND_IPI		10
+#define KVM_HC_UNUSED_PAGE_HINT		11
 
 /*
  * hypercalls use architecture specific

