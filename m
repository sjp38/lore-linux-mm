Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C5ACC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:00:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CE0E20811
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:00:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="FriXieDa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CE0E20811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA8E66B0006; Thu, 28 Mar 2019 11:00:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C57416B0007; Thu, 28 Mar 2019 11:00:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B46E06B0008; Thu, 28 Mar 2019 11:00:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 662D56B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:00:20 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id 187so3931912wmc.1
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:00:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:from:subject:to:cc
         :date;
        bh=T+J229KlSwmDE+sECLswESBH4a6GRbtFc9G5p7ym4qU=;
        b=pneael/4mA1Z6yoHm3Ab3WeAq5VvEwsCB5eSkXQ3zP+0lhxGUcUeroqG/pDv+5dJKo
         HKWkZfTLjCEIL8fWqhxsE+eCLTHPP/5JwadMFWKDjgK45s49T9gXRLc91KqcKx9S5tOB
         d68sLRGG2h1r85tuDis4g1ZNGT0mRu88RfdjfTBcd/Lpb+ZhExa/cW/5sQfpk0Wkj924
         q3dJNjUfI+HdEseSrnlAL5IXxDq3Jc4jwVnPYO3Z63TKvnf4mDXMxQ+dzi+3qptyrQ3c
         50s+nHR95UWGbVhy2oY0133fn09xPPuUi8sNepsP6nu/yLaVxQRTdbASLjbdOyvSc4ac
         pT2A==
X-Gm-Message-State: APjAAAXMrrlMymcp6OmcL4Ophvh+8y+RQdQ23q5bSZEOjUOJd2YT1Fi4
	TXPnchxcBvVDTiWKeTSBUYAKeS0Sc8R0CbTd1IiMgWL5bGZuEsRHZfsn1rlSMHaXPGj0x+Xf7bq
	rpvbR70rMWuSxqddiLSWKypNiLeVX9fCU2iCBxXbu/mjuPxp92j8X5ZqInKm7m9XEkg==
X-Received: by 2002:a7b:c309:: with SMTP id k9mr271320wmj.139.1553785219923;
        Thu, 28 Mar 2019 08:00:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyybg3QkH1MjU3eN6Xaz6FJPRlYJIB5iZq+IYmWuC2iy5MGNQkmJmTUN+oFI1nj0nC8Anu
X-Received: by 2002:a7b:c309:: with SMTP id k9mr271230wmj.139.1553785218496;
        Thu, 28 Mar 2019 08:00:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553785218; cv=none;
        d=google.com; s=arc-20160816;
        b=k3nxoIQWdkcx2Td0xMPGbsjjwcOlo+ZYHQYndKbXIT4aDISNcHOaWf3/FCOohIKu9X
         XgsqEMi1nnyPCcl1XzupJl1eLQQHwvMkgKeK1XR95mTVRz7DFNsSao/BbJ3HTQHX2/L+
         AmAS63Ij8qbF6uQBeRipK0sbmVJ6qQh0cqb91c4IeRiXI2mdynCSB6Xz5nHTftViByAk
         2gFfNRZodGANU491UOGJdx0MFE7t0M870s77K+zZ6bDrjQcJ0Qv17qvpEXqatkjIG6xm
         lXKqykxDdSVsuv5Xrcu7N7V/MZnrTEDpMYPRlK4SzwvnJHsTW9H1QFeyjZOn4ImBwuMC
         QOvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:message-id:dkim-signature;
        bh=T+J229KlSwmDE+sECLswESBH4a6GRbtFc9G5p7ym4qU=;
        b=G+rkSXo4D2zs+8zo7rvXFsWQT1fCADBuZxHdm65x5maDXj928Uluo5fHVOCUPAH28O
         +BFfK8rfcerv6MAh1UmRQAI5pJj8VEdjms0+InuRpf6eSBrJIDi9vKeYB1GPxWdi0VBK
         odtNf/UCZVncAQsFsn3dsBe/QDkh9Pwj0ZcI8bK2yWn8kcpy05Dku+zYNOvhtZQAR8qX
         j8QB28ryBMWI17iI4tOUqU6rrmcvEMOejh1a/ipg/5fxhh2algiZ0jKEJQ0KEPJ5NUnj
         /l/4deR6gntagtX01sWy2swC+2EFMaj9bb4LqdHMv5X+rUPpdEt7aVWUd0IZ2EYVJArT
         UmvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=FriXieDa;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id s133si1977890wme.164.2019.03.28.08.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 08:00:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=FriXieDa;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44VShw3Sq9z9v2Hd;
	Thu, 28 Mar 2019 16:00:16 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=FriXieDa; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id ZDF9MEr-EH3G; Thu, 28 Mar 2019 16:00:16 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44VShw2C2Bz9v2HP;
	Thu, 28 Mar 2019 16:00:16 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1553785216; bh=T+J229KlSwmDE+sECLswESBH4a6GRbtFc9G5p7ym4qU=;
	h=From:Subject:To:Cc:Date:From;
	b=FriXieDaYZYFCgEwwz6EiADVaeeRtqV6w8F7LRDUsr0QB/roc/vF55BaP6X/vwVRE
	 CRRNP0EARS2ndxDIxNXsu5DTu1jJPkxeNYCFJhyR2JlO5gUwZ4XzRSY0dgqV6u/CAJ
	 NVeqw9du4IMVXMpsmflMfg+VWdLL3CyeaZiXoSk0=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 969DC8B924;
	Thu, 28 Mar 2019 16:00:17 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id FZGcjbU8hIEW; Thu, 28 Mar 2019 16:00:17 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 486128B923;
	Thu, 28 Mar 2019 16:00:17 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 0DD3E6FC84; Thu, 28 Mar 2019 15:00:16 +0000 (UTC)
