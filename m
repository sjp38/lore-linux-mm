Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A98D36B0296
	for <linux-mm@kvack.org>; Tue,  8 May 2018 11:00:04 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id w9-v6so7952984pgq.21
        for <linux-mm@kvack.org>; Tue, 08 May 2018 08:00:04 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id n4si23955277pfa.66.2018.05.08.08.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 08:00:03 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 7/8] mm/pkeys: Add an empty arch_pkeys_enabled()
Date: Wed,  9 May 2018 00:59:47 +1000
Message-Id: <20180508145948.9492-8-mpe@ellerman.id.au>
In-Reply-To: <20180508145948.9492-1-mpe@ellerman.id.au>
References: <20180508145948.9492-1-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com

Add an empty arch_pkeys_enabled() in linux/pkeys.h for the
CONFIG_ARCH_HAS_PKEYS=n case.

Split out of a patch by Ram Pai <linuxram@us.ibm.com>.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 include/linux/pkeys.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
index 946cb773b79f..2955ba976048 100644
--- a/include/linux/pkeys.h
+++ b/include/linux/pkeys.h
@@ -39,6 +39,11 @@ static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 	return 0;
 }
 
+static inline bool arch_pkeys_enabled(void)
+{
+	return false;
+}
+
 static inline void copy_init_pkru_to_fpregs(void)
 {
 }
-- 
2.14.1
