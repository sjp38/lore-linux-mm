Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE15BC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 818B4222CC
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qXZ2Vu+P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 818B4222CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 330FC8E000B; Wed, 13 Feb 2019 17:42:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BCA08E0001; Wed, 13 Feb 2019 17:42:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15B248E000B; Wed, 13 Feb 2019 17:42:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id B4D358E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:42:32 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id a5so1457229wrq.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:42:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=hKpBmvKhY62YcE+qk2JyFeoOHJdEVTVCpq3mJ7wKHeo=;
        b=TEsw0RV/yt56MmyinZrc1YdXA9lUlJiHPhRAeBdetnXO+tQydvDdL9eOUgYyb8mc+9
         /K63Y6f0t6lqMRynwDmExGpslUbgcCpc49XHbgty2u+VqnOH90ed4OQM2bORSPtY2csl
         4aLUJSrvdVArGqjcirrOrTgNWcgURRlVOhYaI7YMnscDqzRWQFGcovu95JCFdk9Hfnen
         IK62x3FDcd2QfWXv7b9piM7uDp7xt3hidK1vqNZdsSu0RhydYPBfBRcbc35Y+bfnkWwI
         +adOWcvCV3sbd5CHrk8z3IuGqDHcVwAbCDvHzSABGIryWoqhoSu/SHuXgNExZ3k691p5
         0DjA==
X-Gm-Message-State: AHQUAuZ95tRoKJR/1tvXvBqd9ycAbHPnjPDn+gA2+16NTCt9Jrtdba79
	kxajjMmqePoS1vo2vIxVO6wz+qh5wir2ycTTDA2dzGYJqk8DkOcGgyu2c/nsJxW9CgjHpppWct2
	SWMD7hcYva2dZtzRoTF50t4E73X4hvfmJoFivQkWt/wDCJZvuGiI5rYhAMIV4N38VfwEmmR9ZXo
	shzLllGTz82PcIOGUvx89InEe9G0eNHApBchJ8YECMj1RA3SbOMi2zKe9Ii4PfGE1pxl82SaBYY
	CwsFs5fjTT25C+msrTk8dMMApaMDGVB1exMtB+zbuxJzO0HJYFuZ7QDM4rpxuFWWGeBHboXRmz4
	8s/hijTE6k7pNQkWsZ/37ydAKNRKQAfCXl0PnMpOBDy6/mW9bkH9MxpRrBzqQSFXJ8uuO80GKnX
	s
X-Received: by 2002:a05:6000:8a:: with SMTP id m10mr275939wrx.79.1550097752247;
        Wed, 13 Feb 2019 14:42:32 -0800 (PST)
X-Received: by 2002:a05:6000:8a:: with SMTP id m10mr275899wrx.79.1550097750960;
        Wed, 13 Feb 2019 14:42:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550097750; cv=none;
        d=google.com; s=arc-20160816;
        b=MXoPx6AA0DGx+bCiw3zA/U1oMPZbInGiAjFdOvYSZDxuvQgLoNuoiGcabwilRn1u0y
         65jGnH+O5iyvVRi5gA3/m9nfiRIwnNp1WpgJ7n++4TC5JIDOR103TnQ9meFVgWx3vEgE
         w7WuS/SPp5/3unjYcBbQe5xfiwrbKdsJGAFEdCwhdjAc+35sby+F5e9KXh26iUTIe/AT
         xjmmvDKgVZUhCmlvPjkq+ZfxsQ8IPObg4D8/4GwHF2ua0eWMo83DQDI6wLNK/+KrUhFP
         7w2W8972aUE2tSgJzzzUNKM6ffGfW0gT1nyJg1zwpTyqxwkSdsFHJouZTbUFJ6mU239O
         AuMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=hKpBmvKhY62YcE+qk2JyFeoOHJdEVTVCpq3mJ7wKHeo=;
        b=f42xJrwhGv1A70CD5Z8/KufVOMePqBQHo2gH7o8skyhBgtl0B5H9TydjuorwG4LdgB
         kTlbOB8m021/CC0xN2bBLe3hR2E4gJiyeDD1Xb53X54mrUR5MWbeifL+st523PyzPBQY
         Twla9AVZZxONWYx5AWD1nR2rBjc9XrlKHAEjA0dmNHayOYzLZ2LFIOP37P2u/b9Zi4Rp
         S64sVhmMGhjwb/35GYnIms2n63i+sfPYN2ZS/0HB46cVdG44PZnx893vIroKPf6JDJf4
         G6kQnsf4ElpHHOmONHxijzNEyJ4Gz+5zFXwdEW3pu+AH/LJYRccTZAIMEVh+Gv9QX/R2
         RC1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qXZ2Vu+P;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t12sor383128wrw.18.2019.02.13.14.42.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 14:42:30 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qXZ2Vu+P;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=hKpBmvKhY62YcE+qk2JyFeoOHJdEVTVCpq3mJ7wKHeo=;
        b=qXZ2Vu+P6kthMEkjo4iNmgotT7rvJqsgrxxwiFIZl81jupiKBpLSUH2abdTiMlSLJs
         YahkFPUw4qFNOTutD7eS0RkUg8/4x71BFfYo03YVardx8EzGJKYPhLTp7k9S+a53JLMv
         M0pdfY2WiUJrH05PCxiQNB/qHgXxlZuJ3TU+QrEu0FcGIo457jatHpc7OPuJqaa9AZl6
         RGP/Zel8+olUZCL6uwyRtRpnAnITyKhXcOeL8t64zoh8KvFaWjZqdhMCNOoDamFRVbxm
         WFsxWPvhhEzgW6QvSW1k6TbPE36aOAgqq9OpmuIO5LEScw602S7o8oXyO3Tc0d4i2nNa
         pjag==
