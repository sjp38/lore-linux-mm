Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82AFAC433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43F97216F4
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:17:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="qWlkfAGQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43F97216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C819D6B0007; Wed, 14 Aug 2019 20:17:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C32776B0008; Wed, 14 Aug 2019 20:17:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B21306B000A; Wed, 14 Aug 2019 20:17:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0091.hostedemail.com [216.40.44.91])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5C46B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:17:05 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id ECC64180AD7C1
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:17:04 +0000 (UTC)
X-FDA: 75822747168.14.earth20_20abc39219f05
X-HE-Tag: earth20_20abc39219f05
X-Filterd-Recvd-Size: 4942
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:17:04 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id y1so346113plp.9
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:17:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=w7zQctoUbbEOIFpo2YzbJpxQDN+pRrmLCUjs8vOkAsU=;
        b=qWlkfAGQoM9lNg5jrzdKX18t6sNjHQqFETlJMuNiVjnHwXmE5ER8oeVFulSqZe/BKr
         Ug4sI09UOOdHmFC6ggpqPP4NbkA9a4ZNhhdG1ZrS4GRxM+pRbHOg1URC5o6zSbzLT+i/
         QqaGtFntkOZjlvxFjQCqy+LaWbR5iK9QzKa6k=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=w7zQctoUbbEOIFpo2YzbJpxQDN+pRrmLCUjs8vOkAsU=;
        b=KvhD8UB1YBuSrc3kufHhyhud/ucXw4HH365x1lUiGRvTsn/Z4nD8FLKW5hU54Q90Yu
         TKXY31P1nz+8L+TRgvoI7Dkx3/+wvs4hKkqTEJ7k+GL65Zj6gBWvJZcVVA5NUtaRa2fX
         wKQ5wYlhQrhnfHKSj1yZb1pXq/NsFX/IYDS8wJsDgqDWUm6OtbNjHsQSyMKc5wPKF2Bl
         7VR2jTi6bTwR+N+Oa6VZh9OddweVMX1+roDcOny4+Japc18teqfAiQi8AupphRWdDcHw
         nWPkoPT287r3Wcpj6wWfpY7sDCWfLJ4zrXKgXUmLUYce5LZgOJT+/tA2XZMWr1hHCjU+
         lE2A==
X-Gm-Message-State: APjAAAWK/wrOjlUdDzmxmjzL4ImxWWZjHL7YD6BYTOlx1Yyq9VR9tV7F
	QqcnElFNIvQ9KOS2crXxOKkQGA==
X-Google-Smtp-Source: APXvYqwToY126Akzgc+y0UF2qzlU3mi5AwpPlz/jjn3ocLwQBwldvb4KUXKXncmzJjVHauguV6Dj+A==
X-Received: by 2002:a17:902:b698:: with SMTP id c24mr1902458pls.28.1565828223382;
        Wed, 14 Aug 2019 17:17:03 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id z16sm835454pgi.8.2019.08.14.17.17.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Aug 2019 17:17:02 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	x86@kernel.org,
	aryabinin@virtuozzo.com,
	glider@google.com,
	luto@kernel.org,
	linux-kernel@vger.kernel.org,
	mark.rutland@arm.com,
	dvyukov@google.com
Cc: linuxppc-dev@lists.ozlabs.org,
	gor@linux.ibm.com,
	Daniel Axtens <dja@axtens.net>
Subject: [PATCH v4 2/3] fork: support VMAP_STACK with KASAN_VMALLOC
Date: Thu, 15 Aug 2019 10:16:35 +1000
Message-Id: <20190815001636.12235-3-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190815001636.12235-1-dja@axtens.net>
References: <20190815001636.12235-1-dja@axtens.net>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Supporting VMAP_STACK with KASAN_VMALLOC is straightforward:

 - clear the shadow region of vmapped stacks when swapping them in
 - tweak Kconfig to allow VMAP_STACK to be turned on with KASAN

Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Daniel Axtens <dja@axtens.net>
---
 arch/Kconfig  | 9 +++++----
 kernel/fork.c | 4 ++++
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index a7b57dd42c26..e791196005e1 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -825,16 +825,17 @@ config HAVE_ARCH_VMAP_STACK
 config VMAP_STACK
 	default y
 	bool "Use a virtually-mapped stack"
-	depends on HAVE_ARCH_VMAP_STACK && !KASAN
+	depends on HAVE_ARCH_VMAP_STACK
+	depends on !KASAN || KASAN_VMALLOC
 	---help---
 	  Enable this if you want the use virtually-mapped kernel stacks
 	  with guard pages.  This causes kernel stack overflows to be
 	  caught immediately rather than causing difficult-to-diagnose
 	  corruption.
=20
-	  This is presently incompatible with KASAN because KASAN expects
-	  the stack to map directly to the KASAN shadow map using a formula
-	  that is incorrect if the stack is in vmalloc space.
+	  To use this with KASAN, the architecture must support backing
+	  virtual mappings with real shadow memory, and KASAN_VMALLOC must
+	  be enabled.
=20
 config ARCH_OPTIONAL_KERNEL_RWX
 	def_bool n
diff --git a/kernel/fork.c b/kernel/fork.c
index d8ae0f1b4148..ce3150fe8ff2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -94,6 +94,7 @@
 #include <linux/livepatch.h>
 #include <linux/thread_info.h>
 #include <linux/stackleak.h>
+#include <linux/kasan.h>
=20
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -215,6 +216,9 @@ static unsigned long *alloc_thread_stack_node(struct =
task_struct *tsk, int node)
 		if (!s)
 			continue;
=20
+		/* Clear the KASAN shadow of the stack. */
+		kasan_unpoison_shadow(s->addr, THREAD_SIZE);
+
 		/* Clear stale pointers from reused stack. */
 		memset(s->addr, 0, THREAD_SIZE);
=20
--=20
2.20.1


