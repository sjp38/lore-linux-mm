Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id EAE636B0672
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:59:35 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id i128so40167505qkc.11
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:59:35 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id k3si12087870qta.212.2017.07.15.20.59.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:59:35 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id q66so17064481qki.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:59:35 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 38/62] powerpc: implementation for arch_pkeys_enabled()
Date: Sat, 15 Jul 2017 20:56:40 -0700
Message-Id: <1500177424-13695-39-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

arch_pkeys_enabled() returns true if the cpu
supports protection key, and the kernel has it
enabled.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/pkeys.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 7a9aade..ea43cb2 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -201,6 +201,11 @@ static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 	return __arch_set_user_pkey_access(tsk, pkey, init_val);
 }
 
+static inline bool arch_pkeys_enabled(void)
+{
+	return pkey_inited;
+}
+
 static inline void pkey_mm_init(struct mm_struct *mm)
 {
 	if (!pkey_inited)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