X-Google-Smtp-Source: AHgI3IawnVj1KBrwvlzP2l4yYPQzxhp3IgPK38fpbbnsPGtbn+e/GwYjxoGB2EAAlzWjGvPfKesd0w==
X-Received: by 2002:a5d:538a:: with SMTP id d10mr283768wrv.121.1550097750621;
        Wed, 13 Feb 2019 14:42:30 -0800 (PST)
Received: from localhost.localdomain ([91.75.74.250])
        by smtp.gmail.com with ESMTPSA id f196sm780810wme.36.2019.02.13.14.42.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 14:42:30 -0800 (PST)
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
Subject: [RFC PATCH v5 10/12] __wr_after_init: rodata_test: test __wr_after_init
Date: Thu, 14 Feb 2019 00:41:39 +0200
Message-Id: <c46757d8e40a2c4269c2a5376f7d96b17b81f250.1550097697.git.igor.stoppa@huawei.com>
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

The write protection of the __wr_after_init data can be verified with the
same methodology used for const data.

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
 mm/rodata_test.c | 27 ++++++++++++++++++++++++---
 1 file changed, 24 insertions(+), 3 deletions(-)

diff --git a/mm/rodata_test.c b/mm/rodata_test.c
index e1349520b436..a669cf9f5a61 100644
--- a/mm/rodata_test.c
+++ b/mm/rodata_test.c
@@ -16,8 +16,23 @@
 
 #define INIT_TEST_VAL 0xC3
 
+/*
+ * Note: __ro_after_init data is, for every practical effect, equivalent to
+ * const data, since they are even write protected at the same time; there
+ * is no need for separate testing.
+ * __wr_after_init data, otoh, is altered also after the write protection
+ * takes place and it cannot be exploitable for altering more permanent
+ * data.
+ */
+
 static const int rodata_test_data = INIT_TEST_VAL;
 
+#ifdef CONFIG_PRMEM
+static int wr_after_init_test_data __wr_after_init = INIT_TEST_VAL;
+extern long __start_wr_after_init;
+extern long __end_wr_after_init;
+#endif
+
 static bool test_data(char *data_type, const int *data,
 		      unsigned long start, unsigned long end)
 {
@@ -59,7 +74,13 @@ static bool test_data(char *data_type, const int *data,
 
 void rodata_test(void)
 {
-	test_data("rodata", &rodata_test_data,
-		  (unsigned long)&__start_rodata,
-		  (unsigned long)&__end_rodata);
+	if (!test_data("rodata", &rodata_test_data,
+		       (unsigned long)&__start_rodata,
+		       (unsigned long)&__end_rodata))
+		return;
+#ifdef CONFIG_PRMEM
+	    test_data("wr after init data", &wr_after_init_test_data,
+		      (unsigned long)&__start_wr_after_init,
+		      (unsigned long)&__end_wr_after_init);
+#endif
 }
-- 
2.19.1

