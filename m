Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 129C7C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4FFE214DA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h0Rzbxd5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4FFE214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D7048E0199; Mon, 11 Feb 2019 18:28:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AC7C8E0189; Mon, 11 Feb 2019 18:28:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 477F08E0199; Mon, 11 Feb 2019 18:28:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFAE68E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:28:32 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id x3so221371wru.22
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:28:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=FDryqu5ur4j9ePg/wc9MnpTPYVkBg8AjJFLLJs3gfA8=;
        b=CimRDiFCjEFO38H/4J2qQiQYg9D3vKNrjjQCT3sKzEnPSQhGO0E3Fjs67iq4L2yXkP
         TlLsJK71Ecbn66xKsLm+cgrewoa7bWuCsObBiuu++TB+8YUbS1jBJCuEPwaKthAmhzgl
         C+QgJWyfcAcgk8nCrAFkXa707TBDdbiCZRJvEoX009cXaSh68q4s6TB1NapjGoHw/wj7
         fFbj1gUEWkDWikEMYUBavHKZNlLiKqfIf5Xlm8HgFScUS4Cbwcw5POWro5XNYEr6MLVE
         5ojE+MPZJ8t18Q2Khl7NnqTsS8dN3j98gm2EBLYJgClR/GJwOyDQjLHrd4qsRdzDuCa1
         gJdg==
X-Gm-Message-State: AHQUAuYgCOi9faKWp6O4kNG1kGvwXnYcIV9D97zFQt5FOJEGY+nhugLN
	E3T0xs4wEznQf+1hbgdluhWvVLOGre46rNnb+/WXiVdbcxrkwVpjmIn7XBK6qhyiRlSZtR2LT7y
	DMIFmHZqIjLIeJGJzCyltg0XHMyX0z420A8pBUYN1oKvW9/0mBteL19rfMH3JsX1cXPbFTj1tf1
	iOTuEV16/3fpMPuXMpvErmCiCSZMugp1KUB/Zrz+r2KkXaVaQufI4cZL2HvYxrs2Fwc1xyL8LDb
	3s9GDu72TBaHGqIucBSJzuxby6vh2xjheEMZkxOm2QWOWvxrtkk9Jk0kTBM+BhJ/hXcgOLGmAKd
	v//dJYuR0msFPJjylac0Z+6KvfKyVsc+oP8KPhXyraDTIvCmariYpJGADUWumeJmFXctomgky1G
	8
X-Received: by 2002:a5d:4486:: with SMTP id j6mr456269wrq.41.1549927712438;
        Mon, 11 Feb 2019 15:28:32 -0800 (PST)
X-Received: by 2002:a5d:4486:: with SMTP id j6mr456220wrq.41.1549927711129;
        Mon, 11 Feb 2019 15:28:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549927711; cv=none;
        d=google.com; s=arc-20160816;
        b=us5uFo8j7PAvA+lhVOBL1u4fVxBnREuKx2V7/p3CQJRfTpYTb+SzlYNTbI7IdTTWUG
         eb8pk+eEKZ1kmsSknbjtRer7QQxfM3Pmg5+3sCnCi/cPTwD1mbM1vONj86Oj9rktlUW5
         1sTdaWr1cNKeiBbQ6jLAA4+Fv60snZDVnRg7kL7ByCSpXJEIXflU0rah0MwaqZjn7Y4Q
         Sj9PMfeGQEwMxEE8YmlUdeY29/vGPav1CJpi0aXGoAEdpumIIoz8jXts2XhzkR60cdaY
         l3y6oV0YY1Hvun60LJ2RsLoOyppRo2s9QowIKPfDXcJluZNthpT5ColBvA93yoyl+UAp
         uMFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=FDryqu5ur4j9ePg/wc9MnpTPYVkBg8AjJFLLJs3gfA8=;
        b=Mtw8mnRsCvFbU0ATmo+xEzE//jRpM15teOMZjpWjuThT5PhVryKHHnqE8xSRGqDHJE
         xEBdKqGTYsnd32OfUyPOPgYQ2e2NxduXPZaeSUEcWDwKf3Q7cN6Wmc/j0wDhHSSTO67g
         /BdeRnG+tK9Fswu2Sm+broI0dJN8HWJY9w/nMCQG7mjxukWx5zyPUIZInDXCD3n1R7J9
         XExKfFauYjyUSxPBsH7GGOmUnFf/BXxjSMSrWom0xYKphIfN0Ai4UfYlh3RMd3Y8y7Ne
         XxfiQo2mlrE1U88SA/WaLRUNw4ZLzfrWsexFDlHJVa/wk65QwYvJu/Qi/jcsjTvHnpIL
         BHBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=h0Rzbxd5;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f193sor503703wme.9.2019.02.11.15.28.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 15:28:31 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=h0Rzbxd5;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=FDryqu5ur4j9ePg/wc9MnpTPYVkBg8AjJFLLJs3gfA8=;
        b=h0Rzbxd5vn6TVM2F2wuqMENuqEgutSdwfh3qz1lUYLLEMfzzzFr+9FKaWiM0SL7W/l
         PMFr/LndNJVr8UlZOHtY8hVVLm1ymPo6bBVirh1KqTOo1QuyQ10b8dyw6Up5cQgDaCI1
         MqMBnExiZM6pKTNfcEJSMM6f+AP7TnRUhahb1YCl/NAT19yR8i9SdJIdijWHiJAsJHOH
         rA/m0TBUELlebS6i3BK6rYJIqveTENGDdz52jo5px/scN6ruwhzpSOrXXFX86fD/rg/U
         DWtGaSmXDyNtXRrLF30Q6TRcElVr7wnfYYgwhiq9Pjo/v/ZbTPeSEW/poumVo6sQ/JpM
         tlNw==
