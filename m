Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E42ECC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3BA820844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3BA820844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38BFC8E0017; Tue, 29 Jan 2019 13:50:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 337C18E0015; Tue, 29 Jan 2019 13:50:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 227038E0017; Tue, 29 Jan 2019 13:50:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B35FA8E0015
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:39 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z10so8314133edz.15
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QOY/2hNJALFKKfjWnlCJcXzlT4qedTCy7caAQiFnm7o=;
        b=Ns6punK9vjU1uk3XUOPTB6MJkZ7dpbhj9DG0NSVUU7shbY1luzMRlOtoAqJWAPQeIm
         U7WCThHSDoDoFWKK7YycG6DsBQlyqDoFchIjxAS4az9LriZ3r0lBviuj5Bi+my2mzwcQ
         KHfryjytKsrGczE5Ba5fxyD+ZxztzgBtZDovWPRQXEG9U/p/reRD1G61eT+nDxjwSRH5
         3TEQaKwNbBqb4U1QBujlqKo3cyp3d7747QQqpnISYd4OG/ttTawM3adTD5Z/KfZPYmvJ
         SJrHzJODGPU4nzNleyRtuQ/QqOP6DgWSzERpMu1DIrMmxXcO8csheMdMkUCcgCCif/x8
         skBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukfbdxeFpUVxVMEcvQr+Us35v0u6TtkvRNOyt9HcM3MLMD7TOmEa
	aRz2/FQ0CCvk5wQAsto66x061K3U/viWgBdmurU9vNuD6YfSmGyhlpmNDo4CXYgAX2lDE4kDr0b
	8HxBV0sB01sr2ZDFoNA252/mPrINtm/RyivdibSBRC81fFY1uLhrdGUuxOi+OYjzaMA==
X-Received: by 2002:a50:9315:: with SMTP id m21mr26049245eda.58.1548787839239;
        Tue, 29 Jan 2019 10:50:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5ZxEbhRj1h2YKyVYmo8FdERc4hWsLzhD1/cO6YnBT8gYhOXo0c3jachEJBRUhHjcnKfozq
X-Received: by 2002:a50:9315:: with SMTP id m21mr26049194eda.58.1548787838296;
        Tue, 29 Jan 2019 10:50:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787838; cv=none;
        d=google.com; s=arc-20160816;
        b=mHbhY/ACnWpIoUJXDNfQ+M2Aqi174oKXhXVEW3bWpT4BpGwuMEjmPcJyaPCGPCk+1H
         LWrsLc6umV05bNy2HQugtDjb1h8/ysuCrdejt+V+l0DkbQVgi2X1PiBWZdQbTx0wQ9IP
         BjIVwwIp8LQgWrxX00z++XQFqX+oMf6z3FJDXLFqfw3mwWT60JyPCBQzgqQXwAkFnUS4
         ibUafSLG7f1MPr3ilSg98adm7SBPFWv+M4ZGgyEgQ3oFPSZLpuxMIz9TytpZYPt6aNsK
         uTlA5yZ2k/3KCVFYKMaWDIafNKcuxNH6J94mxucJWZxnWnMosT/6d+TsmH56Q4gkf5bz
         RPdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QOY/2hNJALFKKfjWnlCJcXzlT4qedTCy7caAQiFnm7o=;
        b=t9QtGIe2nYNPHnj7M/XO3vNQ3fuZ0D23dD0YabV8/327pMi3T28YhGsEuhAKEeBJut
         DFCgwt5xQFbjen2dQAqRaaqZm3CVaBkxal/jlEl0tVWHd2io2IZLhuzlRM1bUZ4F7lD6
         0Rr4yBOavas94c3AtBR47koOOIwZhPamowu8K+wZm1RrfUKNAk+WYnjbcPWs5ofjJLvN
         W5XNZfY5T+ZaebzaMJiSr07QhnvL5uHf53gtQ/92fw8HBpod+q505xTg6J4S+HT5BCqQ
         TU4j3vT5ogWWb2xLw1RozVt1/nlXF6xkGsLxHTEEXEpWfBfeciNaiVveIzAy1WqVG/zr
         O0aA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f7si3189875eda.363.2019.01.29.10.50.37
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:38 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2FA8F15AB;
	Tue, 29 Jan 2019 10:50:37 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 827933F557;
	Tue, 29 Jan 2019 10:50:34 -0800 (PST)
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
Subject: [PATCH v8 20/26] ACPI / APEI: Only use queued estatus entry during in_nmi_queue_one_entry()
Date: Tue, 29 Jan 2019 18:48:56 +0000
Message-Id: <20190129184902.102850-21-james.morse@arm.com>
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

