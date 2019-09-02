Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74180C3A5A7
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 11:21:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 395FA21882
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 11:21:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="GKuCbVx1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 395FA21882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C493B6B0007; Mon,  2 Sep 2019 07:21:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD3066B0008; Mon,  2 Sep 2019 07:21:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A73636B000A; Mon,  2 Sep 2019 07:21:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id 84CDE6B0007
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:21:52 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 27D8140C0
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 11:21:52 +0000 (UTC)
X-FDA: 75889740864.15.print21_2d5f11f01ec2f
X-HE-Tag: print21_2d5f11f01ec2f
X-Filterd-Recvd-Size: 4266
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 11:21:51 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id w16so8857373pfn.7
        for <linux-mm@kvack.org>; Mon, 02 Sep 2019 04:21:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=HNDV9DT7O32N2h9l7CrACdWJSzNVfR3Dv9pnUT55kOg=;
        b=GKuCbVx1t+eL5NuSXYg24Zb8O/7qTbI6sdxmgVMesG2eQh9g+M4P/EvE8/9CODfonb
         HkkHFG8Jfj0z4u6Wejfvymvg0FJ/jFlvzomETWUK76xRmoT4O1vaYZFlHdPyE8vpCFrZ
         3vAjdReE6wxH63jd/H9o8cAAEV+he33Jb66Vs=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=HNDV9DT7O32N2h9l7CrACdWJSzNVfR3Dv9pnUT55kOg=;
        b=D8SkPGZ0O0/dInBx8/+amcQayW5/dKMNTuvwm0ekbYoswQiK3YKxCZoMKnoW2ErBg2
         569HOVKJTiRE5d4y1IPG/DGwOeRoOA8ovdzGzRbAhboQ77v5sYv0/IzTOy0Op8gz2/Qk
         8y2DT00CajBqyt+Ue4jdQvdvECRkWfzyEJ5L1FdTBajEZluCC0TEqSd3IepXnaYe46qQ
         lx862441pq2ONtV6yJb+Uy/bfUtzLUSyYlGSbRUgdBXRlOjaVhXbvu+0n36UYd42ToRP
         HYK139G7SJyvKW51iW7eSa0sO+SEuDztRhwr/4q6q9MIi25icSH0ED7TQavTd/V8Vmz5
         Tpmw==
X-Gm-Message-State: APjAAAUDnIK2zwXCa7ABDIK2F9QqQDbAegrLUABFavaZP9AVA3jitX2L
	bL+5ZiFjzpeNOHVUZhAb7flTeg==
X-Google-Smtp-Source: APXvYqxtvaCM3hqb+7Izu1R5iMb3P+H/OrJHoZiO5jXOxIbwph4iMi5iHPiqM6OOmUWJg7dmwTafQA==
X-Received: by 2002:a63:b904:: with SMTP id z4mr24200059pge.388.1567423310696;
        Mon, 02 Sep 2019 04:21:50 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id o64sm7133044pjb.24.2019.09.02.04.21.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Sep 2019 04:21:50 -0700 (PDT)
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
Subject: [PATCH v6 2/5] kasan: add test for vmalloc
Date: Mon,  2 Sep 2019 21:20:25 +1000
Message-Id: <20190902112028.23773-3-dja@axtens.net>
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


