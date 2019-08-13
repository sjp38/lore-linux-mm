Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 255B7C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:02:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E62AA20842
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:02:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E62AA20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69BB26B0269; Tue, 13 Aug 2019 17:02:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 629C66B026A; Tue, 13 Aug 2019 17:02:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47D216B026B; Tue, 13 Aug 2019 17:02:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0200.hostedemail.com [216.40.44.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03EC26B0269
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:02:42 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9CDEB181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:02:42 +0000 (UTC)
X-FDA: 75818628564.17.stone39_1795217c61a57
X-HE-Tag: stone39_1795217c61a57
X-Filterd-Recvd-Size: 4902
Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:02:41 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 14:02:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="187901353"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by orsmga002.jf.intel.com with ESMTP; 13 Aug 2019 14:02:40 -0700
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
Subject: [PATCH v8 07/27] x86/cet/shstk: Add Kconfig option for user-mode shadow stack
Date: Tue, 13 Aug 2019 13:52:05 -0700
Message-Id: <20190813205225.12032-8-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190813205225.12032-1-yu-cheng.yu@intel.com>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce Kconfig option X86_INTEL_SHADOW_STACK_USER.

An application has shadow stack protection when all the following are
true:

  (1) The kernel has X86_INTEL_SHADOW_STACK_USER enabled,
  (2) The running processor supports the shadow stack,
  (3) The application is built with shadow stack enabled tools & libs
      and, and at runtime, all dependent shared libs can support
      shadow stack.

If this kernel config option is enabled, but (2) or (3) above is not
true, the application runs without the shadow stack protection.
Existing legacy applications will continue to work without the shadow
stack protection.

The user-mode shadow stack protection is only implemented for the
64-bit kernel.  Thirty-two bit applications are supported under the
compatibility mode.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/Kconfig  | 25 +++++++++++++++++++++++++
 arch/x86/Makefile |  7 +++++++
 2 files changed, 32 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 222855cc0158..eaf86ef13348 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1934,6 +1934,31 @@ config X86_INTEL_MEMORY_PROTECTION_KEYS
 
 	  If unsure, say y.
 
+config X86_INTEL_CET
+	def_bool n
+
+config ARCH_HAS_SHSTK
+	def_bool n
+
+config X86_INTEL_SHADOW_STACK_USER
+	prompt "Intel Shadow Stack for user-mode"
+	def_bool n
+	depends on CPU_SUP_INTEL && X86_64
+	select ARCH_USES_HIGH_VMA_FLAGS
+	select X86_INTEL_CET
+	select ARCH_HAS_SHSTK
+	---help---
+	  Shadow stack provides hardware protection against program stack
+	  corruption.  Only when all the following are true will an application
+	  have the shadow stack protection: the kernel supports it (i.e. this
+	  feature is enabled), the application is compiled and linked with
+	  shadow stack enabled, and the processor supports this feature.
+	  When the kernel has this configuration enabled, existing non shadow
+	  stack applications will continue to work, but without shadow stack
+	  protection.
+
+	  If unsure, say y.
+
 config EFI
 	bool "EFI runtime service support"
 	depends on ACPI
diff --git a/arch/x86/Makefile b/arch/x86/Makefile
index 56e748a7679f..0b2e9df48907 100644
--- a/arch/x86/Makefile
+++ b/arch/x86/Makefile
@@ -148,6 +148,13 @@ ifdef CONFIG_X86_X32
 endif
 export CONFIG_X86_X32_ABI
 
+# Check assembler shadow stack suppot
+ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+  ifeq ($(call as-instr, saveprevssp, y),)
+      $(error CONFIG_X86_INTEL_SHADOW_STACK_USER not supported by the assembler)
+  endif
+endif
+
 #
 # If the function graph tracer is used with mcount instead of fentry,
 # '-maccumulate-outgoing-args' is needed to prevent a GCC bug
-- 
2.17.1


