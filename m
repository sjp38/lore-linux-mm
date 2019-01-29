Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACBDDC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75E0420844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75E0420844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F27F78E000F; Tue, 29 Jan 2019 13:50:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E84048E0003; Tue, 29 Jan 2019 13:50:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D22CC8E000F; Tue, 29 Jan 2019 13:50:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3578E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:16 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so8358387edd.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KywK7H6KOuId8dTgb/lIe0I83ZQq1HND6cxdnv9EtDY=;
        b=sXDHIOPHSfhZcUx8YI2GSUDi6RrutBn0f73x+6BIZmmhIjewBHz8QIdqB20B0k4CyU
         +nZ75q64nsFmSYqNgRed3k9loPTVtcGspOXSqsmKaWa8ZXdA6MAM14mPFtn7a9gQNgqp
         ZU/+FJmI5iOn92DDg8d2HCx4BcGmPCE7OEyGhTiwfwegnmTkV2Pq5NzyeVwkYfCJr/nv
         M9VzC1KuWQppOSQodKuo4jwqzVq2xa47JiZebgisNUrLDfAUxsdOZt3kLftUSRiuhPB9
         VWeNhP52g2hLt30J/X2ESqHuflJ0s02yDvBzNLfJs2WwZTq0DAH6WRaxtYW1zK7dsKon
         vyQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukf/QxW3LhLRrCeIumFG4hyj3o7/z46y1HTbLKzc/6zViUhzZV+y
	OglLrISRRQ8P0A1aS1gkFTi9Bqx366vN8EBJkqukt4iQFEOY/woFfXuVIUCyyeLLeWDPs7YmhgS
	F3mqcRZnpa+7DV2fQ6SSJL1cPrpVqI7VxXnHqZmAJlcsZbUMJb8ble1gzU1DKKcG/Sg==
X-Received: by 2002:a50:81e3:: with SMTP id 90mr26172860ede.67.1548787815940;
        Tue, 29 Jan 2019 10:50:15 -0800 (PST)
X-Google-Smtp-Source: ALg8bN63wlJqojbXbXrS4B/5x7OtDlsgjh6cms79O7e5H1bhoE8FGlxrBQJ2zA4GXCC8g1p0+TiP
X-Received: by 2002:a50:81e3:: with SMTP id 90mr26172788ede.67.1548787814771;
        Tue, 29 Jan 2019 10:50:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787814; cv=none;
        d=google.com; s=arc-20160816;
        b=YJb4R6ZQVU7m7r8knpELQyh2dMF9UUxW+wMkQ22XLEBWumPoKCCsOeI8tMCsV5qw5x
         myoqKAgKF3bWmUjofAmLu4BjvEx2jla2/gL6jzHBPWju8xceVlMsybvx/BK76VdpaLCS
         eNXu9y7rzsxroPaA3aeV9phzN/E8g8i9nOtV5traD5dxBrkrIDZikcaYt9XyCyVpRAAB
         6mNYrnqWYSm+xVi6VRrh8DAc9Eap6MQ58ljM2CXdzKjphLALOaT66a3NHy/o0U+u+eIh
         Ek4qkahFL5RoGK1RNBymYCljj+ctGoKu4DIh0K9ozK6gtR6MEeBwfp/Qglrj6n2NYkIG
         uuRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=KywK7H6KOuId8dTgb/lIe0I83ZQq1HND6cxdnv9EtDY=;
        b=dfQ3gpb+3j0GesCgGVuIGQvo3+HDfjzAPFIUH26+zbviGh1r8bpHxPScAUg+ghw+Y/
         CJJdf96P8cOqLvXma4vnju4KO5EmFiD/7p77y+ZJnl+fNf06BQbsH7c5goMZrom7pbCG
         7LfRbWLq1MBThbmHFuk5hGdJLB1mVDFd4ub8zqn05oSAcKXbrVJ2l1ZrRdP9KqrOh8cL
         15afKPtSOU5DIhDZ94WuvNIR6V1LtCVPdLbNfXNujag8axShSp1bbf4Zj8Or9Zy7vFI9
         RgcJXKBcnmCKv6PGpgBmrOquusBN8T20w+BBuGvg+adgIK0LSpq11Xyyi35GGuxF7Kfw
         i5EQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n14si1690378edy.344.2019.01.29.10.50.14
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:14 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id ADFF21596;
	Tue, 29 Jan 2019 10:50:13 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0D7D83F557;
	Tue, 29 Jan 2019 10:50:10 -0800 (PST)
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
Subject: [PATCH v8 12/26] ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
Date: Tue, 29 Jan 2019 18:48:48 +0000
Message-Id: <20190129184902.102850-13-james.morse@arm.com>
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

