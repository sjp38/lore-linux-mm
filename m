Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ADA4C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15E69214DA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VmiIU8pX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15E69214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0B638E019A; Mon, 11 Feb 2019 18:28:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB86D8E0189; Mon, 11 Feb 2019 18:28:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CDE18E019A; Mon, 11 Feb 2019 18:28:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 49CC98E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:28:36 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id t133so245853wmg.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:28:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=vgb7J+uzu72a1nLgAIDJQpmIZYI0IWGcwJEvrx3eHk8=;
        b=OwMSbqSDTUPZ6gKp2d4PWeA9uNuSba4WaEP19RfIthKkplBf3qFa3635uOvBo30zn2
         lyhlXCzlEynp2tbL834m0s7Chcuwe0Eb6Bm/FxEjXNEdTq9WufOIvItQdU7ylG0Jc3uf
         afGub34Llo706an/LIZLLV/sDicHbY6oWeX63+aS4X/WJfklAQ2C/isDJc+5auPM4xT3
         YhNs5hrXYYBEyjsR/Hge7+B8FPWhrRF/1zSYDGUhIs2Ocv2c5zr+Ph3nKzkt21s/1wFW
         HATPVW3JkgS0rrrYPeGA8jlSFlV/3wecJYA19YaOSE8/dQpFNeS9aNTtipzKjNqnvdgf
         pXjA==
X-Gm-Message-State: AHQUAubmgv1yQxGd2WVKbLJhTPf+fdjvcnDd3JLjcphy9c8m4ICoTF+x
	w5/9QHgOH6uNZuYt04L/vS221GEZRi+4sgTiGs6k+UWdCUeZOKnth1mIpqAGDQqXZM5vqQHszKV
	3VcmCQlzyyLXmz/dylohqhRZD8sPWE3p6X07BdPl01AsTDVTJ1cKpYqRwBQbz6DUz3/fnAqpo+G
	sGtnNm7iHsqqL7y3o3JhFnFG2d/HTT6cenrcLn96B6E82obgRm3ZAThdjbFCEqs7wTKsv5qu2KA
	BralepOviB2GYbkaAfmRWspefKqWu5WM0RYgHT0kDQ6C+XrZzgvCB53CSmVu5QSDPqfQLoT5qbZ
	i8UwtygNk9J0rewscB6bIw+Ma+UF5z94J+U+KZF3E5VzTOD54jGAE4NOMN6XCymAGwYwmnh12nj
	B
X-Received: by 2002:a1c:9e4a:: with SMTP id h71mr517373wme.82.1549927715825;
        Mon, 11 Feb 2019 15:28:35 -0800 (PST)
X-Received: by 2002:a1c:9e4a:: with SMTP id h71mr517323wme.82.1549927714542;
        Mon, 11 Feb 2019 15:28:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549927714; cv=none;
        d=google.com; s=arc-20160816;
        b=UGRKSWEkeSTEFhFBZU9FtJ0W+JQV4iv30cYwiW6wPd9MDlFtuZI1VWsWhXKOXsoskJ
         YueGHMalXUHPh3k53A2ugDWL586vNkYEQCV3ihVa+/Uhu6uCMNcifnJrwp9r7TVBUtpp
         JHKdVRhq0wuh6dV6pyPgr+k+d1lRu1WwmwLcOxd5HYoH0I/gIv/jsrrPmuf5Z8ZwrS71
         JL9qgOAP9oH7VE35zzkL6aMMY7AMR1CRV344el53Ywtgemmme9SOPDAlXxhV1jD1FRHI
         H0XfvXWqn121G6S3WqZoz8JQoPdxmprTMTzOEp8k3/gBOvrra7zO5xNktxw/ep45sIde
         tCaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=vgb7J+uzu72a1nLgAIDJQpmIZYI0IWGcwJEvrx3eHk8=;
        b=0dZl+jM3avIpPwR3H4q6h4wJRWEl9/KO+hXo8UVnujcCiAoAeFWJDOORYf/+C3CBnt
         oGsQV22N1LqzFsEiTeAx/bcISdfuvEQPStMPIcYCx0TM9XPaJZcRc386AT5V5JIIy1jw
         mfhJEQLRePOAaNEbWodZAyAuLYhuZ+ECWoaFo4a2W3P/9JouRXaGd8+4HpsyipgNDUXJ
         gYndz271i0yOwM5uAG2EFrjFqzAbCOjy4SAfKX6wDH3uVbPWAsuZcivJAWB8u3Lc1vbV
         jjpD9STEFkjA6vlZ6+ThWlUlS9fQM8o2dn+utLQUla0Dnoz4wGMnfAjeWbCoZiCh/UB4
         2U+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VmiIU8pX;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d7sor3668525wrx.34.2019.02.11.15.28.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 15:28:34 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VmiIU8pX;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=vgb7J+uzu72a1nLgAIDJQpmIZYI0IWGcwJEvrx3eHk8=;
        b=VmiIU8pXfiJ8oLtorDhULSxsmh+YjuTJjvlq8YuRiNowB4/1UqpCrVw5BosEBTfL6V
         lQbb1zyKnf0f37rNuOWdB/36I0sBvIypEXOaJlidU+6cLxaed7X4JobdhlwNv7l2ZOgr
         CLcpjJ/DKikqWa2/di7U6WvgXoxM13L73BBHmEh+vVp+7fBOqFY3BuY7Dsv3OewGcQn7
         wx+umnTSpRY8mM+athafH9jgbBlDHfGt5caNxzNx1BFVa2rsre/0TI78tes3g2BD6/u6
         dID0vUXju22Zkh/Kep+vSEP2+NHeXyAdLybiLgP8GoWTcJfJRcKIg6pEbmyXmkESLdcX
         RvPg==
