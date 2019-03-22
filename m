Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB8E7C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 14:00:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E279218A5
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 14:00:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="TVD3t75R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E279218A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CE136B0003; Fri, 22 Mar 2019 10:00:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37CDC6B0006; Fri, 22 Mar 2019 10:00:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 246346B0007; Fri, 22 Mar 2019 10:00:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id C86E16B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:00:08 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id y7so1077420wrq.4
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 07:00:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:from:subject:to:cc
         :date;
        bh=l///YPAie6uypUB1yNuBRWNf9RJugCs+/QmoUcS6Zx0=;
        b=JCwIQ5RQuKDYFNLpx7A2jCijJGDuv3TDXvu3ImHUGAdpKmrTSPEltGjrtMK8U2cCwD
         5IHHWNCXhy5MVvaHLcgrD2r5CIDT9Xruy9UFBNwGENJ+X1L6eL7SM5GswPUzcrJpm4mc
         mM4Dml/kG1HS78pvSeK2KJHo36CQ2V5ne9wwYKqOl+opLCAQgdTQZcGHW/VDcpM9gAaD
         hABdi9c38edEw3x4Os0BUdDbpgv2c2Cf8k0WEcriMP9M4au2xQ2ptqmEd+fWcxZ762/M
         LuCzBwAgltclVy5iVahYMrrMp5sPfNN6aHFgLam+yKQA7VK6gjtFyxmcNZ3HymEHXp3p
         GPFg==
X-Gm-Message-State: APjAAAV1xuRuWa5Z5ge34mrKkM9EEwSvpxwLfDfPbUMRf8G/MVwvgA/6
	/3JPIiWLBwOzWsxYy7S5Jg9caI2giMLgdt3PYMkSMcFbESZU8JXmkdM8h1h8P2MzhUOU2PhwjLH
	1NvMn5QxKHgjXPXvAE+M5yS1C8gPWKhBXGZk3OPx16bKf/8I2koLyccgIbnEeZFFnMg==
X-Received: by 2002:adf:f786:: with SMTP id q6mr6308810wrp.125.1553263208274;
        Fri, 22 Mar 2019 07:00:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcorzaC7CLysNts21JYUTvVLvheqVrDZR0wQ2XTxwvW1XHb+0ePXL9FK78CKrDIPjqa8Ex
X-Received: by 2002:adf:f786:: with SMTP id q6mr6308733wrp.125.1553263207208;
        Fri, 22 Mar 2019 07:00:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553263207; cv=none;
        d=google.com; s=arc-20160816;
        b=gtq4dcDilguCYG1cCe5zczXgQsazM5plmMzLsVUx4GN2Px2296Nj/ESISPa2EVwT5Y
         Nwal81cCIwdsNs7O8xKK7rWwKaV6CqWGh4wsg+t9uKDzcKR20QTSUTHA+6k3/ok71WGb
         e1o/gbbc2mD7ufmQ3CPl5nOvo1VVNFse4mgJnUD+z3RWj1PQIk9XJBrmywbi0FstR4t+
         GnO/H4G7fVXfLKfdZHKNwyKYcot1ge4iaxUeDrC4D0StDFC+JcBnHgB/bIJVzNyrYtjf
         sm6mlm6xvnC+HEXKWEuUZ3wk2CPo6XuRlHU2EeKvvs39MUUIyOb+eAqC8TaOfbZK5a3g
         rwuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:message-id:dkim-signature;
        bh=l///YPAie6uypUB1yNuBRWNf9RJugCs+/QmoUcS6Zx0=;
        b=RoKH79G/bPMAPW22z3Cw+nipmwa98sTpmqCw1EifxXkkgNko9IqCN1yK9yQ5yE5Od/
         rbdKK4jRM8rdDowzqQ/v26SOl3Ajap3554KrzW6eT/SichkdgIyPRUyPbBHOuh2zR+sm
         4y96UKjqFPXzcKQdg8JvtVlpJLMJkBoHg6rEkPDgIMZeCJPOkKQQiKvY6jjPeQEIm36V
         GRhgE3pVuSlmvau4+rW+EWJrk8DI4DDSQX4q0/DLJ+LZMe0bQres0KJaRxr/M5hXR+aZ
         V7eHaFxWIXjz1YkbS04KhsjcAX9Fz65KSF7zmSp9TGYYXmy3WbEfX2qWfDbEnosYyMLt
         i8QA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=TVD3t75R;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id s23si5362590wmc.62.2019.03.22.07.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 07:00:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=TVD3t75R;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44QlfD5myfz9tydW;
	Fri, 22 Mar 2019 15:00:04 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=TVD3t75R; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id xPLK5FWV0xo7; Fri, 22 Mar 2019 15:00:04 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44QlfD4bHHz9tydV;
	Fri, 22 Mar 2019 15:00:04 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1553263204; bh=l///YPAie6uypUB1yNuBRWNf9RJugCs+/QmoUcS6Zx0=;
	h=From:Subject:To:Cc:Date:From;
	b=TVD3t75RzjncfGO+RukbpauQg6uI80vUDWLYyiU0cmGK2tADoEKMnA9EDqo4mH7SC
	 xEU6OVubJ5ndZubeSwVVggp5Y2lHFaYTtoKgyA1BwNTPPi1ru6okwUD3vrIJJ4of9n
	 NfTVntuDHQPZS/lEcJGozAj7O42qvByZ7/R2CgKI=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 0F0388BB1B;
	Fri, 22 Mar 2019 15:00:06 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 4Uyy-m5EOo7f; Fri, 22 Mar 2019 15:00:05 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id D1A368B848;
	Fri, 22 Mar 2019 15:00:05 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id ACA3C6CE54; Fri, 22 Mar 2019 14:00:05 +0000 (UTC)
Message-Id: <45a5e13683694fc8d4574b52c4851ffb7f5e5fbd.1553263058.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [RFC PATCH v1 1/3] kasan: move memset/memmove/memcpy interceptors in
 a dedicated file
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 22 Mar 2019 14:00:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation of the addition of interceptors for other string functions,
this patch moves memset/memmove/memcpy interceptions in string.c

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 mm/kasan/Makefile |  5 ++++-
 mm/kasan/common.c | 26 --------------------------
 mm/kasan/string.c | 35 +++++++++++++++++++++++++++++++++++
 3 files changed, 39 insertions(+), 27 deletions(-)
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
index 000000000000..f23a740ff985
--- /dev/null
+++ b/mm/kasan/string.c
@@ -0,0 +1,35 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * This file contains strings functions for KASAN
+ *
+ */
+
+#include <linux/string.h>
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

