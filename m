Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 81D4F6B026B
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:25:00 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e63so960762ith.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:25:00 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0066.outbound.protection.outlook.com. [104.47.41.66])
        by mx.google.com with ESMTPS id v34si145596otd.289.2016.08.22.16.24.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:24:59 -0700 (PDT)
Subject: [RFC PATCH v1 06/28] KVM: SVM: Add SEV feature definitions to KVM
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:24:46 -0400
Message-ID: <147190828659.9523.13390615310993962670.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

Define a new KVM cpu feature for Secure Encrypted Virtualization (SEV).
The kernel will check for the presence of this feature to determine if
it is running with SEV active.

Define the SEV enable bit for the VMCB control structure. The hypervisor
will use this bit to enable SEV in the guest.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/svm.h           |    1 +
 arch/x86/include/uapi/asm/kvm_para.h |    1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/x86/include/asm/svm.h b/arch/x86/include/asm/svm.h
index 2aca535..fba2a7b 100644
--- a/arch/x86/include/asm/svm.h
+++ b/arch/x86/include/asm/svm.h
@@ -137,6 +137,7 @@ struct __attribute__ ((__packed__)) vmcb_control_area {
 #define SVM_VM_CR_SVM_DIS_MASK  0x0010ULL
 
 #define SVM_NESTED_CTL_NP_ENABLE	BIT(0)
+#define SVM_NESTED_CTL_SEV_ENABLE	BIT(1)
 
 struct __attribute__ ((__packed__)) vmcb_seg {
 	u16 selector;
diff --git a/arch/x86/include/uapi/asm/kvm_para.h b/arch/x86/include/uapi/asm/kvm_para.h
index 94dc8ca..67dd610f 100644
--- a/arch/x86/include/uapi/asm/kvm_para.h
+++ b/arch/x86/include/uapi/asm/kvm_para.h
@@ -24,6 +24,7 @@
 #define KVM_FEATURE_STEAL_TIME		5
 #define KVM_FEATURE_PV_EOI		6
 #define KVM_FEATURE_PV_UNHALT		7
+#define KVM_FEATURE_SEV			8
 
 /* The last 8 bits are used to indicate how to interpret the flags field
  * in pvclock structure. If no bits are set, all flags are ignored.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
