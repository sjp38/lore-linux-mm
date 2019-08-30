Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0903C3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 00:39:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77DE821670
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 00:39:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="qZFO1ufn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77DE821670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 306136B000E; Thu, 29 Aug 2019 20:39:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DCAF6B0010; Thu, 29 Aug 2019 20:39:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CBA16B0266; Thu, 29 Aug 2019 20:39:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0190.hostedemail.com [216.40.44.190])
	by kanga.kvack.org (Postfix) with ESMTP id F17736B000E
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 20:39:29 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A385D82437CF
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 00:39:29 +0000 (UTC)
X-FDA: 75877235658.14.class67_52d866233640a
X-HE-Tag: class67_52d866233640a
X-Filterd-Recvd-Size: 4974
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 00:39:29 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id 196so3310132pfz.8
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 17:39:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ltnYvwXNt85pQWYuu3Woofu2pXYpHtCxsiErjju1VKA=;
        b=qZFO1ufnQ4RzGLDmpNBBD8xLbLUSe/uPxIPwRgNb/8C1MeDgxj1IuxZwSgTtu/3mWo
         2plw5QzKfc1xhua3ICso6nWcau8unleFne2xH2R3zZpUctvuA8I7BebNJ6IqS45ly7u9
         r54BRf8K3pzPYXos1tiVjDS4eJ3Q9OdWwQfOg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ltnYvwXNt85pQWYuu3Woofu2pXYpHtCxsiErjju1VKA=;
        b=KNTi7w0sCbvPuQ0PflSjm6GfR5mrlFdkrUnZrgo/ZlvDalmV0HhE6IiBwXfUykQn2t
         cBm/PnvnMVAdx5EpbdSpciP7wpJphQ3bLvt8OwXSLv6UXoNCYhEQBQoRcQIqwDWyFiwm
         cz8Lf1OqKaRUVMezmuXak83l3Y+OspwV2Ej+3K/Nequxjj1TxEMR3qV6YbThn9zVFMJU
         K+bFmfUNnBxKPzoofh3//kmO3e5yZMz0DrzIcbztFH4sClqjWrwRo+6Cd6ip7rzkVjyY
         d6OL7UWqDfKmZcJYAve2ezBcQOflx7taCXSi9g3vkcBNamE/NL2Hrl/NDClv9FkwVL2d
         JCyw==
X-Gm-Message-State: APjAAAWzp+VhSrI9+cUFVOEQU28jyAsQ6nxCGfseX54r5d/4bwv4flk8
	wLuN1ErM4tvifEbP8x0xU4ft6Epyh9I=
X-Google-Smtp-Source: APXvYqyKlf0Curg+QgHFMU7CVSgRUolc+ixnBqYSqq7ea1tAptjrSjZsllz7aAJpXkkpH/hEA4izKA==
X-Received: by 2002:a65:48c3:: with SMTP id o3mr10685138pgs.372.1567125568304;
        Thu, 29 Aug 2019 17:39:28 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id i4sm2211696pfd.168.2019.08.29.17.39.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Aug 2019 17:39:27 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	x86@kernel.org,
	aryabinin@virtuozzo.com,
	glider@google.com,
	luto@kernel.org,
	linux-kernel@vger.kernel.org,
	mark.rutland@arm.com,
	dvyukov@google.com,
	christophe.leroy@c-s.fr
Cc: linuxppc-dev@lists.ozlabs.org,
	gor@linux.ibm.com,
	Daniel Axtens <dja@axtens.net>
Subject: [PATCH v5 3/5] fork: support VMAP_STACK with KASAN_VMALLOC
Date: Fri, 30 Aug 2019 10:38:19 +1000
Message-Id: <20190830003821.10737-4-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190830003821.10737-1-dja@axtens.net>
References: <20190830003821.10737-1-dja@axtens.net>
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
index 6728c5fa057e..e15f1486682a 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -843,16 +843,17 @@ config HAVE_ARCH_VMAP_STACK
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
index f601168f6b21..52279fd5e72d 100644
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
@@ -229,6 +230,9 @@ static unsigned long *alloc_thread_stack_node(struct =
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


