Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6C27C3A5A7
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 11:21:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABAE321882
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 11:21:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="KJvuFZFe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABAE321882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 608006B0008; Mon,  2 Sep 2019 07:21:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B82E6B000A; Mon,  2 Sep 2019 07:21:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 459026B000C; Mon,  2 Sep 2019 07:21:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0196.hostedemail.com [216.40.44.196])
	by kanga.kvack.org (Postfix) with ESMTP id 229426B0008
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:21:58 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C5C87181AC9B6
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 11:21:57 +0000 (UTC)
X-FDA: 75889741074.30.song19_2e2ebce700325
X-HE-Tag: song19_2e2ebce700325
X-Filterd-Recvd-Size: 4975
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 11:21:57 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id h195so2308028pfe.5
        for <linux-mm@kvack.org>; Mon, 02 Sep 2019 04:21:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ltnYvwXNt85pQWYuu3Woofu2pXYpHtCxsiErjju1VKA=;
        b=KJvuFZFemq48CN49xAn0XMdT8Gd11s5/DG4skkXmljGh5sxOZA2vVU9YWSmBRnhQIL
         48lYVWauWM0mr3YZTZn7rzAK+6pv0ObxoAdYqOFfQjraVxpFE6Lg8loxKfokY2h64G7w
         8oCm1ItfZaVPvwLy8QfT9xV0gUudXmGUSN31o=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ltnYvwXNt85pQWYuu3Woofu2pXYpHtCxsiErjju1VKA=;
        b=quy9zcV0aBGhLdNhQxvl5+N21eu6WqXBeJGUuQcWXTWfzWwi4ABLka8Kj8RxUoMMYn
         ey037f0rVgFOS7OndNQPSEnVptz4QSB9b1sUkIgNebF+mlnxqcOPf/LvYVRPhMidgxP1
         TLZYtN3lDUiaS9SFxPWVwKFQA0F0mLh2gMTpFt0NU+EeQ3psMBY2eTHaHk4iMwvaSwqa
         tyOzJnYSj18dOofGYXj/6/dUXJhFXZTCSi4aMAvdg53Phr5FOzi2ANDGYFZNitj0SNWj
         ju56yFeedAnGsyy4p585ZvBykQHCDakvFCvJ7MW0RwfX6wQDlN1kjhkI6sxjUTt4trS9
         1qRA==
X-Gm-Message-State: APjAAAVJDkMyaDO+s8l8hfhPJQou9p1KNRNmNQvQ27Pb6MwDoS7NnVWB
	pBlbZ6kREIL4rEmf1KF9FUBp6g==
X-Google-Smtp-Source: APXvYqzbeVQOO1H7u1MKLY3LMRh/FsOUkMLI8e9zPqbWR51nVUSncMQqE+hLYnWR4pTrqKchpQ9r7w==
X-Received: by 2002:a17:90a:30e8:: with SMTP id h95mr7353865pjb.44.1567423316484;
        Mon, 02 Sep 2019 04:21:56 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id k5sm21422793pfg.167.2019.09.02.04.21.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Sep 2019 04:21:55 -0700 (PDT)
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
Subject: [PATCH v6 3/5] fork: support VMAP_STACK with KASAN_VMALLOC
Date: Mon,  2 Sep 2019 21:20:26 +1000
Message-Id: <20190902112028.23773-4-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190902112028.23773-1-dja@axtens.net>
References: <20190902112028.23773-1-dja@axtens.net>
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


