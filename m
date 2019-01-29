Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38FF2C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEF8220989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEF8220989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77BB38E0003; Tue, 29 Jan 2019 13:50:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 711D48E0017; Tue, 29 Jan 2019 13:50:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 386238E0015; Tue, 29 Jan 2019 13:50:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D019E8E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:36 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e12so8296076edd.16
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cB5Vc/XqlFzwaz7GNJcyfHSezxcsXClhbOckn8nvs0Q=;
        b=cT+5hzeu33B0scNrnddjTFH1Ri3+SXyC3TlB7xwIH/cZTxshnAoMh7evlWwPlxUFJh
         wO4tj1MOsQ/X2L32e6+3Wit7PDmnihcCYTIFKOeQIGr5RJYHQ65+TJtlheZ7nJEvmxk8
         OWxNC5pdm4V+eGtHxE7bbyychV2jsw661ENCF4XhtJhLHGtwD20BqatHOGbH9v0Bc31/
         kUNjDa/ANwnTmxRy9RqeIyvR5ssWttcJm/YQpGKxzl7tKJtINIjibhR/NeOhUObvCQE7
         RIA8umTP41rVlgYR6v4EL+ZyNnRgmFAG5t3wLOs+KO3mlndFA5URZOFI5bCKFGthSoS/
         aZJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukdh+5uIOF8gicDI3bgGEWkdW0dqBefXwJ/UpBtZbmtGCHxR8CWg
	pzRbzO/JzMiD5jj70ZXCnO2rZ4M/SopK0rQD8ilT0Bpt4jUjESFTVdrmRyp5g2Z1DgO7/PMzVVO
	yrAHY4feJ3hDkSAWaTlfULEP2wgXLxACjF7ZjG0ohfsy909Z9HjEUC192ylSGA3kxuQ==
X-Received: by 2002:a50:983a:: with SMTP id g55mr26742169edb.143.1548787836318;
        Tue, 29 Jan 2019 10:50:36 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4q5RE98aTwJ2FeRTRciETQUYshlNcj/dJQ1YfyvqEozoC6ghDqDoXejaxoYhhKAzfV5UBR
X-Received: by 2002:a50:983a:: with SMTP id g55mr26742111edb.143.1548787835331;
        Tue, 29 Jan 2019 10:50:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787835; cv=none;
        d=google.com; s=arc-20160816;
        b=cHnlfuuykly8IouW7kbbR/oqxa49BO32WTc+1w3apP+jJoTXWqUgzB1h5/bnKjFmtV
         5a3CkShl7zFc1FdpjUBpZTe7AbxpTII+DHnkRzXAvHsinasVcJmwOPk7vpw8UcuqJvbb
         xKSEtcCk66xq1tQYxVg853gwNK9J7MJmp/+o9xuANWLFcy3IflVN0mrXc8ip+FqWfHUF
         M81cVzC3tHgSALDsCjogk0r+O6qKygJzEAmAWdF+gpBLpssG62/QGMQCqeo6TSSVGxAV
         sOeq3Y0XpDYlabT8LRLna16IVYaa+T5XNTcSZtGd5RJptspPyk/dRG/O+yEtx9ShVrgD
         Y87w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cB5Vc/XqlFzwaz7GNJcyfHSezxcsXClhbOckn8nvs0Q=;
        b=zUBNlDXPrBfEvyakGox6Jwsx4Jc/7pyrM5GdMFrclwbkKQnNCoboYMuoVL5NSQl7Sr
         HozACsaidNCLKOQMgl0+oa9ubIohk/ujbtOwepJ5k6OMS+8PvPzcsiTfL6MZLFWJGiEX
         Bh+HWQnLnz0zIJmkO2BpuLgmvUOde9RSYYzFvbeOz93VTrv/54Yjs3/hL2f+uGD4Kio9
         MavnH9RvZQ3v/cSGeR4KwKy/qwGNiEx4g4SIZppYMb4O+Yszt72UWWqX3DjsZnXz9w5E
         UGTNfGE1cPEyE09X5Lj7FSlV1J66JoPGgy9sf1dLsqN+ahDaOvSnfLdtdZKSDerI/u+e
         DH4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o11si1360504edv.168.2019.01.29.10.50.34
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:35 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 43C9115AB;
	Tue, 29 Jan 2019 10:50:34 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9741E3F557;
	Tue, 29 Jan 2019 10:50:31 -0800 (PST)
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
Subject: [PATCH v8 19/26] ACPI / APEI: Split ghes_read_estatus() to allow a peek at the CPER length
Date: Tue, 29 Jan 2019 18:48:55 +0000
Message-Id: <20190129184902.102850-20-james.morse@arm.com>
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

