Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA5A7C04AAA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9130D2084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="z94gwv/h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9130D2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95FBD6B000D; Mon, 13 May 2019 10:39:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E9156B000E; Mon, 13 May 2019 10:39:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 678176B0010; Mon, 13 May 2019 10:39:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5AC6B000E
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:12 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id m20so6802820itn.3
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=ivlXRYid08bCLk7EeeAFLog7R/4eiJfJ3h7LO8cUdeI=;
        b=fbS1/mQSbh6PMhkEnIiUhin95oaoTBBGP7DNXRQduzQKI/JkyjXHhA6IgJjmJi5tm5
         cJhzNhiE0N/5K+jz6eNKHMXNl+K6FlennT6HfGQKjNbulyA8J5RZ4BoY10DcmmEvJF57
         Xf8k+oyifoBVv6YSnsPT1IDXJsXMkBSazqEs1lDkbMGtyI4BT2BITmPijVKfdWuI3Gmf
         l+XZC5VxDoYby+gm+hS849cd2ACvZ6gb6Vc3ezIskZxgYUGA0IRWO2/E5xjOm0uE+h6f
         lspNrXBzeb2En46wioRtN8itsLHzGV1RmTUwR3TddXnoM9oHEMa/297zXdGJT9BC7nHk
         ml6A==
X-Gm-Message-State: APjAAAX/AXrfxTDzUn+iG66IugVXfxXH85fzsnNoapNC0o8tFiTaOU6i
	4iHfKZEnRRnWrh89MvgdLj1QiO50K98E2SLl0lIzAQLyJnGeBkzDqh4db88El+Fzori9ZE5UWl0
	v7GxVQkRR5HHB4bCS0OMzL/mDG9tQivGSPtK4ZwJcROb42awfcZaxFBP+rDbG0q2BQA==
X-Received: by 2002:a05:6602:21d7:: with SMTP id c23mr17786544ioc.66.1557758351971;
        Mon, 13 May 2019 07:39:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdhifnTXo9MXDplt9ld2K9itr4UowiHd6RQXWJ33HTToHgvefN9jETHF7ouGLqTP9DyIFm
X-Received: by 2002:a05:6602:21d7:: with SMTP id c23mr17786503ioc.66.1557758351358;
        Mon, 13 May 2019 07:39:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758351; cv=none;
        d=google.com; s=arc-20160816;
        b=kgOsGn8ikRf9pxLCp2S5bQZXkl6dVunizLbCGyoxlqKm3LoC5V+C1KNEl3J+D9OXfN
         l8kOQVmnWoJlcbv7YHr4wkcFIyJVUS59Y0f565KqtfRAyq7BBYon75mwI6ZQNzTL20Ul
         jOSxkR9x7YHFcc7IHFBxQsOZFUsnbQMLmKoLEOq31I8bSnl2djoJAJEjK1gNGs4f0H3T
         2TrWRY+czoloSASKq6JMFNkGbKBbYs4AMLmWIwpQSXI4B8ratYyH6j4hjWRhO6KHLWHa
         Y5efPeYEi4XW5hdQfMIAR/tH2V6CmJOfBTejCSJANHmXJO4R6OxkE2jx3WM9W3V14aaG
         9IEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=ivlXRYid08bCLk7EeeAFLog7R/4eiJfJ3h7LO8cUdeI=;
        b=rB6syKYztLnCHs7ilES2xClj/sX5+ou1TIFh1an9Jr/tX3kVjSeYVKbQZ30ty6mVWd
         l9WmWccPXvl8b1zY8QzPasBop7843RwgPG4baeiVHkO/a+UqCqiEae6gUNQ63mzCR3Tn
         PMPQ30zAwNkGuEBUd4ay92j67ehHOg95G6x6kPf1R5yEijD1IujzajGciwShuU/Mk2GA
         KEgVjsyTlEJB1U4m/0xDdzcbQA46q9Tfz5qOSc6lyz0HIUQVarPrCX83cPXMkLqn8BJI
         6DG/X1JtU3MaLyPn/54fN3lN/h6PLmNGZ7RGmmDW8Bguk+pqAmCwM8nmmtenaP2lhGcK
         ckrw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="z94gwv/h";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i141si403951iti.137.2019.05.13.07.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="z94gwv/h";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd3QK194955;
	Mon, 13 May 2019 14:39:03 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=ivlXRYid08bCLk7EeeAFLog7R/4eiJfJ3h7LO8cUdeI=;
 b=z94gwv/h6a2eKxGWAbRUGkTU6KQJtXJ5d9W6ZAsILmq9BIFlV0LuM3OrSOh/UH7Pz5NG
 96qNkm9FPETMU1CK7gybTPwq+ay4+eI/5ZBk7+Q+y/kQOV/x7sjuvp8KNOiVPI3sWHJp
 aavXu55k8608Ik9cqQUYuPI190YDw9stqWSKV2ovjULIm12NLn2fEyPVAmeiTcuHgcon
 8059HBgFrgSpkKo1gDcIsSnBF1vNWz4rpcg52v7RzoR3yGYo4g+LLYhNJsd8LIgK7av1
 KVYEFQoIDdxdVwMIjw1yVhHummBBRuJpdrOk80g5n+iCI4jKYptxDL+3/5eTCqCqtgeN 4g== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2sdq1q7atx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:03 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQ8022780;
	Mon, 13 May 2019 14:38:53 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 05/27] KVM: x86: Add handler to exit kvm isolation
