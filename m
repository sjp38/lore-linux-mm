Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58209C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F37BF2084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:40:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="sU2LVxvs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F37BF2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A47B86B0277; Mon, 13 May 2019 10:39:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 983286B0278; Mon, 13 May 2019 10:39:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 785BE6B0279; Mon, 13 May 2019 10:39:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 572B26B0277
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:53 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id n24so497361ioo.23
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=OxanbwcMAhQGR2MgwGG1WhL6eejs6scvJBA++WEfeAY=;
        b=LkJiSepkvLmNXqrDMMLHUfXKxUYKvVV9LOg9VBsisJDC0I1dS37ow4DYa9XdMlnLwg
         AjXr1l/VAEKh8HUTKnd5ywUgjDW6PIRnEGCZSAsNP+98tRTTCKzBpEMw3TP/ulwqVtq0
         Bkzl46+VyCyTEohGXCPhfNrkSV63ZuRbIwLDT1AvumuqiqTC6EhJMhEA2FXHqyhpus52
         IauWS8mX8cgwCSdmbiqm55xprqI9XzsGkE9yzmdXVJcEt6f18uzNkbLX3jHNvtFS9QZB
         yHFcV66rpdhdm/VmAzlsrc5J3hNjoNrz+r3l3sXKTPzzc85I73LJ/BM/pgjeCD3ZSYli
         skOg==
X-Gm-Message-State: APjAAAULVQzDTWyaeaFdNed1cCNtcyoyGBF6UflPgS+qzibup2aKz3Cz
	TFYFPGH5yQO3gt3KjN/VdUBzucUZcFzvT+ax69EcJCtPQ6vhpVbll9auNWV2iRZI6oA8QJ1PdxW
	dCvjCkJRzf738lQsFxfbQ1VuePldIRHeEO7HrVqpoxQGoPwSwGz2UJPJ2mvdnmbqlPA==
X-Received: by 2002:a24:274e:: with SMTP id g75mr17314962ita.34.1557758393095;
        Mon, 13 May 2019 07:39:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUYv0YQ5TP5w40sgJLkPrNWnEwDO7MEqo1zEgN9Bguiy6+bZtW99b0h3Qb/D+SQIa84KwA
X-Received: by 2002:a24:274e:: with SMTP id g75mr17314906ita.34.1557758392267;
        Mon, 13 May 2019 07:39:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758392; cv=none;
        d=google.com; s=arc-20160816;
        b=MUIONStcK1rPTUWTkxnmq/rsCumOZWK5hLNBL6Wq+ylAu8m1iVhTVFnz0GeoI4vHgH
         4zSQveymIYwgear2mYQuTCxvglJMnNfi33VvunUVTYRZtenmUatMdGC90lzWINitlz7B
         oC5et0e4LPFP9l83jkKlBXmqTIFgPOXNvijeYQjhovQxJIETtkq80sBqibvgecoTyBNl
         qseHwzXrY2R1UFG4XVmYBrCds/7dssRlNODDUAjxfE3vIaNjDdN4AHMFegtBN7spTpgW
         QU2VJIaASLYcgYuUtJUViq1kzAbVnfj0WiVYY1Yj8GgReBUzUI+xEu7MR6OogMxQWxuG
         9+fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=OxanbwcMAhQGR2MgwGG1WhL6eejs6scvJBA++WEfeAY=;
        b=TjbKGdIc8bbmVDCQ1dOFBeGKiwkA0+ADcTUYUGMteAewPo6k9mIf1rfifN0yJuf+R8
         dZzE9RdzFFiPRkiddleC9avTvruCw6bAbtU7M9l9y8/Ym7ZsIua6YayPxUbAz5E64IcP
         yzroy3WI4+CeI67FSZwpeLkAVq0bmkbN1pwvbUw+skj9TqiPx0ssGE8nZ6aa+9YuV1en
         Ixp1TXMo6ARxjGqpx9lqLf5UkIjYPGcjTa+2jPD7GuJ49Eq44MWGGF0gpvnkwfsYfr2O
         WHzcN1fsszfTAGDtcFmkBunAfL8q57oqKmjR5aSVOF/0kaW7KH6IZ6pRt2Z3Y/RvDrD1
         kfVw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sU2LVxvs;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 7si8146824itv.107.2019.05.13.07.39.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sU2LVxvs;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd3dD181544;
	Mon, 13 May 2019 14:39:43 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=OxanbwcMAhQGR2MgwGG1WhL6eejs6scvJBA++WEfeAY=;
 b=sU2LVxvsJrs8djlyFSIdZHIRCpnGERg2UYPNUhkjBZS5y33p5PwL4YfHc1GeuRzDdQDc
 tI0T4yhU0dK1zriLrw7oc9ar2kWJb8ndOWDLgtO2S3p47ONlJjMT8DUNuiH6bnk/HBS8
 4pRTCY+QUM4kQQE3oKH19lJQLedFyMmlQevJV2qxd27nI0pcuQGDzWA0LWRRFA/SWQEU
 nPdKdbh2dWUUqgGbATEXLToM31SW1rDh84aMrX31dZ5ifOINbXk1GaZ1ybT260MDzhmO
 Rv/V6YNnfjMVWcuyQ7jnbONxErhqEaY2u+iG8myukAxzaJ4GJAWzjMX/sNhelawAFCXL Aw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2sdnttfejj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:42 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQO022780;
	Mon, 13 May 2019 14:39:39 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 21/27] kvm/isolation: initialize the KVM page table with vmx VM data
