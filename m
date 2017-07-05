Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78B1B6B03D7
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:22:59 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g2so558625qta.14
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:22:59 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id j5si50036qkc.388.2017.07.05.14.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:22:58 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id 91so190548qkq.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:22:58 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 12/38] mm: ability to disable execute permission on a key at creation
Date: Wed,  5 Jul 2017 14:21:49 -0700
Message-Id: <1499289735-14220-13-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Currently sys_pkey_create() provides the ability to disable read
and write permission on the key, at  creation. powerpc  has  the
hardware support to disable execute on a pkey as well.This patch
enhances the interface to let disable execute  at  key  creation
time. x86 does  not  allow  this.  Hence the next patch will add
ability  in  x86  to  return  error  if  PKEY_DISABLE_EXECUTE is
specified.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 include/uapi/asm-generic/mman-common.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 8c27db0..bf4fa07 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -74,7 +74,9 @@
 
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
+#define PKEY_DISABLE_EXECUTE	0x4
 #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
-				 PKEY_DISABLE_WRITE)
+				 PKEY_DISABLE_WRITE  |\
+				 PKEY_DISABLE_EXECUTE)
 
 #endif /* __ASM_GENERIC_MMAN_COMMON_H */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
