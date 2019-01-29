Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED4C3C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A86E520844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A86E520844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55A7C8E000B; Tue, 29 Jan 2019 13:49:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50D608E0008; Tue, 29 Jan 2019 13:49:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3861F8E000B; Tue, 29 Jan 2019 13:49:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D4EE78E0008
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:49:58 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y35so8312908edb.5
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:49:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wnz8yl/7ZDxGsxncPzV542oeZz/bggs58LBo1ZJN2WI=;
        b=a0cWV25lbeRhK0AqMnhCCpqHo3HDWyGITUeDjq0xvUcaDta6VtwmBKo+EWcYLcmnJK
         QvqEdFRYi9VlBFtqA+O3yn8xFkO3L3KQ59IXL2hoGIQOjMi1WSuTQtQY3RiapFosluXs
         4YIyVeiGdcwBLNQzF0kKxhFuXgH6FHz+uVASIBju8ZgEJJyBLHLCry4/oe8cEdpDFgjY
         pBIK8/ZnWsRuNUiuEf3j/64auyMC51f0x5jshHEVGmEb0iR5WYwwamyppDM6IotR+sFL
         wvJWNMHmdYzNsM58FyulDsA69icynuVNtwHj/UpkO7/dMOm5NQxpdadDqV6VHFZ0tcKt
         wpYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUuke9NC27rEVAVOoXrZEGhulByGXhgcfKrxb5RLIoLraPkLxX6rsQ
	K30QxDTYDPZlEAL4/QynpOkt/GLMtBSMdn/a8JfXaIYci35PjcODE9fxaHCc7Wsq8wNxR4eVr76
	Xh/VYg+QGu1wxTM39cX/QsAEpyzK6V+tsuWhyhCEWW0DJJt7R6/USU04xEJQZGDFp4g==
X-Received: by 2002:aa7:db0e:: with SMTP id t14mr26815850eds.292.1548787798318;
        Tue, 29 Jan 2019 10:49:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN68+by8OSl0TUAYMRV91V3kDOpfnZmfpyiiaABjTe9pgf1c7BcbLsq+sweIRop4qW2E3lIo
X-Received: by 2002:aa7:db0e:: with SMTP id t14mr26815786eds.292.1548787797302;
        Tue, 29 Jan 2019 10:49:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787797; cv=none;
        d=google.com; s=arc-20160816;
        b=zeGvYqAMtWNDuFzWgch5lWp7aS1CKREIC0fl83TTmXWWy6rGh8ICZXSLSFRBPJXznq
         3vwfAjzEbEaMuCADDoxaTqNArNgwnqHJE2e6/RbQTAEFm7VOWC9Hg1TFxvj0CCk1TcbN
         egE9JV3uZTahs2FyRxbaKsSGVrs5KljRhKhTYflXPfWnsu5oGDBW+mK04NMavuaiqBXC
         Xym5Tj3+7ML7AbbW0uP6iTjuWJcLUYM2K0kpjs1LlFJpMbxx23PxQZtbl5BKdbXf9g3a
         A9LKRkYyLVzVNo8K+cvs+ryd4rp8lgIe5krNoMcJs1/AiKusJF4ettdkQO+PM2mcBMmK
         IqYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=wnz8yl/7ZDxGsxncPzV542oeZz/bggs58LBo1ZJN2WI=;
        b=zpKmof5eZWSlOszrtzTeUaCIiQx6CU2DKb6mEsbf9+RmuRT/AuErA6u12TtoroO86x
         5hbMVLofW4CKzVCTdcgZnz39cqyxST69jx8ODnb8dPJ00S8wpw7EnRalDfTelpyTFUkT
         7PZNC8qnzw3RNwYOINsqBvsREt/0Lm+VlPy7RsfNIvznv4XrCGo0Q3NB0Gy67ekrgL3W
         FRe7jVIGYRtYIW+lxXN/3EpYJLxW0RLUsKj8VGhhsSEfprmrHxluFfcQrziXCVR3HTiK
         /ZWCC6iKWzvtOJvaX5XeTq0qNqVXs5ItyR7Ckyqca0vnwMWJfrRDQpz9okyaY3NYDuL3
         AU0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v3-v6si1218521eji.60.2019.01.29.10.49.56
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:49:57 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 324F5A78;
	Tue, 29 Jan 2019 10:49:56 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 847653F557;
	Tue, 29 Jan 2019 10:49:53 -0800 (PST)
