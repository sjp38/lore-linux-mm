Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81461C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DA29222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MIR5bn/f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DA29222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D40B58E000A; Wed, 13 Feb 2019 17:42:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF6AD8E0001; Wed, 13 Feb 2019 17:42:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBCED8E000A; Wed, 13 Feb 2019 17:42:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6069C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:42:29 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v16so1412385wru.8
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:42:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=vgb7J+uzu72a1nLgAIDJQpmIZYI0IWGcwJEvrx3eHk8=;
        b=r8LNN9A4g6Kgu1L0fJrxzWlE+WlwfcYmC6nefqfPg/52sThW+5jbKrktWMw9uhNW4j
         xt2GUwXKGFOuYEcf8DF7/B3fR1lXUTlwqbnRNfpqvsMxyLJ7/a6exrYxDYaLgWDjWjY+
         VCV4K5vaT7Gj47kT4o8AbmetsGKfzjcvJ7xOIxvZh0akdHMOluMFQXymDipUiMNArvAV
         kT2NBEZ3tLPbccGOH2InWejTwRF/wcMPKXWvm1wNVEhhYc53jJCtk+lwiBF52uLrxnNX
         V9yPKNIYkRTKnwjLxS6lVf7KVZUvQ7pmiEpOGWPskiv/fN7r2sQKnJ7T5uvQSmLgZANQ
         s2Mg==
X-Gm-Message-State: AHQUAuZc8Hi+EhznTVZJzIbnUwmUKinBCTx1WAsdLQ2SDkyU7UfQWyjW
	YJpWFGy4CbqpRzX7p0z2kd9Q0J9oEw1HuYtiMr3RHhDkx8Y3lHvmpPtZOvn+sZiNgRNDL5DI/LZ
	lylLhbJHzp0bePMot6K90MZgq98bvGTQ8pLtuMjD2Zz7yMCU8/csX4H8d5z3GLBUfJYubjOAjWi
	hsYo5KtkZFqhIXiGRWwoKdH+zmk6fq2p0NIWyWNGZ4zqzDssYVV2vAZzVWIH0BGepNbOsdu9L9E
	AAxMAXqFk/4luXt8kPw5kxTfHZl60g+MyvUEyCfqiq5tfY3ZtlCzEEi1QTQ5w1Zsdo7GBL+cY/3
	hN1RxPAig8PHGpEECdiwm6PGLZBMS+wCWKgcqkad1WMBOTSAotcxzZu9kdMrBLlAdsgrIeCROfR
	s
X-Received: by 2002:a1c:4006:: with SMTP id n6mr276892wma.137.1550097748898;
        Wed, 13 Feb 2019 14:42:28 -0800 (PST)
X-Received: by 2002:a1c:4006:: with SMTP id n6mr276856wma.137.1550097747621;
        Wed, 13 Feb 2019 14:42:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550097747; cv=none;
        d=google.com; s=arc-20160816;
        b=wClrNA1L8Ha38L9C3/DM1mznmY5wtRE++26qQeRAvguMnjFo0B4YPAZM5ZvEBXE2Pt
         7OOkdgoVw3iHtoqXWeoW0mfnwNttEZYDc1JnbkP0/CHKrKmA7zMNDqfMK2EaFxI54Jka
         i6Hd1JdhZR66+fgGov5ztcfVWyVHReIwSZLSMmVwV5TbeSpbdMmzppBUpvwHRVIQrDzT
         QS24/Uzl1c8O0u2PXYTJEcBDll5AOQ5s4ZgAxHxp9pTX4ibA7jphD56NR5DXOOCQe7dp
         B0A/ZOrhPtWbfcXo1U9AHJAEVuBdo3R3WiExo5vEe+g4LDd+dPZqRurxJnMf+wcCNTSQ
         IB7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=vgb7J+uzu72a1nLgAIDJQpmIZYI0IWGcwJEvrx3eHk8=;
        b=ByEoDKtZxYDOmuyVLP0NGTz3JlVuvyGV0tDOvRJVHNUKAeJ4MupikLaVpXdfFZND4F
         RBPxCZBs5X3UnH5YWyD67e3CH863d6Csuo1CoTuiqgVGiTZo4aYvDs0FwdPcCBLcTRJw
         Z5jDGGjDPvp8oCJ/SDM6ep4Bu8dDo3b+eB8Pu/Pjkho/gXjGAZfFqFfMSrJ0iIHB9wcr
         oYQf5DhIz9GQJP4kbNOGCjftyBni4x/O6G/TPN1R8pzkvDfG60EkBPZpUp6TqHQKTBlE
         5eOQJXKhZhoTpSAgJmQqc9FQvc/0IrQYpYmi7zFQSm0R1D9rGcUYv7EVEFKJD8T2DHrq
         Ihfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="MIR5bn/f";
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l23sor366566wmi.23.2019.02.13.14.42.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 14:42:27 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="MIR5bn/f";
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=vgb7J+uzu72a1nLgAIDJQpmIZYI0IWGcwJEvrx3eHk8=;
        b=MIR5bn/fwd0D9N8Om1k7o8c/GCTN6LB0C3GeABYZt+IdgyaeK88/xnCr2afThsQtba
         OdrxjaKohAGefxP47UJqddJuo1wL6QROIgYS0nqcNKVXavRx0k4ynvja67Sso2VpdoLb
         z9j+1xtt6Ba4iqVJyiEtsV6kVv2f6na8AIvyf5kQBP+bHJANL/fMnSMajCnjT+s2x5We
         S0NgnOqmddtMsILaxMaOff7AK5WqJx2F8sVI6dC5yeP3exfq/e0MKp75IrcRWN3PIgcX
         a55clojZ32DlpLA7ve3dKZwubnysbhMO49f7OxiSBhfj+QUGvfT6whA+F8zobwRBMXHz
         Re+w==
X-Google-Smtp-Source: AHgI3IY/qpx9bIN8m/MToJYg7+VC1FFLoWbQiBQL48Q2ZmiFFaSGSIEBHj0CtX918v3oqTB9pREW7w==
X-Received: by 2002:a1c:14:: with SMTP id 20mr259551wma.91.1550097747249;
        Wed, 13 Feb 2019 14:42:27 -0800 (PST)
Received: from localhost.localdomain ([91.75.74.250])
        by smtp.gmail.com with ESMTPSA id f196sm780810wme.36.2019.02.13.14.42.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 14:42:26 -0800 (PST)
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
Subject: [RFC PATCH v5 09/12] __wr_after_init: rodata_test: refactor tests
Date: Thu, 14 Feb 2019 00:41:38 +0200
Message-Id: <826811306c45f5735b83b169017b40f563f21fba.1550097697.git.igor.stoppa@huawei.com>
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