ghes_read_estatus() reads the record address, then the record's
header, then performs some sanity checks before reading the
records into the provided estatus buffer.

To provide this estatus buffer the caller must know the size of the
records in advance, or always provide a worst-case sized buffer as
happens today for the non-NMI notifications.

Add a function to peek at the record's header to find the size. This
will let the NMI path allocate the right amount of memory before reading
the records, instead of using the worst-case size, and having to copy
the records.

Split ghes_read_estatus() to create __ghes_peek_estatus() which
returns the address and size of the CPER records.

Signed-off-by: James Morse <james.morse@arm.com>

Changes since v7:
 * Grammar
 * concistent argument ordering

Changes since v6:
 * Additional buf_addr = 0 error handling
 * Moved checking out of peek-estatus
 * Reworded an error message so we can tell them apart
---
 drivers/acpi/apei/ghes.c | 40 +++++++++++++++++++++++++++++-----------
 1 file changed, 29 insertions(+), 11 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 9391fff71344..12375a82fa03 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -317,12 +317,12 @@ int __ghes_check_estatus(struct ghes *ghes,
 	return 0;
 }
 
-static int ghes_read_estatus(struct ghes *ghes,
-			     struct acpi_hest_generic_status *estatus,
-			     u64 *buf_paddr, enum fixed_addresses fixmap_idx)
+/* Read the CPER block, returning its address, and header in estatus. */
+static int __ghes_peek_estatus(struct ghes *ghes,
+			       struct acpi_hest_generic_status *estatus,
+			       u64 *buf_paddr, enum fixed_addresses fixmap_idx)
 {
 	struct acpi_hest_generic *g = ghes->generic;
-	u32 len;
 	int rc;
 
 	rc = apei_read(buf_paddr, &g->error_status_address);
@@ -343,14 +343,14 @@ static int ghes_read_estatus(struct ghes *ghes,
 		return -ENOENT;
 	}
 
-	rc = __ghes_check_estatus(ghes, estatus);
-	if (rc)
-		return rc;
+	return __ghes_check_estatus(ghes, estatus);
+}
 
-	len = cper_estatus_len(estatus);
-	ghes_copy_tofrom_phys(estatus + 1,
-			      *buf_paddr + sizeof(*estatus),
-			      len - sizeof(*estatus), 1, fixmap_idx);
+static int __ghes_read_estatus(struct acpi_hest_generic_status *estatus,
+			       u64 buf_paddr, enum fixed_addresses fixmap_idx,
+			       size_t buf_len)
+{
+	ghes_copy_tofrom_phys(estatus, buf_paddr, buf_len, 1, fixmap_idx);
 	if (cper_estatus_check(estatus)) {
 		pr_warn_ratelimited(FW_WARN GHES_PFX
 				    "Failed to read error status block!\n");
@@ -360,6 +360,24 @@ static int ghes_read_estatus(struct ghes *ghes,
 	return 0;
 }
 
+static int ghes_read_estatus(struct ghes *ghes,
+			     struct acpi_hest_generic_status *estatus,
+			     u64 *buf_paddr, enum fixed_addresses fixmap_idx)
+{
+	int rc;
+
+	rc = __ghes_peek_estatus(ghes, estatus, buf_paddr, fixmap_idx);
+	if (rc)
+		return rc;
+
+	rc = __ghes_check_estatus(ghes, estatus);
+	if (rc)
+		return rc;
+
+	return __ghes_read_estatus(estatus, *buf_paddr, fixmap_idx,
+				   cper_estatus_len(estatus));
+}
+
 static void ghes_clear_estatus(struct ghes *ghes,
 			       struct acpi_hest_generic_status *estatus,
 			       u64 buf_paddr, enum fixed_addresses fixmap_idx)
-- 
2.20.1