From: James Morse <james.morse@arm.com>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	Borislav Petkov <bp@alien8.de>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>,
	james.morse@arm.com
Subject: [PATCH v8 06/26] ACPI / APEI: Don't store CPER records physical address in struct ghes
Date: Tue, 29 Jan 2019 18:48:42 +0000
Message-Id: <20190129184902.102850-7-james.morse@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190129184902.102850-1-james.morse@arm.com>
References: <20190129184902.102850-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When CPER records are found the address of the records is stashed
in the struct ghes. Once the records have been processed, this
address is overwritten with zero so that it won't be processed
again without being re-populated by firmware.

This goes wrong if a struct ghes can be processed concurrently,
as can happen at probe time when an NMI occurs. If the NMI arrives
on another CPU, the probing CPU may call ghes_clear_estatus() on the
records before the handler had finished with them.
Even on the same CPU, once the interrupted handler is resumed, it
will call ghes_clear_estatus() on the NMIs records, this memory may
have already been re-used by firmware.

Avoid this stashing by letting the caller hold the address. A
later patch will do away with the use of ghes->flags in the
read/clear code too.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Borislav Petkov <bp@suse.de>
---
Changes since v7:
 * Added buf_paddr to ghes_panic, as it wants to print the estatus

Changes since v6:
 * Moved earlier in the series
 * Added buf_adder = 0 on all the error paths, and test for it in
   ghes_estatus_clear() for extra sanity.
---
 drivers/acpi/apei/ghes.c | 46 +++++++++++++++++++++++-----------------
 include/acpi/ghes.h      |  1 -
 2 files changed, 27 insertions(+), 20 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 33144ab0661a..a34f79153b1a 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -305,29 +305,30 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 	}
 }
 
-static int ghes_read_estatus(struct ghes *ghes)
+static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr)
 {
 	struct acpi_hest_generic *g = ghes->generic;
-	u64 buf_paddr;
 	u32 len;
 	int rc;
 
-	rc = apei_read(&buf_paddr, &g->error_status_address);
+	rc = apei_read(buf_paddr, &g->error_status_address);
 	if (rc) {
+		*buf_paddr = 0;
 		pr_warn_ratelimited(FW_WARN GHES_PFX
 "Failed to read error status block address for hardware error source: %d.\n",
 				   g->header.source_id);
 		return -EIO;
 	}
-	if (!buf_paddr)
+	if (!*buf_paddr)
 		return -ENOENT;
 
-	ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
+	ghes_copy_tofrom_phys(ghes->estatus, *buf_paddr,
 			      sizeof(*ghes->estatus), 1);
-	if (!ghes->estatus->block_status)
+	if (!ghes->estatus->block_status) {
+		*buf_paddr = 0;
 		return -ENOENT;
+	}
 
-	ghes->buffer_paddr = buf_paddr;
 	ghes->flags |= GHES_TO_CLEAR;
 
 	rc = -EIO;
@@ -339,7 +340,7 @@ static int ghes_read_estatus(struct ghes *ghes)
 	if (cper_estatus_check_header(ghes->estatus))
 		goto err_read_block;
 	ghes_copy_tofrom_phys(ghes->estatus + 1,
-			      buf_paddr + sizeof(*ghes->estatus),
+			      *buf_paddr + sizeof(*ghes->estatus),
 			      len - sizeof(*ghes->estatus), 1);
 	if (cper_estatus_check(ghes->estatus))
 		goto err_read_block;
@@ -349,15 +350,20 @@ static int ghes_read_estatus(struct ghes *ghes)
 	if (rc)
 		pr_warn_ratelimited(FW_WARN GHES_PFX
 				    "Failed to read error status block!\n");
+
 	return rc;
 }
 
