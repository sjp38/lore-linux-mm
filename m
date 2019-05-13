Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EA2BC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B77632146F
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="P2E6fPrV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B77632146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69CE86B0008; Mon, 13 May 2019 10:39:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 626216B000A; Mon, 13 May 2019 10:39:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C5CD6B000C; Mon, 13 May 2019 10:39:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB7B6B0008
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:10 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id z125so12371547itf.4
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=N+bhv6OONCtHadzhgbU1e3MAiku0pVi0en6iW2c0TrE=;
        b=S8ABYTe2IRA8df7yr9dp+8UgCcn64Rmvw7VL0XpYSc2gF7J4GX5tPKZ4B6SCsimI75
         5xG+t3O8XtLM26k0c2I8AMRqFoGLNAONseEZLgP/E/VPWh9k7TyMKpXqZnzu6FG7qBSC
         aPMbR5oVjwv9wnAIBSV3KbWK8cwzzGwvrskdF5ptnNoiXla9vOM2rFnJh1Mw60ON/Hho
         /3/CH6zfZ6NYc6ivKENt0kkC2IBkrsTWsujN28gxd5GK79odCWjd7WI7M4ZnxtgG6ZpC
         Znyt9QwBVzgp+fcZ9CxMVlFuU4da89nvetbenJjYHzWjSPuV8etqutXSn4nH2BUpjM8t
         rmPw==
X-Gm-Message-State: APjAAAXfSWtYe5t23Ai+oDS7ladS8zNCvNjMYHn8md2Q4RUZwrcww2kN
	tzQAJrkp6XrqyR8L0JN6+TJatcd2kLqDVYMZPqYWx1gFnxiDZviK4JMe9QcYk7XWrvjccs1Xzhx
	j9r5r33fKKlIDuzVZ5jNQ8Il5NLdvIL9OOWGOqruMfGfp9baidGsgPc6onnCz56gImg==
X-Received: by 2002:a24:4f4a:: with SMTP id c71mr19979814itb.65.1557758349853;
        Mon, 13 May 2019 07:39:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhB1+omrxlUzOuk8BY18l7BBCzoolPoDQLGO86ucfvN/xgkCwv20SwjVRy6NHVuAN9B4+n
X-Received: by 2002:a24:4f4a:: with SMTP id c71mr19979710itb.65.1557758348553;
        Mon, 13 May 2019 07:39:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758348; cv=none;
        d=google.com; s=arc-20160816;
        b=f1B6xduM9cUUq+NoaRctMMBqmRSfexjnSH33ravRlE8cwvu+hCf3JAWLXrOYE5OMDG
         6+wnoh8VBXZhIKijyDWKXiGu1JCtjBfuaYwCp+SiCuORJUP5/+mUCVaACbi8ODjX+rWZ
         dQhsytTrqEsuEcRY5DImAsnaarYnKvGBQgmamS9H56OGSe0UZaFRKci8OFfmoz+cv3pK
         dWTjgRkkvamMAn/R+hDcW+Sy19o6cPzpTI/oSKd2ZEo/+sCCbqW2zXKyVbAkEf8fvjIy
         gmTD2ZUEVnPsc/z+d7/zMSGAq0ZcPp4nm01NF5c7FfjjCb4jXQDjvqs7MPNsKsBKbits
         xIUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=N+bhv6OONCtHadzhgbU1e3MAiku0pVi0en6iW2c0TrE=;
        b=KLD0uit/9xK042XGSkN6DEynNR8748BewZfwCnqBZrmO9d5KX8NutrRlqFFOljb4pE
         /39cxlu0MOnrZrxXb0d+Ysh6GQG/+l8vblVZIbFmbgst90haUT4supycGZ0CUxckPZRc
         lUzB1wai+Bh8ZbGsCmWFyhDOUjhXfBLMJNRyEVqqhxXx4YxyBH3NRv5GPASQoAgnFcqL
         VYtqbN/Pm1NpnUr2K4qtdNTTwmTsJOj5M33ichNjHmpuSUvdxnia+ZLrStfUcMY/x8Ip
         jobTWxh/irY/SAUEB5skA52PfLsfr9RBXl8ZlO4OLGsVzDUWTmqhAgBPghGt2PRWPuFx
         QsgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=P2E6fPrV;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w1si7553576iop.69.2019.05.13.07.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=P2E6fPrV;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DESuQq184844;
	Mon, 13 May 2019 14:38:56 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=N+bhv6OONCtHadzhgbU1e3MAiku0pVi0en6iW2c0TrE=;
 b=P2E6fPrVnhroaq8muel0nn2IGVthj4KsZusNGeNWJzt9GowNKpeWiTFc/b69anfJ0Jmu
 oveuhNt89Ikw71ZvGW5vaL++kydq+j4PLd4quL0ofYa2FFOqRahZ4/VLfHaGhpQ4vHLA
 m5ceIwPWsPji5If/gseVw1NXQQCm7CUpEO9gRgNKuigMbubyHEiBRLZ2oXHfdXvE5+yg
 4Vxc4Q0CWq9Ih+MZt7QCjMIpS8BEJfgPaEsyU1ULUJzIGUT76jHo7eJhX4dTAjgX0kjG
 sJYESl+2wGBWqLkwymFi6MuDOCTCpC/bVqNxgtfnEiuBaKSkXU7jAwqSWP/dnuQqoRnn 9A== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2sdq1q7as5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:38:56 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQ6022780;
	Mon, 13 May 2019 14:38:47 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 03/27] KVM: x86: Introduce KVM separate virtual address space
