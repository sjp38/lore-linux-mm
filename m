Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 46CBE6B02A4
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 11:22:09 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id l7-v6so6526794plg.6
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 08:22:09 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a28-v6si14382557pfc.106.2018.10.11.08.22.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 08:22:08 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v5 10/11] x86/vsyscall/64: Add ENDBR64 to vsyscall entry points
Date: Thu, 11 Oct 2018 08:16:53 -0700
Message-Id: <20181011151654.27221-11-yu-cheng.yu@intel.com>
In-Reply-To: <20181011151654.27221-1-yu-cheng.yu@intel.com>
References: <20181011151654.27221-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

From: "H.J. Lu" <hjl.tools@gmail.com>

Add ENDBR64 to vsyscall entry points.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
---
 arch/x86/entry/vsyscall/vsyscall_emu_64.S | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/x86/entry/vsyscall/vsyscall_emu_64.S b/arch/x86/entry/vsyscall/vsyscall_emu_64.S
index c9596a9af159..08554445bef1 100644
--- a/arch/x86/entry/vsyscall/vsyscall_emu_64.S
+++ b/arch/x86/entry/vsyscall/vsyscall_emu_64.S
@@ -18,16 +18,25 @@ __PAGE_ALIGNED_DATA
 	.type __vsyscall_page, @object
 __vsyscall_page:
 
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+	endbr64
+#endif
 	mov $__NR_gettimeofday, %rax
 	syscall
 	ret
 
 	.balign 1024, 0xcc
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+	endbr64
+#endif
 	mov $__NR_time, %rax
 	syscall
 	ret
 
 	.balign 1024, 0xcc
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+	endbr64
+#endif
 	mov $__NR_getcpu, %rax
 	syscall
 	ret
-- 
2.17.1
