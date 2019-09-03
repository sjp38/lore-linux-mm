Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 675B6C3A5A9
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 14:55:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C9CA23717
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 14:55:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="FR2A8WMD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C9CA23717
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3D106B000A; Tue,  3 Sep 2019 10:55:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF1106B000C; Tue,  3 Sep 2019 10:55:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDE426B000D; Tue,  3 Sep 2019 10:55:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0090.hostedemail.com [216.40.44.90])
	by kanga.kvack.org (Postfix) with ESMTP id 955486B000A
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 10:55:53 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 3B53F181AC9BA
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:55:53 +0000 (UTC)
X-FDA: 75893908986.18.cup05_506ea2de9e962
X-HE-Tag: cup05_506ea2de9e962
X-Filterd-Recvd-Size: 4268
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:55:52 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id u72so5100563pgb.10
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 07:55:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=HNDV9DT7O32N2h9l7CrACdWJSzNVfR3Dv9pnUT55kOg=;
        b=FR2A8WMD+DnhNMxW/AdS1tEdkZRXiPpMUgFAehGpzfwPiADje+HGwN/tXiTSg49kjs
         8axf1yK6lckfmwIzBX6evzvsGC+UBpSQ5lgI/sc1uFwoQLHw2slgHM1nEaZg/UP3PXxr
         2SPS4jhPXzi9sV3nsNx99PY1dXpjYVpzCMVE4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=HNDV9DT7O32N2h9l7CrACdWJSzNVfR3Dv9pnUT55kOg=;
        b=DiZC276LXwQFFDljnFMV6zijky4vDxe4EwHWc+Ugn1ENgOkAC8AbI7uHyl5bL9F7pj
         Yev7Xj1hKKa/DprwKo4ZCnp9V10CR4B61F9VNWdoLS8xAhxRe84mSeAYqhgsjSDhPJkX
         A6ZL3iZa4WK1ch+83xHNMTTeHy0lPXECultfOXkpUSoaWkARcjoAhQMvVpJvfiOnVCyj
         8cip0m9EU4n7cEr8FjnV653halxawHzjIE0SITjHZ4kL/b9uTqvOIbKmJYdh/VSTKQpu
         fSN+Ho8a1qo3uc4tA1XXIn9gYuWVwlUAfVBd7QW3ycer2F0cVoOS5NLvOgVebURmt+io
         sx8g==
X-Gm-Message-State: APjAAAV2T4Y7zwQd4BVISnWZUg6F1TcAXXsInzbmzWCxCHmGNGDTBRSG
	OKjLEfgir6evaK/6vD0UmJfgKw==
X-Google-Smtp-Source: APXvYqyssI9EpWOcemmTKjSWeJkp8pesyl80zlv7UbppPhIyxvFpoEZSj4nDikJ0w4fVrnzAh6rdPw==
X-Received: by 2002:a17:90a:fe0e:: with SMTP id ck14mr466805pjb.78.1567522551845;
        Tue, 03 Sep 2019 07:55:51 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id b19sm16216868pgs.10.2019.09.03.07.55.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 07:55:51 -0700 (PDT)
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
Subject: [PATCH v7 2/5] kasan: add test for vmalloc
Date: Wed,  4 Sep 2019 00:55:33 +1000
Message-Id: <20190903145536.3390-3-dja@axtens.net>
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

Test kasan vmalloc support by adding a new test to the module.

Signed-off-by: Daniel Axtens <dja@axtens.net>

--

v5: split out per Christophe Leroy
---
 lib/test_kasan.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 49cc4d570a40..328d33beae36 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -19,6 +19,7 @@
 #include <linux/string.h>
 #include <linux/uaccess.h>
 #include <linux/io.h>
+#include <linux/vmalloc.h>
=20
 #include <asm/page.h>
=20
@@ -748,6 +749,30 @@ static noinline void __init kmalloc_double_kzfree(vo=
id)
 	kzfree(ptr);
 }
=20
+#ifdef CONFIG_KASAN_VMALLOC
+static noinline void __init vmalloc_oob(void)
+{
+	void *area;
+
+	pr_info("vmalloc out-of-bounds\n");
+
+	/*
+	 * We have to be careful not to hit the guard page.
+	 * The MMU will catch that and crash us.
+	 */
+	area =3D vmalloc(3000);
+	if (!area) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	((volatile char *)area)[3100];
+	vfree(area);
+}
+#else
+static void __init vmalloc_oob(void) {}
+#endif
+
 static int __init kmalloc_tests_init(void)
 {
 	/*
@@ -793,6 +818,7 @@ static int __init kmalloc_tests_init(void)
 	kasan_strings();
 	kasan_bitops();
 	kmalloc_double_kzfree();
+	vmalloc_oob();
=20
 	kasan_restore_multi_shot(multishot);
=20
--=20
2.20.1


