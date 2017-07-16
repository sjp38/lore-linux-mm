Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 11B026B066E
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:59:31 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id z22so59011366qka.4
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:59:31 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id h63si11932170qkd.279.2017.07.15.20.59.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:59:30 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id q66so17064383qki.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:59:30 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 36/62] mm: introduce arch_pkeys_enabled()
Date: Sat, 15 Jul 2017 20:56:38 -0700
Message-Id: <1500177424-13695-37-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Only the architecture knows if it supports protection keys.
Hence introducing arch_pkeys_enabled().

This function is needed by arch neutral code.

One use case is -- to determine if the
	protection key needs to be displayed in smaps.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 include/linux/pkeys.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
index a1bacf1..d120810 100644
--- a/include/linux/pkeys.h
+++ b/include/linux/pkeys.h
@@ -34,6 +34,11 @@ static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
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
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
