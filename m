Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85353C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 14:55:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 472F022D6D
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 14:55:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="fYYdJo80"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 472F022D6D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDA826B000D; Tue,  3 Sep 2019 10:55:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D89CD6B000E; Tue,  3 Sep 2019 10:55:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA0276B0010; Tue,  3 Sep 2019 10:55:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7176B000D
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 10:55:58 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 4B42899BF
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:55:58 +0000 (UTC)
X-FDA: 75893909196.22.soda88_512f31d64f451
X-HE-Tag: soda88_512f31d64f451
X-Filterd-Recvd-Size: 4974
Received: from mail-pl1-f196.google.com (mail-pl1-f196.google.com [209.85.214.196])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:55:57 +0000 (UTC)
Received: by mail-pl1-f196.google.com with SMTP id b10so2924297plr.4
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 07:55:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ltnYvwXNt85pQWYuu3Woofu2pXYpHtCxsiErjju1VKA=;
        b=fYYdJo80f5W8wLCBsV9PXpH7FmOumHx81yzdzpAabJEIhstQ8OpGzWB9Tvl1BjtS9b
         sZ+W/qIQVUO23yK4AuvPlsv0K6/h4c4+PdEoaD/gP7ooZjMZbs0SkfJVPWfIixna5F7u
         9Dq9BLMKPic+DZfVetTR9ZdJrkIROlyat+W3E=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ltnYvwXNt85pQWYuu3Woofu2pXYpHtCxsiErjju1VKA=;
        b=CYYjL8QdzUn24NN/WkPbSzRqJP2cSWN0GlccKzqVNU42zxYiPqr1+MN6QzCR9sp85b
         aKYVe3Y+WlSWHM7URaE2TeYXgaM1Xy75u6oSPC9mU8d6KOp5wnU5UBHK6qfqW6oH9j63
         1/RjrjHoA06wkxHzrnNCPpUAwXx2iisVZ3Xln+N8HBajWitnRsncesrblcL2ZG69ID63
         8wbGqYM8mpvpEJx5ErgsvI03GcGqb2MUSE2GTRozsnwuza/oGarHa8IQO9vyaOUbpDGQ
         3Q60VZ05is1a7nojGLo23Df4CE5yVBLEv5l2WYtGxk6ePkVVe8h+DqPMSpV7hOd5Ktne
         TNTQ==
X-Gm-Message-State: APjAAAWWLrCvSnorSMyH2bcp1iMcaSXvIwrf1pElw1ZJ93v728Z/tTft
	pPcNPy5ATWwp80PGVxv3+PIa8Q==
X-Google-Smtp-Source: APXvYqwpR52IQD3jhAG2BrnEaKYsfUMiAuK8F0vrmrcIq0PHbZ3D4ZwgyS4ZycQr97O3MeYII234dA==
X-Received: by 2002:a17:902:720a:: with SMTP id ba10mr33715784plb.231.1567522557013;
        Tue, 03 Sep 2019 07:55:57 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id y8sm19975257pfe.146.2019.09.03.07.55.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 07:55:56 -0700 (PDT)
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
Subject: [PATCH v7 3/5] fork: support VMAP_STACK with KASAN_VMALLOC
Date: Wed,  4 Sep 2019 00:55:34 +1000
Message-Id: <20190903145536.3390-4-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190903145536.3390-1-dja@axtens.net>
References: <20190903145536.3390-1-dja@axtens.net>
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


