Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22B41C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6BD0208CA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6BD0208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDED16B02BB; Thu,  6 Jun 2019 16:15:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C695E6B02BD; Thu,  6 Jun 2019 16:15:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B09376B02BC; Thu,  6 Jun 2019 16:15:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0366B02B9
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:42 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d2so2144957pla.18
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=93Gwv6XnAt1YbfZeHX2fnzvAW5eh83qpiHtLTKRMHGE=;
        b=m27vzOtDtOFADDuuy52108UxlQfykoxtaSN6/TLD3B0h/plAXeVCzP8QxReeGa287D
         BOnA/+b6NpGNpolXUdB5p7IxibvdqT9/w49J+/deICgN38JzV1ibEdTYAPyLlef80f0s
         FvShX108JNlt4nwwF3BZJ2mcjxgK6mFW2LHRLzplcovO+bL+3464ntb3clEpTJ0w5Kfl
         5IDXjExFLgIb1HyWplvxiyHiFfZNCSWbtDjdkKH76LsQJPvzh10iyRIOnrDPK8QqWv0F
         EHk5jIbjS7+0D8SM/93uYPSj6pUhjS2naHA8/ghPXpYR4ue2jRD2I4ARFJNeikxavEVw
         3m3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWFq2tCC62JYKAkazX121L3NRZ7zgwzNbdEQNwDHy9wN3bOLmaX
	J7HrC28JF6FPhWkRqjxbSoLTzVUiQHXDtw3Y84cp7PQFP3N7l67+2w/A+B09CKgaJBM2EMQbQdN
	ZHJNYS1ppzMyU3yiQrFw39QkqygiBrDbckULQ05FnLnADRtcdawgR157PqVpTG3o0BQ==
X-Received: by 2002:a62:7552:: with SMTP id q79mr34939971pfc.71.1559852142032;
        Thu, 06 Jun 2019 13:15:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyfMgMUsp/XTMX9yjOEsC6l0q8LVvYp1H9+muASRZvqVaRIIhtMePigwDYJLA1jXNGjB1z
X-Received: by 2002:a62:7552:: with SMTP id q79mr34939866pfc.71.1559852140520;
        Thu, 06 Jun 2019 13:15:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852140; cv=none;
        d=google.com; s=arc-20160816;
        b=MhX1xgA8CQ3cjmnE6q66f6D8fWe+n6Ia8UlOaETtNM433FLRvV60OXUx5GB0hxXKMO
         t03M8eiet0sRV2Ac6WMrI4ZMI1hjHlgz1dzpvVKkAhI027EAHfaQRCZtPZWmVyQqj0fT
         Fc4HyKlK0ltlEytFxbuaT+OPPC0XoJGnTWL84ut5Pb80HKfkn399vqdpwfkI9UaZOum3
         /oZJQBQmtghVUhWWxFnDNLa0FVLm9jp7BCMQjNJXCL7KPL6AearL+xGMGjggyzOe+6vi
         5yssJ+zeHJSWXWfusXn9rkba6XUFsSu1nMyt6Qd3oztkwN2msKPT/p6S8JfxBFju/O66
         MoMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=93Gwv6XnAt1YbfZeHX2fnzvAW5eh83qpiHtLTKRMHGE=;
        b=myralCXL5KVr/PInZewvNq4VM07tGLI8226E60M8uRY0Dd1s+jer8ywvXVxHamCo8i
         tmz7aNc4LVymEqKcYruqv/jv53AhqgSXDDHY5vRUFIPFaK+B1EY/1IiLjwrzcVimsHdK
         +bU2fPu6K0eBoKYq8A/B0uV+JK96ek43s8mGP4DPJaaJhGkX646QOAM8RO0IZQFS/vFz
         OsM0N1vJcm88EPvkMaFvvUChmZSNZA8Jd5oMxSDJYOci4Z1Ue4dGiUG0xi4O7lHj0ke7
         Mxsy1xcjurXORexND+NgyTPuUXQcIlQBBGw7E9taXhPWS4ZTYA8W+qSGMTZjdeGpg/cA
         QkNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:40 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:38 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 24/27] x86/cet/shstk: Handle thread shadow stack
Date: Thu,  6 Jun 2019 13:06:43 -0700
Message-Id: <20190606200646.3951-25-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The shadow stack for clone/fork is handled as the following:

(1) If ((clone_flags & (CLONE_VFORK | CLONE_VM)) == CLONE_VM),
    the kernel allocates (and frees on thread exit) a new SHSTK
    for the child.

    It is possible for the kernel to complete the clone syscall
    and set the child's SHSTK pointer to NULL and let the child
    thread allocate a SHSTK for itself.  There are two issues
    in this approach: It is not compatible with existing code
    that does inline syscall and it cannot handle signals before
    the child can successfully allocate a SHSTK.

(2) For (clone_flags & CLONE_VFORK), the child uses the existing
    SHSTK.

(3) For all other cases, the SHSTK is copied/reused whenever the
    parent or the child does a call/ret.