Each struct ghes has an worst-case sized buffer for storing the
estatus. If an error is being processed by ghes_proc() in process
context this buffer will be in use. If the error source then triggers
an NMI-like notification, the same buffer will be used by
in_nmi_queue_one_entry() to stage the estatus data, before
__process_error() copys it into a queued estatus entry.

Merge __process_error()s work into in_nmi_queue_one_entry() so that
the queued estatus entry is used from the beginning. Use the new
ghes_peek_estatus() to know how much memory to allocate from
the ghes_estatus_pool before reading the records.

Reported-by: Borislav Petkov <bp@suse.de>
Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Borislav Petkov <bp@suse.de>

Change since v6:
 * Added a comment explaining the 'ack-error, then goto no_work'.
 * Added missing esatus-clearing, which is necessary after reading the GAS,
---
 drivers/acpi/apei/ghes.c | 64 +++++++++++++++++++++++-----------------
 1 file changed, 37 insertions(+), 27 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 12375a82fa03..957c1559ebf5 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -862,57 +862,67 @@ static void ghes_print_queued_estatus(void)
 	}
 }
 
-/* Save estatus for further processing in IRQ context */
-static void __process_error(struct ghes *ghes,
-			    struct acpi_hest_generic_status *src_estatus)
+static int ghes_in_nmi_queue_one_entry(struct ghes *ghes,
+				       enum fixed_addresses fixmap_idx)
 {
-	u32 len, node_len;
+	struct acpi_hest_generic_status *estatus, tmp_header;
 	struct ghes_estatus_node *estatus_node;
-	struct acpi_hest_generic_status *estatus;
+	u32 len, node_len;
+	u64 buf_paddr;
+	int sev, rc;
 
 	if (!IS_ENABLED(CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG))
-		return;
+		return -EOPNOTSUPP;
 
-	if (ghes_estatus_cached(src_estatus))
-		return;
+	rc = __ghes_peek_estatus(ghes, &tmp_header, &buf_paddr, fixmap_idx);
+	if (rc) {
+		ghes_clear_estatus(ghes, &tmp_header, buf_paddr, fixmap_idx);
+		return rc;
+	}
 
-	len = cper_estatus_len(src_estatus);
-	node_len = GHES_ESTATUS_NODE_LEN(len);
+	rc = __ghes_check_estatus(ghes, &tmp_header);
+	if (rc) {
+		ghes_clear_estatus(ghes, &tmp_header, buf_paddr, fixmap_idx);
+		return rc;
+	}
 
+	len = cper_estatus_len(&tmp_header);
+	node_len = GHES_ESTATUS_NODE_LEN(len);
 	estatus_node = (void *)gen_pool_alloc(ghes_estatus_pool, node_len);
 	if (!estatus_node)
-		return;
+		return -ENOMEM;
 
 	estatus_node->ghes = ghes;
 	estatus_node->generic = ghes->generic;
 	estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
-	memcpy(estatus, src_estatus, len);
-	llist_add(&estatus_node->llnode, &ghes_estatus_llist);
-}
 
-static int ghes_in_nmi_queue_one_entry(struct ghes *ghes,
-				       enum fixed_addresses fixmap_idx)
-{
-	struct acpi_hest_generic_status *estatus = ghes->estatus;
-	u64 buf_paddr;
-	int sev;
-
-	if (ghes_read_estatus(ghes, estatus, &buf_paddr, fixmap_idx)) {
+	if (__ghes_read_estatus(estatus, buf_paddr, fixmap_idx, len)) {
 		ghes_clear_estatus(ghes, estatus, buf_paddr, fixmap_idx);
-		return -ENOENT;
+		rc = -ENOENT;
+		goto no_work;
 	}
 
 	sev = ghes_severity(estatus->error_severity);
 	if (sev >= GHES_SEV_PANIC) {
 		ghes_print_queued_estatus();
 		__ghes_panic(ghes, estatus, buf_paddr, fixmap_idx);
-
 	}
 
-	__process_error(ghes, estatus);
-	ghes_clear_estatus(ghes, estatus, buf_paddr, fixmap_idx);
+	ghes_clear_estatus(ghes, &tmp_header, buf_paddr, fixmap_idx);
 
-	return 0;
+	/* This error has been reported before, don't process it again. */
+	if (ghes_estatus_cached(estatus))
+		goto no_work;
+
+	llist_add(&estatus_node->llnode, &ghes_estatus_llist);
+
+	return rc;
+
+no_work:
+	gen_pool_free(ghes_estatus_pool, (unsigned long)estatus_node,
+		      node_len);
+
+	return rc;
 }
 
 static int ghes_in_nmi_spool_from_list(struct list_head *rcu_list,
-- 
2.20.1