Now that the estatus queue can be used by more than one notification
method, we can move notifications that have NMI-like behaviour over.

Switch NOTIFY_SEA over to use the estatus queue. This makes it behave
in the same way as x86's NOTIFY_NMI.

Remove Kconfig's ability to turn ACPI_APEI_SEA off if ACPI_APEI_GHES
is selected. This roughly matches the x86 NOTIFY_NMI behaviour, and means
each architecture has at least one user of the estatus-queue, meaning it
doesn't need guarding with ifdef.

Signed-off-by: James Morse <james.morse@arm.com>
---
Changes since v6:
 * Lost all the pool grow/shrink stuff,
 * Changed Kconfig so this can't be turned off to avoid kconfig complexity:
 * Dropped Tyler's tested-by.
 * For now we need #ifdef around the SEA code as the arch code assumes its there.
 * Removed Punit's reviewed-by due to the swirling #ifdeffery
---
 drivers/acpi/apei/Kconfig | 12 +-----------
 drivers/acpi/apei/ghes.c  | 22 +++++-----------------
 2 files changed, 6 insertions(+), 28 deletions(-)

diff --git a/drivers/acpi/apei/Kconfig b/drivers/acpi/apei/Kconfig
index 52ae5438edeb..6b18f8bc7be3 100644
--- a/drivers/acpi/apei/Kconfig
+++ b/drivers/acpi/apei/Kconfig
@@ -41,19 +41,9 @@ config ACPI_APEI_PCIEAER
 	  Turn on this option to enable the corresponding support.
 
 config ACPI_APEI_SEA
-	bool "APEI Synchronous External Abort logging/recovering support"
+	bool
 	depends on ARM64 && ACPI_APEI_GHES
 	default y
-	help
-	  This option should be enabled if the system supports
-	  firmware first handling of SEA (Synchronous External Abort).
-	  SEA happens with certain faults of data abort or instruction
-	  abort synchronous exceptions on ARMv8 systems. If a system
-	  supports firmware first handling of SEA, the platform analyzes
-	  and handles hardware error notifications from SEA, and it may then
-	  form a HW error record for the OS to parse and handle. This
-	  option allows the OS to look for such hardware error record, and
-	  take appropriate action.
 
 config ACPI_APEI_MEMORY_FAILURE
 	bool "APEI memory error recovering support"
diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 576dce29159d..ab794ab29554 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -767,7 +767,6 @@ static struct notifier_block ghes_notifier_hed = {
 	.notifier_call = ghes_notify_hed,
 };
 
-#ifdef CONFIG_HAVE_ACPI_APEI_NMI
 /*
  * Handlers for CPER records may not be NMI safe. For example,
  * memory_failure_queue() takes spinlocks and calls schedule_work_on().
@@ -904,7 +903,6 @@ static int ghes_in_nmi_spool_from_list(struct list_head *rcu_list)
 
 	return ret;
 }
-#endif /* CONFIG_HAVE_ACPI_APEI_NMI */
 
 #ifdef CONFIG_ACPI_APEI_SEA
 static LIST_HEAD(ghes_sea);
@@ -915,16 +913,7 @@ static LIST_HEAD(ghes_sea);
  */
 int ghes_notify_sea(void)
 {
-	struct ghes *ghes;
-	int ret = -ENOENT;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(ghes, &ghes_sea, list) {
-		if (!ghes_proc(ghes))
-			ret = 0;
-	}
-	rcu_read_unlock();
-	return ret;
+	return ghes_in_nmi_spool_from_list(&ghes_sea);
 }
 
 static void ghes_sea_add(struct ghes *ghes)
@@ -992,16 +981,15 @@ static void ghes_nmi_remove(struct ghes *ghes)
 	 */
 	synchronize_rcu();
 }
+#else /* CONFIG_HAVE_ACPI_APEI_NMI */
+static inline void ghes_nmi_add(struct ghes *ghes) { }
+static inline void ghes_nmi_remove(struct ghes *ghes) { }
+#endif /* CONFIG_HAVE_ACPI_APEI_NMI */
 
 static void ghes_nmi_init_cxt(void)
 {
 	init_irq_work(&ghes_proc_irq_work, ghes_proc_in_irq);
 }
-#else /* CONFIG_HAVE_ACPI_APEI_NMI */
-static inline void ghes_nmi_add(struct ghes *ghes) { }
-static inline void ghes_nmi_remove(struct ghes *ghes) { }
-static inline void ghes_nmi_init_cxt(void) { }
-#endif /* CONFIG_HAVE_ACPI_APEI_NMI */
 
 static int ghes_probe(struct platform_device *ghes_dev)
 {
-- 
2.20.1