This patch handles cases (1) & (2).  Case (3) is handled in the
SHSTK page fault patches.

A 64-bit SHSTK has a fixed size of RLIMIT_STACK. A compat-mode
thread SHSTK has a fixed size of 1/4 RLIMIT_STACK.  This allows
more threads to share a 32-bit address space.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h         |  2 ++
 arch/x86/include/asm/mmu_context.h |  3 +++
 arch/x86/kernel/cet.c              | 41 ++++++++++++++++++++++++++++++
 arch/x86/kernel/process.c          |  1 +
 arch/x86/kernel/process_64.c       |  7 +++++
 5 files changed, 54 insertions(+)

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index 422ccb8adbb7..52c506a68848 100644
--- a/arch/x86/include/asm/cet.h
+++ b/arch/x86/include/asm/cet.h
@@ -19,12 +19,14 @@ struct cet_status {
 
 #ifdef CONFIG_X86_INTEL_CET
 int cet_setup_shstk(void);
+int cet_setup_thread_shstk(struct task_struct *p);
 void cet_disable_shstk(void);
 void cet_disable_free_shstk(struct task_struct *p);
 int cet_restore_signal(bool ia32, struct sc_ext *sc);
 int cet_setup_signal(bool ia32, unsigned long rstor, struct sc_ext *sc);
 #else
 static inline int cet_setup_shstk(void) { return -EINVAL; }
+static inline int cet_setup_thread_shstk(struct task_struct *p) { return 0; }
 static inline void cet_disable_shstk(void) {}
 static inline void cet_disable_free_shstk(struct task_struct *p) {}
 static inline int cet_restore_signal(bool ia32, struct sc_ext *sc) { return -EINVAL; }
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 9024236693d2..a9a768529540 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -13,6 +13,7 @@
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
 #include <asm/mpx.h>
+#include <asm/cet.h>
 #include <asm/debugreg.h>
 
 extern atomic64_t last_mm_ctx_id;
@@ -228,6 +229,8 @@ do {						\
 #else
 #define deactivate_mm(tsk, mm)			\
 do {						\
+	if (!tsk->vfork_done)			\
+		cet_disable_free_shstk(tsk);	\
 	load_gs_index(0);			\
 	loadsegment(fs, 0);			\
 } while (0)
diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index b247cd15c1e2..9ef1af617d38 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -151,6 +151,47 @@ int cet_setup_shstk(void)
 	return 0;
 }
 
+int cet_setup_thread_shstk(struct task_struct *tsk)
+{
+	unsigned long addr, size;
+	struct cet_user_state *state;
+
+	if (!current->thread.cet.shstk_enabled)
+		return 0;
+
+	state = get_xsave_addr(&tsk->thread.fpu.state.xsave,
+			       XFEATURE_CET_USER);
+
+	if (!state)
+		return -EINVAL;
+
+	size = rlimit(RLIMIT_STACK);
+
+	/*
+	 * Compat-mode pthreads share a limited address space.
+	 * If each function call takes an average of four slots
+	 * stack space, we need 1/4 of stack size for shadow stack.
+	 */
+	if (in_compat_syscall())
+		size /= 4;
+
+	addr = do_mmap_locked(0, size, PROT_READ,
+			      MAP_ANONYMOUS | MAP_PRIVATE, VM_SHSTK);
+
+	if (addr >= TASK_SIZE_MAX) {
+		tsk->thread.cet.shstk_base = 0;
+		tsk->thread.cet.shstk_size = 0;
+		tsk->thread.cet.shstk_enabled = 0;
+		return -ENOMEM;
+	}
+
+	fpu__prepare_write(&tsk->thread.fpu);
+	state->user_ssp = (u64)(addr + size - sizeof(u64));
+	tsk->thread.cet.shstk_base = addr;
+	tsk->thread.cet.shstk_size = size;
+	return 0;
+}
+
 void cet_disable_shstk(void)
 {
 	u64 r;
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index a4deb79b1089..58b1c52b38b5 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -130,6 +130,7 @@ void exit_thread(struct task_struct *tsk)
 
 	free_vm86(t);
 
+	cet_disable_free_shstk(tsk);
 	fpu__drop(fpu);
 }
 
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index c51df5b4e116..5fa0d9ab18f1 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -421,6 +421,13 @@ int copy_thread_tls(unsigned long clone_flags, unsigned long sp,
 	if (sp)
 		childregs->sp = sp;
 
+	/* Allocate a new shadow stack for pthread */
+	if ((clone_flags & (CLONE_VFORK | CLONE_VM)) == CLONE_VM) {
+		err = cet_setup_thread_shstk(p);
+		if (err)
+			goto out;
+	}
+
 	err = -ENOMEM;
 	if (unlikely(test_tsk_thread_flag(me, TIF_IO_BITMAP))) {
 		p->thread.io_bitmap_ptr = kmemdup(me->thread.io_bitmap_ptr,
-- 
2.17.1

