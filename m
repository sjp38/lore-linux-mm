Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2ECBC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 854AC20844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 854AC20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8405B8E0006; Tue, 29 Jan 2019 13:50:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C8A48E0015; Tue, 29 Jan 2019 13:50:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DEC88E0006; Tue, 29 Jan 2019 13:50:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1017C8E0015
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:49 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b3so8352877edi.0
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cGyWsH8E5iMe5/JM/wndPOtcKX97fv1WfR21Y9tGLcE=;
        b=D/E2m/BmxoK90R+YHBqIEI9y50zBb1XykUVbANQrwvOdkeU1PQykmQhXHzoztW9bfk
         DuXCfI9PGtpzBLqVQL7/vFJRDJOWlIiCSA7tzVISWHzoOiGklX4g2Q9Ggny3uCBPx05r
         8LggyhFKOpH2Wrq5li1fn/6u+xxvTzqqeW++hFWY6pTp/vqwGz7qhCxg/vVQfCOssF3B
         1rmL/wr24ziw55b9QsweRVDc1hjLfJsGtUnpZogBGh/g4Sxg0rOFmjS7Nzns0qmzSTOF
         3m9nyO0llGdnUnUuHKxyeC7UY3moKhqJ0YdZM1G6LZexgtHXEls14CcXrrJJiWcGokUL
         ruBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukcIAYsdGM6C2a88GywGWuNvcdq3b4t9XC+Aa26meTAtURYiMngl
	GcQeNyTowi/N8vLxHQmkMMpia3p2H2vo/z7/bEdCTzY2WVSfKbgJvXIn7FUhM6AccTdhTIcdWw2
	adnpXMzCT1iC1+gO0lFoI/VKDTl3hen96Gczr2DwoAHVFkVYv+DwqRF5YSqB2rYOSDg==
X-Received: by 2002:a50:d797:: with SMTP id w23mr27424729edi.19.1548787848526;
        Tue, 29 Jan 2019 10:50:48 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4rrLs8vdEs+VUvreeQeYqoFsD73eA6iERsY68nzHu0bA4fA3tb0fpOiIsR/FY927pDTNZ9
X-Received: by 2002:a50:d797:: with SMTP id w23mr27424644edi.19.1548787846920;
        Tue, 29 Jan 2019 10:50:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787846; cv=none;
        d=google.com; s=arc-20160816;
        b=DawYX0yIBME5nopyY0S+EZ1JEYgHGhE1qPhm1vs6n8oyVItacqoM0uREc24mFS27FU
         T2oaGpCqoTTwzSWOuABixCZMjXAjzpzz+CjoNSDRjDHt5aI1gEDOWVWZFr82wrLmyOms
         7pDIxtY0SQdYxSrPsJPjTtkdlWNg6c1HK8BhyuL8TWTHj3oGghDQppZr3f7IbojL1qCk
         cAcP2Ysd9QcEOBN4fGntrpMAHkFbBDK2m/D19DdJ/lJen0/w5kGxsc8CH/FtuCCkXW26
         N7JbAb5PmLn//ZyV5ABi+W13/G+eucr5Me5SUXCK1yBliQ9sBhFENiL+gQcjFTYFOa8r
         d5vA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cGyWsH8E5iMe5/JM/wndPOtcKX97fv1WfR21Y9tGLcE=;
        b=d59fO3+N7M3Bgw0BLGJ6/4j0ke3TlupMUVeJ8GAeRrfCDQ8XYNFJxM6h4UbNuw5nxE
         cEjMeBEk87XwKcZ20KnKnaSfZb6eHFCRLK8Gl++o/SNJhQ2nI6VClJ32nPE/ZWQ9Ti6B
         DICUABfynCNcrfPD5xOiAAJFfRlSK29PSqFfm63OVUjHLKsrMCEk3dDzVdHR9arkZ1S6
         bNClMNke2TxQs5+f5RbrMc36J8oF2Ita1ETdeKiTTvc+kseWgHhIjJbxNrOr1c78wR8f
         0AnkBb7QnKib36HyzeCiLsohKK+fmgTv2tGw7rcG/F2b9iWVvCYewTVAa7sSJDmx7Vj/
         x+BQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g41si7684527eda.198.2019.01.29.10.50.46
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:46 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E7D8B15AB;
	Tue, 29 Jan 2019 10:50:45 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 46AB93F557;
	Tue, 29 Jan 2019 10:50:43 -0800 (PST)
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
Subject: [PATCH v8 23/26] ACPI / APEI: Kick the memory_failure() queue for synchronous errors
Date: Tue, 29 Jan 2019 18:48:59 +0000
Message-Id: <20190129184902.102850-24-james.morse@arm.com>
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