Date: Mon, 13 May 2019 16:38:29 +0200
Message-Id: <1557758315-12667-22-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=2
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Map VM data, in particular the kvm structure data.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   17 +++++++++++++++++
 arch/x86/kvm/isolation.h |    2 ++
 arch/x86/kvm/vmx/vmx.c   |   31 ++++++++++++++++++++++++++++++-
 arch/x86/kvm/x86.c       |   12 ++++++++++++
 include/linux/kvm_host.h |    1 +
 virt/kvm/arm/arm.c       |    4 ++++
 virt/kvm/kvm_main.c      |    2 +-
 7 files changed, 67 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index cf5ee0d..d3ac014 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -1222,6 +1222,23 @@ static void kvm_isolation_clear_handlers(void)
 	kvm_set_isolation_exit_handler(NULL);
 }
 
+int kvm_isolation_init_vm(struct kvm *kvm)
+{
+	if (!kvm_isolation())
+		return 0;
+
+	return (kvm_copy_percpu_mapping(kvm->srcu.sda,
+		sizeof(struct srcu_data)));
+}
+
+void kvm_isolation_destroy_vm(struct kvm *kvm)
+{
+	if (!kvm_isolation())
+		return;
+
+	kvm_clear_percpu_mapping(kvm->srcu.sda);
+}
+
 int kvm_isolation_init(void)
 {
 	int r;
diff --git a/arch/x86/kvm/isolation.h b/arch/x86/kvm/isolation.h
index 1f79e28..33e9a87 100644
--- a/arch/x86/kvm/isolation.h
+++ b/arch/x86/kvm/isolation.h
@@ -23,6 +23,8 @@ static inline bool kvm_isolation(void)
 
 extern int kvm_isolation_init(void);
 extern void kvm_isolation_uninit(void);
+extern int kvm_isolation_init_vm(struct kvm *kvm);
+extern void kvm_isolation_destroy_vm(struct kvm *kvm);
 extern void kvm_isolation_enter(void);
 extern void kvm_isolation_exit(void);
 extern void kvm_may_access_sensitive_data(struct kvm_vcpu *vcpu);
diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index f181b3c..5b52e8c 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -6523,6 +6523,33 @@ static void vmx_vcpu_run(struct kvm_vcpu *vcpu)
 	vmx_complete_interrupts(vmx);
 }
 