Date: Mon, 13 May 2019 16:38:11 +0200
Message-Id: <1557758315-12667-4-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130102
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Liran Alon <liran.alon@oracle.com>

Create a separate mm for KVM that will be active when KVM #VMExit
handlers run. Up until the point which we architectully need to
access host (or other VM) sensitive data.

This patch just create kvm_mm but never makes it active yet.
This will be done by next commits.

Signed-off-by: Liran Alon <liran.alon@oracle.com>
Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   95 ++++++++++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/isolation.h |    8 ++++
 arch/x86/kvm/x86.c       |   10 ++++-
 3 files changed, 112 insertions(+), 1 deletions(-)
 create mode 100644 arch/x86/kvm/isolation.h

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index e25f663..74bc0cd 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -7,6 +7,21 @@
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
+#include <linux/printk.h>
+
+#include <asm/mmu_context.h>
+#include <asm/pgalloc.h>
+
+#include "isolation.h"
+
+struct mm_struct kvm_mm = {
+	.mm_rb			= RB_ROOT,
+	.mm_users		= ATOMIC_INIT(2),
+	.mm_count		= ATOMIC_INIT(1),
+	.mmap_sem		= __RWSEM_INITIALIZER(kvm_mm.mmap_sem),
+	.page_table_lock	= __SPIN_LOCK_UNLOCKED(kvm_mm.page_table_lock),
+	.mmlist			= LIST_HEAD_INIT(kvm_mm.mmlist),
+};
 
 /*
  * When set to true, KVM #VMExit handlers run in isolated address space
@@ -24,3 +39,83 @@
  */
 static bool __read_mostly address_space_isolation;
 module_param(address_space_isolation, bool, 0444);
