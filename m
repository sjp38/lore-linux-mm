Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D12D6B000D
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 09:50:14 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u68-v6so844156qku.5
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 06:50:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z11-v6sor500707qti.109.2018.07.17.06.50.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 06:50:13 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v14 05/22] selftests/vm: Make gcc check arguments of sigsafe_printf()
Date: Tue, 17 Jul 2018 06:49:08 -0700
Message-Id: <1531835365-32387-6-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, dave.hansen@intel.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, linuxram@us.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

From: Thiago Jung Bauermann <bauerman@linux.ibm.com>

This will help us ensure we print pkey_reg_t values correctly in different
architectures.

Signed-off-by: Thiago Jung Bauermann <bauerman@linux.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index 3ed2f02..7f18a82 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -27,6 +27,10 @@
 #define DPRINT_IN_SIGNAL_BUF_SIZE 4096
 extern int dprint_in_signal;
 extern char dprint_in_signal_buffer[DPRINT_IN_SIGNAL_BUF_SIZE];
+
+#ifdef __GNUC__
+__attribute__((format(printf, 1, 2)))
+#endif
 static inline void sigsafe_printf(const char *format, ...)
 {
 	va_list ap;
-- 
1.7.1