-static void ghes_clear_estatus(struct ghes *ghes)
+static void ghes_clear_estatus(struct ghes *ghes, u64 buf_paddr)
 {
 	ghes->estatus->block_status = 0;
 	if (!(ghes->flags & GHES_TO_CLEAR))
 		return;
-	ghes_copy_tofrom_phys(ghes->estatus, ghes->buffer_paddr,
+
+	if (!buf_paddr)
+		return;
+
+	ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
 			      sizeof(ghes->estatus->block_status), 0);
 	ghes->flags &= ~GHES_TO_CLEAR;
 }
@@ -666,11 +672,11 @@ static int ghes_ack_error(struct acpi_hest_generic_v2 *gv2)
 	return apei_write(val, &gv2->read_ack_register);
 }
 
-static void __ghes_panic(struct ghes *ghes)
+static void __ghes_panic(struct ghes *ghes, u64 buf_paddr)
 {
 	__ghes_print_estatus(KERN_EMERG, ghes->generic, ghes->estatus);
 
-	ghes_clear_estatus(ghes);
+	ghes_clear_estatus(ghes, buf_paddr);
 
 	/* reboot to log the error! */
 	if (!panic_timeout)
@@ -680,14 +686,15 @@ static void __ghes_panic(struct ghes *ghes)
 
 static int ghes_proc(struct ghes *ghes)
 {
+	u64 buf_paddr;
 	int rc;
 
-	rc = ghes_read_estatus(ghes);
+	rc = ghes_read_estatus(ghes, &buf_paddr);
 	if (rc)
 		goto out;
 
 	if (ghes_severity(ghes->estatus->error_severity) >= GHES_SEV_PANIC) {
-		__ghes_panic(ghes);
+		__ghes_panic(ghes, buf_paddr);
 	}
 
 	if (!ghes_estatus_cached(ghes->estatus)) {
@@ -697,7 +704,7 @@ static int ghes_proc(struct ghes *ghes)
 	ghes_do_proc(ghes, ghes->estatus);
 
 out:
-	ghes_clear_estatus(ghes);
+	ghes_clear_estatus(ghes, buf_paddr);
 
 	if (rc == -ENOENT)
 		return rc;
@@ -912,6 +919,7 @@ static void __process_error(struct ghes *ghes)
 
 static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 {
+	u64 buf_paddr;
 	struct ghes *ghes;
 	int sev, ret = NMI_DONE;
 
@@ -919,8 +927,8 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 		return ret;
 
 	list_for_each_entry_rcu(ghes, &ghes_nmi, list) {
-		if (ghes_read_estatus(ghes)) {
-			ghes_clear_estatus(ghes);
+		if (ghes_read_estatus(ghes, &buf_paddr)) {
+			ghes_clear_estatus(ghes, buf_paddr);
 			continue;
 		} else {
 			ret = NMI_HANDLED;
@@ -929,14 +937,14 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 		sev = ghes_severity(ghes->estatus->error_severity);
 		if (sev >= GHES_SEV_PANIC) {
 			ghes_print_queued_estatus();
-			__ghes_panic(ghes);
+			__ghes_panic(ghes, buf_paddr);
 		}
 
 		if (!(ghes->flags & GHES_TO_CLEAR))
 			continue;
 
 		__process_error(ghes);
-		ghes_clear_estatus(ghes);
+		ghes_clear_estatus(ghes, buf_paddr);
 	}
 
 #ifdef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
diff --git a/include/acpi/ghes.h b/include/acpi/ghes.h
index cd9ee507d860..f82f4a7ddd90 100644
--- a/include/acpi/ghes.h
+++ b/include/acpi/ghes.h
@@ -22,7 +22,6 @@ struct ghes {
 		struct acpi_hest_generic_v2 *generic_v2;
 	};
 	struct acpi_hest_generic_status *estatus;
-	u64 buffer_paddr;
 	unsigned long flags;
 	union {
 		struct list_head list;
-- 
2.20.1

