Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2CE9C3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 00:39:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A33112189D
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 00:39:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="rC80CM3v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A33112189D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 500696B000D; Thu, 29 Aug 2019 20:39:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B2166B000E; Thu, 29 Aug 2019 20:39:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A0E86B0010; Thu, 29 Aug 2019 20:39:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0164.hostedemail.com [216.40.44.164])
	by kanga.kvack.org (Postfix) with ESMTP id 160BA6B000D
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 20:39:12 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 9A9DF82437CF
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 00:39:11 +0000 (UTC)
X-FDA: 75877234902.15.smash06_50365e63ea219
X-HE-Tag: smash06_50365e63ea219
X-Filterd-Recvd-Size: 4267
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 00:39:11 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id c81so3299674pfc.11
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 17:39:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=HNDV9DT7O32N2h9l7CrACdWJSzNVfR3Dv9pnUT55kOg=;
        b=rC80CM3vg5AM+oCtr2yGiOMkyFX3PwyWe/XtNpAWG+HqpbnDeR7304D9UdEPGcbG1z
         p5Wwn/tzrFn8wuMCtE+W9itdoK1VA57nvODNtfU9ort+tqudg9czalidTRlConko7Q9N
         ZCj2Wv+K+wlO0ZT2El8qdKr16hfYxsr077kTU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=HNDV9DT7O32N2h9l7CrACdWJSzNVfR3Dv9pnUT55kOg=;
        b=BWFy84YR2KyOkDq+RzIMP7r7hE/kS6z9Z6qDrueaihRDlKMy7hk+D5D9+AUMnjFOx7
         CGXp5fhXGlBu9UHCQu/ng+DZoo5S0vL0Q8BDC/dvFQuyc9Dh0+bvkyTq0Sa2ZeEgxfK6
         FRQ8J3WdSyopaC5rN7OYEMtVrCbEpe0+VPoRPL/tHMmMc2+10AlZbfLPM1/JqeaQ6RyU
         PzgZs2uxUXsK0iBHM1i76/VUA1MFeOH7rXT3y1RKy4jhXNv/EzqVyy+155rTnDoVbfHC
         EINPnY6pCWOyL9TZhd99NybulH2xAmsJMoXjyiWbiPUQGUMjj4IoaQ6QWQVRr9JC2Koj
         0y6w==
X-Gm-Message-State: APjAAAW4GVUtb4dUpiJ5+bdSl0mKe5u/12hx2bsVVC3+XITzP3niJEQT
	Ea27uB0uvv4v7cHQctPNgLYEZQ==
X-Google-Smtp-Source: APXvYqxf40ssvyv4OlvQVqWJJ70xy4S4K17zZEo3u0JMMATs1HkRt9dCDVYyGh/84sHT3v5sSG1DHw==
X-Received: by 2002:a63:a66:: with SMTP id z38mr11066655pgk.247.1567125550257;
        Thu, 29 Aug 2019 17:39:10 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id i4sm2211255pfd.168.2019.08.29.17.39.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Aug 2019 17:39:09 -0700 (PDT)
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
Subject: [PATCH v5 2/5] kasan: add test for vmalloc
Date: Fri, 30 Aug 2019 10:38:18 +1000
Message-Id: <20190830003821.10737-3-dja@axtens.net>
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


