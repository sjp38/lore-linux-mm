Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2D6BC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87A3A222CC
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NjIzVPkQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87A3A222CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A4768E0009; Wed, 13 Feb 2019 17:42:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3534B8E0001; Wed, 13 Feb 2019 17:42:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 243A78E0009; Wed, 13 Feb 2019 17:42:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id BCFEF8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:42:25 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id e2so1420429wrv.16
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:42:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=FDryqu5ur4j9ePg/wc9MnpTPYVkBg8AjJFLLJs3gfA8=;
        b=hoSKbBtfpbj9OHt5963nQzgnb0bv0uVt0FMtKRj+smqQjzX/jfxplOdpNbFITsJyz4
         AFT6o8vU7Nk1U2tv9kfl6b/XzyN9O8IQj26bSNqsqDWcw3lBrNP+qmBfIZx2RA5+hgGx
         KSqiOQiwg+QV1PuTJo8LIGDcEdo+ojtLQ+iTmb2YfNS7dBMPwtl8yTAdevXvEnDDLmav
         Q15ITG9obGLFXcHkNGs3s0pzPR3K44yUu37U/w/ylSGM+GQtD7FkUhFQR/MvEl4yNr0T
         x/08bIBpvePWbcZ+F4qFixL3BrpROE4uIon1Qpje+x6RAHaHepUHXXiOOPiYChoKuHIC
         NKRw==
X-Gm-Message-State: AHQUAuYbVhoL00Blsdb8sJO/B/cb6k/qpZLjBwJpBhC69+tXP0jf8dTr
	cInYbF8O9UyAW2cQTcP1uXXE9R9+YVxwcBWR+Im01wSShKY3ZedSY9mdtAnvGTp3v+YqMvvMDrW
	QgvC5oiK6tR/ZVjrzA3hhUnal9KFbqS3gUuj1G5NLFj7TWhYm8FwOit7v5jIrxwnyo7TIn+gur/
	UaeHvhVHV/CWX5gsHoYLryMP0XAkm09yNSUH/rptjKS/MzFqBve6pFX7OXI2LRYK+EvTcs6D6Jb
	0HQsL+CRbuCfJB6S8Lm5jxeAd7CiD9aQLb6GfYO127X/ddZSuEEOex2jL4xwtyOBKqbtPfSTISb
	BPHjCnrgK3rYHfU4xubXxSJujZEPLsBqME8igIRoDKNArAeu3/b0PraxsQ29xe1rFZuy/Mi02iI
	s
X-Received: by 2002:adf:f410:: with SMTP id g16mr319589wro.246.1550097745286;
        Wed, 13 Feb 2019 14:42:25 -0800 (PST)
X-Received: by 2002:adf:f410:: with SMTP id g16mr319531wro.246.1550097743982;
        Wed, 13 Feb 2019 14:42:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550097743; cv=none;
        d=google.com; s=arc-20160816;
        b=aWhETM7947fM7ipKcGBSlAgCgsvBV9Kp1qYqjCX9D9snLKM9KwmNaGYiKqtowNODYG
         dAUvQi5c04ztSX/qie+bfkaI1K+HK9Wr5ZsWkugPBLxBs84t14hQbHzkt/rn0t5NzoNb
         ldcUv8mhDUNQhhsTIsddxxA2ZPxYZKrNL7g5KA8/132lQBI6UnIVI3+zW7SWsv/wnvFh
         tQf5UBtjfPC0UZTu6fkqD/qhB3q85aJcDQnvODqIgKDlIYu0iim+rO8WIyvRLQmwv3eJ
         /UT3HFxrBkRySAe6UDDKxncXyMzm2D2vtxQMrZPYNvD1LaW9vk6BB4w6XmB4TDHwBVcq
         QJvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=FDryqu5ur4j9ePg/wc9MnpTPYVkBg8AjJFLLJs3gfA8=;
        b=qnxBd0ErdEM3BjZ9VmLpuq54PGx2it88wh0d5YyKfL162GIJ+F2Sn9d2MATuUFSvmg
         z9WEOX7hHxM9rEQDwyKF3LzJg0JEuO5GnPWS6Eq3swBJADnK0gNnTz2JqxamrEialnUy
         ZKjdUBWID1H/o1DRYAFcpDvFM527JFms9Kf3CWLprrHZrmmBuS8lDNw7SpI56aANWlIR
         YqepDchEntkSvt13mdMRAUA2zbOuKsq8T+1j1O708t3/c7RKMAW+Xa/bHFTlG20WaNLs
         lZm8hIjLJm620xpzH7IhLX7kNmSgylfyXSxIE2Ux0eFvMxnrZwkznSHZxT2uCvL0dUZa
         lJ1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NjIzVPkQ;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t8sor377761wmh.15.2019.02.13.14.42.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 14:42:23 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NjIzVPkQ;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=FDryqu5ur4j9ePg/wc9MnpTPYVkBg8AjJFLLJs3gfA8=;
        b=NjIzVPkQI+bCcLNEI/Rt4U85tu0DGaKik0uQCOMXvSEkO/SvlHDTcAU8+IhLk21y1p
         5m+FNp4iAWRrJ/k/DDDQZG8GEE1PO9QmTNuEZj9sZ3t8GOVxkaHS88LjJhq6BKQ7N9X3
         FJu9x7w0j1lXKAVEa9NaOLOiDSwyj28NVgD1R/mi4Ij/muEfi9+4T/7X6PO8M08gwtT4
         aaJwB93WJNH0Lk9jcLkQo1ju6chbGRcgdS0TIt45lL7EReQ2hPmGRvbjzBEH7IuKbkQK
         PTBJS9E+bupu40oKgPBcvq9VxB11GBhj6qIU7b2yqA1Ep6uVGLC5RY2njYXlBvxDI91M
         RhlQ==
X-Google-Smtp-Source: AHgI3Ia10COWxjNMWWeGUZ4kyfPoLmhHvf/GKRNqfO/0o20+P2q+df+RyfuyEETkMZNIJGOmGU8VSw==
X-Received: by 2002:a1c:e086:: with SMTP id x128mr325384wmg.10.1550097743522;
        Wed, 13 Feb 2019 14:42:23 -0800 (PST)
Received: from localhost.localdomain ([91.75.74.250])
        by smtp.gmail.com with ESMTPSA id f196sm780810wme.36.2019.02.13.14.42.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 14:42:22 -0800 (PST)
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
Subject: [RFC PATCH v5 08/12] __wr_after_init: lkdtm test
Date: Thu, 14 Feb 2019 00:41:37 +0200
Message-Id: <b739e9f8f43cb9cf5843fcb2f90b569bd560fccc.1550097697.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1550097697.git.igor.stoppa@huawei.com>
References: <cover.1550097697.git.igor.stoppa@huawei.com>
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