Date: Mon, 13 May 2019 16:38:13 +0200
Message-Id: <1557758315-12667-6-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Liran Alon <liran.alon@oracle.com>

Interrupt handlers will need this handler to switch from
the KVM address space back to the kernel address space
on their prelog.

Signed-off-by: Liran Alon <liran.alon@oracle.com>
Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/irq.h |    1 +
 arch/x86/kernel/irq.c      |   11 +++++++++++
 arch/x86/kvm/isolation.c   |   13 +++++++++++++
 3 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/irq.h b/arch/x86/include/asm/irq.h
index 8f95686..eb32abc 100644
--- a/arch/x86/include/asm/irq.h
+++ b/arch/x86/include/asm/irq.h
@@ -29,6 +29,7 @@ static inline int irq_canonicalize(int irq)
 extern __visible void smp_kvm_posted_intr_ipi(struct pt_regs *regs);
 extern __visible void smp_kvm_posted_intr_wakeup_ipi(struct pt_regs *regs);
 extern __visible void smp_kvm_posted_intr_nested_ipi(struct pt_regs *regs);
+extern void kvm_set_isolation_exit_handler(void (*handler)(void));
 #endif
 
 extern void (*x86_platform_ipi_callback)(void);
diff --git a/arch/x86/kernel/irq.c b/arch/x86/kernel/irq.c
index 59b5f2e..e68483b 100644
--- a/arch/x86/kernel/irq.c
+++ b/arch/x86/kernel/irq.c
@@ -295,6 +295,17 @@ void kvm_set_posted_intr_wakeup_handler(void (*handler)(void))
 }
 EXPORT_SYMBOL_GPL(kvm_set_posted_intr_wakeup_handler);
 
+void (*kvm_isolation_exit_handler)(void) = dummy_handler;
+
+void kvm_set_isolation_exit_handler(void (*handler)(void))
+{
+	if (handler)
+		kvm_isolation_exit_handler = handler;
+	else
+		kvm_isolation_exit_handler = dummy_handler;
+}
+EXPORT_SYMBOL_GPL(kvm_set_isolation_exit_handler);
+
 /*
  * Handler for POSTED_INTERRUPT_VECTOR.
  */
diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index 35aa659..22ff9c2 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -5,6 +5,7 @@
  * KVM Address Space Isolation
  */
 
+#include <linux/kvm_host.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/printk.h>
@@ -95,6 +96,16 @@ static void kvm_isolation_uninit_mm(void)
 	free_pages((unsigned long)kvm_pgd, PGD_ALLOCATION_ORDER);
 }
 
+static void kvm_isolation_set_handlers(void)
+{
+	kvm_set_isolation_exit_handler(kvm_isolation_exit);
+}
+
+static void kvm_isolation_clear_handlers(void)
+{
+	kvm_set_isolation_exit_handler(NULL);
+}
+
 int kvm_isolation_init(void)
 {
 	int r;
@@ -106,6 +117,7 @@ int kvm_isolation_init(void)
 	if (r)
 		return r;
 
+	kvm_isolation_set_handlers();
 	pr_info("KVM: x86: Running with isolated address space\n");
 
 	return 0;
@@ -116,6 +128,7 @@ void kvm_isolation_uninit(void)
 	if (!address_space_isolation)
 		return;
 
+	kvm_isolation_clear_handlers();
 	kvm_isolation_uninit_mm();
 	pr_info("KVM: x86: End of isolated address space\n");
 }
-- 
1.7.1