memory_failure() offlines or repairs pages of memory that have been
discovered to be corrupt. These may be detected by an external
component, (e.g. the memory controller), and notified via an IRQ.
In this case the work is queued as not all of memory_failure()s work
can happen in IRQ context.

If the error was detected as a result of user-space accessing a
corrupt memory location the CPU may take an abort instead. On arm64
this is a 'synchronous external abort', and on a firmware first
system it is replayed using NOTIFY_SEA.

This notification has NMI like properties, (it can interrupt
IRQ-masked code), so the memory_failure() work is queued. If we
return to user-space before the queued memory_failure() work is
processed, we will take the fault again. This loop may cause platform
firmware to exceed some threshold and reboot when Linux could have
recovered from this error.

For NMIlike notifications keep track of whether memory_failure() work
was queued, and make task_work pending to flush out the queue.
To save memory allocations, the task_work is allocated as part of
the ghes_estatus_node, and free()ing it back to the pool is deferred.

Signed-off-by: James Morse <james.morse@arm.com>

---
current->mm == &init_mm ? I couldn't find a helper for this.
The intent is not to set TIF flags on kernel threads. What happens
if a kernel-thread takes on of these? Its just one of the many
not-handled-very-well cases we have already, as memory_failure()
puts it: "try to be lucky".

I assume that if NOTIFY_NMI is coming from SMM it must suffer from
this problem too.

Changes since v7:
 * Don't allocate memory, stuff it in estatus_node. This means passing
   back a 'queued' flag to ghes_proc_in_irq() which holds the estatus_node.
---
 drivers/acpi/apei/ghes.c | 68 +++++++++++++++++++++++++++++++++-------
 include/acpi/ghes.h      |  3 ++
 2 files changed, 60 insertions(+), 11 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index e6f0d176b245..dfa8f155f964 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -47,6 +47,7 @@
 #include <linux/sched/clock.h>
 #include <linux/uuid.h>
 #include <linux/ras.h>
+#include <linux/task_work.h>
 
 #include <acpi/actbl1.h>
 #include <acpi/ghes.h>
@@ -399,23 +400,46 @@ static void ghes_clear_estatus(struct ghes *ghes,
 		ghes_ack_error(ghes->generic_v2);
 }
 