X-Google-Smtp-Source: AHgI3IbtlJdoliv99+hxRUZolITpfcILFWmzZayl1QjTtb4jAfcYq8ZcflEbQCEsF264j4rFm1ARKw==
X-Received: by 2002:a1c:4044:: with SMTP id n65mr477987wma.85.1549927710788;
        Mon, 11 Feb 2019 15:28:30 -0800 (PST)
Received: from localhost.localdomain (bba134232.alshamil.net.ae. [217.165.113.120])
        by smtp.gmail.com with ESMTPSA id e67sm1470295wmg.1.2019.02.11.15.28.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:28:30 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
X-Google-Original-From: Igor Stoppa <igor.stoppa@huawei.com>
To: 
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v4 08/12] __wr_after_init: lkdtm test
Date: Tue, 12 Feb 2019 01:27:45 +0200
Message-Id: <8708f8d2c541ce803072acec153f38011b271e90.1549927666.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1549927666.git.igor.stoppa@huawei.com>
References: <cover.1549927666.git.igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Verify that trying to modify a variable with the __wr_after_init
attribute will cause a crash.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 drivers/misc/lkdtm/core.c  |  3 +++
 drivers/misc/lkdtm/lkdtm.h |  3 +++
 drivers/misc/lkdtm/perms.c | 29 +++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+)

diff --git a/drivers/misc/lkdtm/core.c b/drivers/misc/lkdtm/core.c
index 2837dc77478e..73c34b17c433 100644
--- a/drivers/misc/lkdtm/core.c
+++ b/drivers/misc/lkdtm/core.c
@@ -155,6 +155,9 @@ static const struct crashtype crashtypes[] = {
 	CRASHTYPE(ACCESS_USERSPACE),
 	CRASHTYPE(WRITE_RO),
 	CRASHTYPE(WRITE_RO_AFTER_INIT),
+#ifdef CONFIG_PRMEM
+	CRASHTYPE(WRITE_WR_AFTER_INIT),
+#endif
 	CRASHTYPE(WRITE_KERN),
 	CRASHTYPE(REFCOUNT_INC_OVERFLOW),
 	CRASHTYPE(REFCOUNT_ADD_OVERFLOW),
diff --git a/drivers/misc/lkdtm/lkdtm.h b/drivers/misc/lkdtm/lkdtm.h
index 3c6fd327e166..abba2f52ffa6 100644
--- a/drivers/misc/lkdtm/lkdtm.h
+++ b/drivers/misc/lkdtm/lkdtm.h
@@ -38,6 +38,9 @@ void lkdtm_READ_BUDDY_AFTER_FREE(void);
 void __init lkdtm_perms_init(void);
 void lkdtm_WRITE_RO(void);
 void lkdtm_WRITE_RO_AFTER_INIT(void);
+#ifdef CONFIG_PRMEM
+void lkdtm_WRITE_WR_AFTER_INIT(void);
+#endif
 void lkdtm_WRITE_KERN(void);
 void lkdtm_EXEC_DATA(void);
 void lkdtm_EXEC_STACK(void);
diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
index 53b85c9d16b8..f681730aa652 100644
--- a/drivers/misc/lkdtm/perms.c
+++ b/drivers/misc/lkdtm/perms.c
@@ -9,6 +9,7 @@
 #include <linux/vmalloc.h>
 #include <linux/mman.h>
 #include <linux/uaccess.h>
+#include <linux/prmem.h>
 #include <asm/cacheflush.h>
 
 /* Whether or not to fill the target memory area with do_nothing(). */
@@ -27,6 +28,10 @@ static const unsigned long rodata = 0xAA55AA55;
 /* This is marked __ro_after_init, so it should ultimately be .rodata. */
 static unsigned long ro_after_init __ro_after_init = 0x55AA5500;
 
+/* This is marked __wr_after_init, so it should be in .rodata. */
+static
+unsigned long wr_after_init __wr_after_init = 0x55AA5500;
+
 /*
  * This just returns to the caller. It is designed to be copied into
  * non-executable memory regions.
@@ -104,6 +109,28 @@ void lkdtm_WRITE_RO_AFTER_INIT(void)
 	*ptr ^= 0xabcd1234;
 }
 
+#ifdef CONFIG_PRMEM
+
+void lkdtm_WRITE_WR_AFTER_INIT(void)
+{
+	unsigned long *ptr = &wr_after_init;
+
+	/*
+	 * Verify we were written to during init. Since an Oops
+	 * is considered a "success", a failure is to just skip the
+	 * real test.
+	 */
+	if ((*ptr & 0xAA) != 0xAA) {
+		pr_info("%p was NOT written during init!?\n", ptr);
+		return;
+	}
+
+	pr_info("attempting bad wr_after_init write at %p\n", ptr);
+	*ptr ^= 0xabcd1234;
+}
+
+#endif
+
 void lkdtm_WRITE_KERN(void)
 {
 	size_t size;
@@ -200,4 +227,6 @@ void __init lkdtm_perms_init(void)
 	/* Make sure we can write to __ro_after_init values during __init */
 	ro_after_init |= 0xAA;
 
+	/* Make sure we can write to __wr_after_init during __init */
+	wr_after_init |= 0xAA;
 }
-- 
2.19.1