+static void vmx_unmap_vm(struct kvm *kvm)
+{
+	struct kvm_vmx *kvm_vmx = to_kvm_vmx(kvm);
+
+	if (!kvm_isolation())
+		return;
+
+	pr_debug("unmapping kvm %p", kvm_vmx);
+	kvm_clear_range_mapping(kvm_vmx);
+}
+
+static int vmx_map_vm(struct kvm *kvm)
+{
+	struct kvm_vmx *kvm_vmx = to_kvm_vmx(kvm);
+
+	if (!kvm_isolation())
+		return 0;
+
+	pr_debug("mapping kvm %p", kvm_vmx);
+	/*
+	 * Only copy kvm_vmx struct mapping because other
+	 * attributes (like kvm->srcu) are not initialized
+	 * yet.
+	 */
+	return kvm_copy_ptes(kvm_vmx, sizeof(struct kvm_vmx));
+}
+
 static struct kvm *vmx_vm_alloc(void)
 {
 	struct kvm_vmx *kvm_vmx = __vmalloc(sizeof(struct kvm_vmx),
@@ -6533,6 +6560,7 @@ static void vmx_vcpu_run(struct kvm_vcpu *vcpu)
 
 static void vmx_vm_free(struct kvm *kvm)
 {
+	vmx_unmap_vm(kvm);
 	vfree(to_kvm_vmx(kvm));
 }
 
@@ -6702,7 +6730,8 @@ static int vmx_vm_init(struct kvm *kvm)
 			break;
 		}
 	}
-	return 0;
+
+	return (vmx_map_vm(kvm));
 }
 
 static void __init vmx_check_processor_compat(void *rtn)
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 1db72c3..e1cc3a6 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -9207,6 +9207,17 @@ int kvm_arch_init_vm(struct kvm *kvm, unsigned long type)
 	return 0;
 }
 
+void kvm_arch_vm_postcreate(struct kvm *kvm)
+{
+	/*
+	 * The kvm structure is mapped in vmx.c so that the full kvm_vmx
+	 * structure can be mapped. Attributes allocated in the kvm
+	 * structure (like kvm->srcu) are mapped by kvm_isolation_init_vm()
+	 * because they are not initialized when vmx.c maps the kvm structure.
+	 */
+	kvm_isolation_init_vm(kvm);
+}
+
 static void kvm_unload_vcpu_mmu(struct kvm_vcpu *vcpu)
 {
 	vcpu_load(vcpu);
@@ -9320,6 +9331,7 @@ void kvm_arch_destroy_vm(struct kvm *kvm)
 		x86_set_memory_region(kvm, IDENTITY_PAGETABLE_PRIVATE_MEMSLOT, 0, 0);
 		x86_set_memory_region(kvm, TSS_PRIVATE_MEMSLOT, 0, 0);
 	}
+	kvm_isolation_destroy_vm(kvm);
 	if (kvm_x86_ops->vm_destroy)
 		kvm_x86_ops->vm_destroy(kvm);
 	kvm_pic_destroy(kvm);
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 640a036..ad24d9e 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -932,6 +932,7 @@ static inline bool kvm_arch_intc_initialized(struct kvm *kvm)
 
 int kvm_arch_init_vm(struct kvm *kvm, unsigned long type);
 void kvm_arch_destroy_vm(struct kvm *kvm);
+void kvm_arch_vm_postcreate(struct kvm *kvm);
 void kvm_arch_sync_events(struct kvm *kvm);
 
 int kvm_cpu_has_pending_timer(struct kvm_vcpu *vcpu);
diff --git a/virt/kvm/arm/arm.c b/virt/kvm/arm/arm.c
index f412ebc..0921cb3 100644
--- a/virt/kvm/arm/arm.c
+++ b/virt/kvm/arm/arm.c
@@ -156,6 +156,10 @@ int kvm_arch_init_vm(struct kvm *kvm, unsigned long type)
 	return ret;
 }
 
+void kvm_arch_vm_postcreate(struct kvm *kvm)
+{
+}
+
 bool kvm_arch_has_vcpu_debugfs(void)
 {
 	return false;
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index a704d1f..3c0c3db 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -3366,7 +3366,7 @@ static int kvm_dev_ioctl_create_vm(unsigned long type)
 		return -ENOMEM;
 	}
 	kvm_uevent_notify_change(KVM_EVENT_CREATE_VM, kvm);
-
+	kvm_arch_vm_postcreate(kvm);
 	fd_install(r, file);
 	return r;
 
-- 
1.7.1