-static void ghes_handle_memory_failure(struct acpi_hest_generic_data *gdata, int sev)
+/*
+ * Called as task_work before returning to user-space.
+ * Ensure any queued work has been done before we return to the context that
+ * triggered the notification.
+ */
+static void ghes_kick_task_work(struct callback_head *head)
+{
+	struct acpi_hest_generic_status *estatus;
+	struct ghes_estatus_node *estatus_node;
+	u32 node_len;
+
+	estatus_node = container_of(head, struct ghes_estatus_node, task_work);
+	memory_failure_queue_kick(estatus_node->task_work_cpu);
+
+	estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
+	node_len = GHES_ESTATUS_NODE_LEN(cper_estatus_len(estatus));
+	gen_pool_free(ghes_estatus_pool, (unsigned long)estatus_node, node_len);
+}
+
+static bool ghes_handle_memory_failure(struct ghes *ghes,
+				       struct acpi_hest_generic_data *gdata,
+				       int sev)
 {
-#ifdef CONFIG_ACPI_APEI_MEMORY_FAILURE
 	unsigned long pfn;
 	int flags = -1;
 	int sec_sev = ghes_severity(gdata->error_severity);
 	struct cper_sec_mem_err *mem_err = acpi_hest_get_payload(gdata);
 
+	if (!IS_ENABLED(CONFIG_ACPI_APEI_MEMORY_FAILURE))
+		return false;
+
 	if (!(mem_err->validation_bits & CPER_MEM_VALID_PA))
-		return;
+		return false;
 
 	pfn = mem_err->physical_addr >> PAGE_SHIFT;
 	if (!pfn_valid(pfn)) {
 		pr_warn_ratelimited(FW_WARN GHES_PFX
 		"Invalid address in generic error data: %#llx\n",
 		mem_err->physical_addr);
-		return;
+		return false;
 	}
 
 	/* iff following two events can be handled properly by now */
@@ -425,9 +449,12 @@ static void ghes_handle_memory_failure(struct acpi_hest_generic_data *gdata, int
 	if (sev == GHES_SEV_RECOVERABLE && sec_sev == GHES_SEV_RECOVERABLE)
 		flags = 0;
 
-	if (flags != -1)
+	if (flags != -1) {
 		memory_failure_queue(pfn, flags);
-#endif
+		return true;
+	}
+
+	return false;
 }
 
 /*
@@ -475,11 +502,12 @@ static void ghes_handle_aer(struct acpi_hest_generic_data *gdata)
 #endif
 }
 
-static void ghes_do_proc(struct ghes *ghes,
+static bool ghes_do_proc(struct ghes *ghes,
 			 const struct acpi_hest_generic_status *estatus)
 {
 	int sev, sec_sev;
 	struct acpi_hest_generic_data *gdata;
+	bool work_queued = false;
 	guid_t *sec_type;
 	guid_t *fru_id = &NULL_UUID_LE;
 	char *fru_text = "";
@@ -500,7 +528,8 @@ static void ghes_do_proc(struct ghes *ghes,
 			ghes_edac_report_mem_error(sev, mem_err);
 
 			arch_apei_report_mem_error(sev, mem_err);
-			ghes_handle_memory_failure(gdata, sev);
+			if (ghes_handle_memory_failure(ghes, gdata, sev))
+				work_queued = true;
 		}
 		else if (guid_equal(sec_type, &CPER_SEC_PCIE)) {
 			ghes_handle_aer(gdata);
@@ -517,6 +546,8 @@ static void ghes_do_proc(struct ghes *ghes,
 					       gdata->error_data_length);
 		}
 	}
+
+	return work_queued;
 }
 
 static void __ghes_print_estatus(const char *pfx,
@@ -812,7 +843,9 @@ static void ghes_proc_in_irq(struct irq_work *irq_work)
 	struct ghes_estatus_node *estatus_node;
 	struct acpi_hest_generic *generic;
 	struct acpi_hest_generic_status *estatus;
+	bool task_work_pending;
 	u32 len, node_len;
+	int ret;
 
 	llnode = llist_del_all(&ghes_estatus_llist);
 	/*
@@ -827,14 +860,26 @@ static void ghes_proc_in_irq(struct irq_work *irq_work)
 		estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
 		len = cper_estatus_len(estatus);
 		node_len = GHES_ESTATUS_NODE_LEN(len);
-		ghes_do_proc(estatus_node->ghes, estatus);
+		task_work_pending = ghes_do_proc(estatus_node->ghes, estatus);
 		if (!ghes_estatus_cached(estatus)) {
 			generic = estatus_node->generic;
 			if (ghes_print_estatus(NULL, generic, estatus))
 				ghes_estatus_cache_add(generic, estatus);
 		}
-		gen_pool_free(ghes_estatus_pool, (unsigned long)estatus_node,
-			      node_len);
+
+		if (task_work_pending && current->mm != &init_mm) {
+			estatus_node->task_work.func = ghes_kick_task_work;
+			estatus_node->task_work_cpu = smp_processor_id();
+			ret = task_work_add(current, &estatus_node->task_work,
+					    true);
+			if (ret)
+				estatus_node->task_work.func = NULL;
+		}
+
+		if (!estatus_node->task_work.func)
+			gen_pool_free(ghes_estatus_pool,
+				      (unsigned long)estatus_node, node_len);
+
 		llnode = next;
 	}
 }
@@ -894,6 +939,7 @@ static int ghes_in_nmi_queue_one_entry(struct ghes *ghes,
 
 	estatus_node->ghes = ghes;
 	estatus_node->generic = ghes->generic;
+	estatus_node->task_work.func = NULL;
 	estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
 
 	if (__ghes_read_estatus(estatus, buf_paddr, fixmap_idx, len)) {
diff --git a/include/acpi/ghes.h b/include/acpi/ghes.h
index e3f1cddb4ac8..517a5231cc1b 100644
--- a/include/acpi/ghes.h
+++ b/include/acpi/ghes.h
@@ -33,6 +33,9 @@ struct ghes_estatus_node {
 	struct llist_node llnode;
 	struct acpi_hest_generic *generic;
 	struct ghes *ghes;
+
+	int task_work_cpu;
+	struct callback_head task_work;
 };
 
 struct ghes_estatus_cache {
-- 
2.20.1