+
+static int kvm_isolation_init_mm(void)
+{
+	pgd_t *kvm_pgd;
+	gfp_t gfp_mask;
+
+	gfp_mask = GFP_KERNEL | __GFP_ZERO;
+	kvm_pgd = (pgd_t *)__get_free_pages(gfp_mask, PGD_ALLOCATION_ORDER);
+	if (!kvm_pgd)
+		return -ENOMEM;
+
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+	/*
+	 * With PTI, we have two PGDs: one the kernel page table, and one
+	 * for the user page table. The PGD with the kernel page table has
+	 * to be the entire kernel address space because paranoid faults
+	 * will unconditionally use it. So we define the KVM address space
+	 * in the user table space, although it will be used in the kernel.
+	 */
+
+	/* initialize the kernel page table */
+	memcpy(kvm_pgd, current->active_mm->pgd, sizeof(pgd_t) * PTRS_PER_PGD);
+
+	/* define kvm_mm with the user page table */
+	kvm_mm.pgd = kernel_to_user_pgdp(kvm_pgd);
+#else /* CONFIG_PAGE_TABLE_ISOLATION */
+	kvm_mm.pgd = kvm_pgd;
+#endif /* CONFIG_PAGE_TABLE_ISOLATION */
+	mm_init_cpumask(&kvm_mm);
+	init_new_context(NULL, &kvm_mm);
+
+	return 0;
+}
+
+static void kvm_isolation_uninit_mm(void)
+{
+	pgd_t *kvm_pgd;
+
+	BUG_ON(current->active_mm == &kvm_mm);
+
+	destroy_context(&kvm_mm);
+
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+	/*
+	 * With PTI, the KVM address space is defined in the user
+	 * page table space, but the full PGD starts with the kernel
+	 * page table space.
+	 */
+	kvm_pgd = user_to_kernel_pgdp(kvm_pgd);
+#else /* CONFIG_PAGE_TABLE_ISOLATION */
+	kvm_pgd = kvm_mm.pgd;
+#endif /* CONFIG_PAGE_TABLE_ISOLATION */
+	kvm_mm.pgd = NULL;
+	free_pages((unsigned long)kvm_pgd, PGD_ALLOCATION_ORDER);
+}
+
+int kvm_isolation_init(void)
+{
+	int r;
+
+	if (!address_space_isolation)
+		return 0;
+
+	r = kvm_isolation_init_mm();
+	if (r)
+		return r;
+
+	pr_info("KVM: x86: Running with isolated address space\n");
+
+	return 0;
+}
+
+void kvm_isolation_uninit(void)
+{
+	if (!address_space_isolation)
+		return;
+
+	kvm_isolation_uninit_mm();
+	pr_info("KVM: x86: End of isolated address space\n");
+}
diff --git a/arch/x86/kvm/isolation.h b/arch/x86/kvm/isolation.h
new file mode 100644
index 0000000..cf8c7d4
--- /dev/null
+++ b/arch/x86/kvm/isolation.h
@@ -0,0 +1,8 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef ARCH_X86_KVM_ISOLATION_H
+#define ARCH_X86_KVM_ISOLATION_H
+
+extern int kvm_isolation_init(void);
+extern void kvm_isolation_uninit(void);
+
+#endif
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index b5edc8e..4b7cec2 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -29,6 +29,7 @@
 #include "cpuid.h"
 #include "pmu.h"
 #include "hyperv.h"
+#include "isolation.h"
 
 #include <linux/clocksource.h>
 #include <linux/interrupt.h>
@@ -6972,10 +6973,14 @@ int kvm_arch_init(void *opaque)
 		goto out_free_x86_fpu_cache;
 	}
 
-	r = kvm_mmu_module_init();
+	r = kvm_isolation_init();
 	if (r)
 		goto out_free_percpu;
 
+	r = kvm_mmu_module_init();
+	if (r)
+		goto out_uninit_isolation;
+
 	kvm_set_mmio_spte_mask();
 
 	kvm_x86_ops = ops;
@@ -7000,6 +7005,8 @@ int kvm_arch_init(void *opaque)
 
 	return 0;
 
+out_uninit_isolation:
+	kvm_isolation_uninit();
 out_free_percpu:
 	free_percpu(shared_msrs);
 out_free_x86_fpu_cache:
@@ -7024,6 +7031,7 @@ void kvm_arch_exit(void)
 #ifdef CONFIG_X86_64
 	pvclock_gtod_unregister_notifier(&pvclock_gtod_notifier);
 #endif
+	kvm_isolation_uninit();
 	kvm_x86_ops = NULL;
 	kvm_mmu_module_exit();
 	free_percpu(shared_msrs);
-- 
1.7.1