X-Google-Smtp-Source: AHgI3IbQwu8eTmjbJnx/2r01oGyJDgWGHUAAfDPRDsTqvehJCmHsCuN42bxdkY5qB2bklveZMh0xdg==
X-Received: by 2002:adf:f410:: with SMTP id g16mr517807wro.246.1549927714236;
        Mon, 11 Feb 2019 15:28:34 -0800 (PST)
Received: from localhost.localdomain (bba134232.alshamil.net.ae. [217.165.113.120])
        by smtp.gmail.com with ESMTPSA id e67sm1470295wmg.1.2019.02.11.15.28.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:28:33 -0800 (PST)
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
Subject: [RFC PATCH v4 09/12] __wr_after_init: rodata_test: refactor tests
Date: Tue, 12 Feb 2019 01:27:46 +0200
Message-Id: <ff02823336ca9959ec53adc469aa113fd00e03cb.1549927666.git.igor.stoppa@huawei.com>
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

Refactor the test cases, in preparation for using them also for testing
__wr_after_init memory, when available.

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
 mm/rodata_test.c | 48 ++++++++++++++++++++++++++++--------------------
 1 file changed, 28 insertions(+), 20 deletions(-)

diff --git a/mm/rodata_test.c b/mm/rodata_test.c
index d908c8769b48..e1349520b436 100644
--- a/mm/rodata_test.c
+++ b/mm/rodata_test.c
@@ -14,44 +14,52 @@
 #include <linux/uaccess.h>
 #include <asm/sections.h>
 
-static const int rodata_test_data = 0xC3;
+#define INIT_TEST_VAL 0xC3
 
-void rodata_test(void)
+static const int rodata_test_data = INIT_TEST_VAL;
+
+static bool test_data(char *data_type, const int *data,
+		      unsigned long start, unsigned long end)
 {
-	unsigned long start, end;
 	int zero = 0;
 
 	/* test 1: read the value */
 	/* If this test fails, some previous testrun has clobbered the state */
-	if (!rodata_test_data) {
-		pr_err("test 1 fails (start data)\n");
-		return;
+	if (*data != INIT_TEST_VAL) {
+		pr_err("%s: test 1 fails (init data value)\n", data_type);
+		return false;
 	}
 
 	/* test 2: write to the variable; this should fault */
-	if (!probe_kernel_write((void *)&rodata_test_data,
-				(void *)&zero, sizeof(zero))) {
-		pr_err("test data was not read only\n");
-		return;
+	if (!probe_kernel_write((void *)data, (void *)&zero, sizeof(zero))) {
+		pr_err("%s: test data was not read only\n", data_type);
+		return false;
 	}
 
 	/* test 3: check the value hasn't changed */
-	if (rodata_test_data == zero) {
-		pr_err("test data was changed\n");
-		return;
+	if (*data != INIT_TEST_VAL) {
+		pr_err("%s: test data was changed\n", data_type);
+		return false;
 	}
 
 	/* test 4: check if the rodata section is PAGE_SIZE aligned */
-	start = (unsigned long)__start_rodata;
-	end = (unsigned long)__end_rodata;
 	if (start & (PAGE_SIZE - 1)) {
-		pr_err("start of .rodata is not page size aligned\n");
-		return;
+		pr_err("%s: start of data is not page size aligned\n",
+		       data_type);
+		return false;
 	}
 	if (end & (PAGE_SIZE - 1)) {
-		pr_err("end of .rodata is not page size aligned\n");
-		return;
+		pr_err("%s: end of data is not page size aligned\n",
+		       data_type);
+		return false;
 	}
+	pr_info("%s tests were successful", data_type);
+	return true;
+}
 
-	pr_info("all tests were successful\n");
+void rodata_test(void)
+{
+	test_data("rodata", &rodata_test_data,
+		  (unsigned long)&__start_rodata,
+		  (unsigned long)&__end_rodata);
 }
-- 
2.19.1