Message-Id: <f13944c4e99ec2cef6d93d762e6b526e0335877f.1553785019.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [RFC PATCH v2 1/3] kasan: move memset/memmove/memcpy interceptors in
 a dedicated file
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Thu, 28 Mar 2019 15:00:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation of the addition of interceptors for other string functions,
this patch moves memset/memmove/memcpy interceptions in string.c

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 v2: added missing includes

 mm/kasan/Makefile |  5 ++++-
 mm/kasan/common.c | 26 --------------------------
 mm/kasan/string.c | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 58 insertions(+), 27 deletions(-)
 create mode 100644 mm/kasan/string.c

diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index 5d1065efbd47..85e91e301404 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -1,11 +1,13 @@
 # SPDX-License-Identifier: GPL-2.0
 KASAN_SANITIZE := n
 UBSAN_SANITIZE_common.o := n
+UBSAN_SANITIZE_string.o := n
 UBSAN_SANITIZE_generic.o := n
 UBSAN_SANITIZE_tags.o := n
 KCOV_INSTRUMENT := n
 
 CFLAGS_REMOVE_common.o = -pg
+CFLAGS_REMOVE_string.o = -pg
 CFLAGS_REMOVE_generic.o = -pg
 CFLAGS_REMOVE_tags.o = -pg
 
@@ -13,9 +15,10 @@ CFLAGS_REMOVE_tags.o = -pg
 # see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63533
 
 CFLAGS_common.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
+CFLAGS_string.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 CFLAGS_generic.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 CFLAGS_tags.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
-obj-$(CONFIG_KASAN) := common.o init.o report.o
+obj-$(CONFIG_KASAN) := common.o init.o report.o string.o
 obj-$(CONFIG_KASAN_GENERIC) += generic.o generic_report.o quarantine.o
 obj-$(CONFIG_KASAN_SW_TAGS) += tags.o tags_report.o
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 80bbe62b16cd..3b94f484bf78 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -109,32 +109,6 @@ void kasan_check_write(const volatile void *p, unsigned int size)
 }
 EXPORT_SYMBOL(kasan_check_write);
 
-#undef memset
-void *memset(void *addr, int c, size_t len)
-{
-	check_memory_region((unsigned long)addr, len, true, _RET_IP_);
-
-	return __memset(addr, c, len);
-}
-
-#undef memmove
-void *memmove(void *dest, const void *src, size_t len)
-{
-	check_memory_region((unsigned long)src, len, false, _RET_IP_);
-	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
-
-	return __memmove(dest, src, len);
-}
-
-#undef memcpy
-void *memcpy(void *dest, const void *src, size_t len)
-{
-	check_memory_region((unsigned long)src, len, false, _RET_IP_);
-	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
-
-	return __memcpy(dest, src, len);
-}
-
 /*
  * Poisons the shadow memory for 'size' bytes starting from 'addr'.
  * Memory addresses should be aligned to KASAN_SHADOW_SCALE_SIZE.
diff --git a/mm/kasan/string.c b/mm/kasan/string.c
new file mode 100644
index 000000000000..083b967255a2
--- /dev/null
+++ b/mm/kasan/string.c
@@ -0,0 +1,54 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * This file contains strings functions for KASAN
+ *
+ */
+
+#include <linux/export.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/kasan.h>
+#include <linux/kernel.h>
+#include <linux/kmemleak.h>
+#include <linux/linkage.h>
+#include <linux/memblock.h>
+#include <linux/memory.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/printk.h>
+#include <linux/sched.h>
+#include <linux/sched/task_stack.h>
+#include <linux/slab.h>
+#include <linux/stacktrace.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/vmalloc.h>
+#include <linux/bug.h>
+
+#include "kasan.h"
+
+#undef memset
+void *memset(void *addr, int c, size_t len)
+{
+	check_memory_region((unsigned long)addr, len, true, _RET_IP_);
+
+	return __memset(addr, c, len);
+}
+
+#undef memmove
+void *memmove(void *dest, const void *src, size_t len)
+{
+	check_memory_region((unsigned long)src, len, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
+
+	return __memmove(dest, src, len);
+}
+
+#undef memcpy
+void *memcpy(void *dest, const void *src, size_t len)
+{
+	check_memory_region((unsigned long)src, len, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
+
+	return __memcpy(dest, src, len);
+}
-- 
2.13.3

