Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12B4DC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C770C20844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C770C20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF7ED8E0007; Tue, 29 Jan 2019 13:50:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE1E48E0015; Tue, 29 Jan 2019 13:50:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF86F8E0007; Tue, 29 Jan 2019 13:50:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7620A8E0015
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:51 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so8358993edd.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WyX6PHLBF1pqpUWRcbcBKvnw8cl/d1twUs4/cn2oYq0=;
        b=Q0cJ68zVFZc5FIEdSvC/eFOzO1gCdRyFyq/sqLa3BY6NQlZ+EW9vObpSlNmVtJ6x0L
         0IohyGmy8f81IC08nf7QsD0eVksAmZmo57Pwvfciihr2ASNXYnht4W2LsEkEozKPeUbF
         xicPLWKQeIIoDWgyErsL8mYmiANZHAUiXZKU14z7F/JjPbEYNbSfa9Qsx20gCRm/R5br
         mrDpNdw7Wvk7/G/eQkLy2BtXhXUSti+yBs/iwXnZfcz6L06jTSHI0Z6/lcde41lS6MXT
         o7mG4WNtAu7G0GelN+XmqAoN+OIBFv1JeZvY1qDrJNS/zpPxqqbNLHWB/RH8wPK9r62K
         rVvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukfhYCQ6G6qvnDINMFsSdEvXHKypYFteespaSGyDATTJKNq24v3L
	tIzRFdlkuOBj9a4LyE0tWU6ejgvWLei3CGy3KDH7bV2IURSAThmtG2q9ijE0Ma2TcD1vtLj1yvg
	me5xurqKQxW3ghiv8J1vX3PK6KW0g9ES8Wa9KdxBT+yHUDBuRPdrIUV1nDDNt3eTdWg==
X-Received: by 2002:a50:b1af:: with SMTP id m44mr26266492edd.47.1548787850949;
        Tue, 29 Jan 2019 10:50:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN46GU/dcpHLMCmO+QPwYLfcJUv7gDmnQuxZmito0SsRQ6M5NR1PdsX8x2r3mf4+77bz0Ib2
X-Received: by 2002:a50:b1af:: with SMTP id m44mr26266435edd.47.1548787849916;
        Tue, 29 Jan 2019 10:50:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787849; cv=none;
        d=google.com; s=arc-20160816;
        b=RZ9O9Ogt8S7HPs6yFShkyKu9jMROiJrWqjM7IYpafq+/aD/+7SZZgYTwSqc8FgcOFR
         I5weUreNn8zf29HF+pkBipikJpOAIQPRTht/toG1ZjDDeCA1VjljlE/VrsjpqqbU2aTs
         ruLBBNMozE03IVOIxyixA+SS+vjgiFaLKrfeRkxPLdm06KHCp5VX2+fCIeZ7lKQqWfVd
         YmoLP7AyQ13L+N+j2fHZxg4QtyOY4j0E24WCBV0xy8SNPdgabbnARNwBNXKJwKE88N6I
         6QK7Z9Hb/WlyaMsx7PW/2xUhBr+oq/RTaeiJjFP5aXHqYPQssj/Uqt+mAI2SGIRxL85E
         2c9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=WyX6PHLBF1pqpUWRcbcBKvnw8cl/d1twUs4/cn2oYq0=;
        b=r+zkVu/7rQYMNqMJsVZNQXwFtb+gADBSu2Nf001+37pqJKej4qhAOT7SNWl8ajGJYd
         HGcHY/9Jn5qjRj8hGttyLN8cGsocyY88WMyR457Kl/36hhM9n8HerhLxqhjZcaHMZ9W4
         MW1C0c35GdFWzNQjhgbFdBgKItXDzMoWNI4DgPMPzWPYXbrJykVUzQeTmocliTudYm1E
         TR6+B8Ekkr3HFFWKd58zWyIEQZL+VfCLX+u56lfcxI8m0O71oDUWleBunhHIfpxDqgQn
         f9UPu3n+TpoxxL7XUuBxRm251ivDsRXa6ozaUT9/949XR6Jw/r9ndBZgGLZfep67qhvU
         3ERg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j30si2157551edc.365.2019.01.29.10.50.49
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:49 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D427E1650;
	Tue, 29 Jan 2019 10:50:48 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 327F33F557;
	Tue, 29 Jan 2019 10:50:46 -0800 (PST)
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
Subject: [PATCH v8 24/26] arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work
Date: Tue, 29 Jan 2019 18:49:00 +0000
Message-Id: <20190129184902.102850-25-james.morse@arm.com>
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

APEI is unable to do all of its error handling work in nmi-context, so
it defers non-fatal work onto the irq_work queue. arch_irq_work_raise()
sends an IPI to the calling cpu, but this is not guaranteed to be taken
before returning to user-space.

Unless the exception interrupted a context with irqs-masked,
irq_work_run() can run immediately. Otherwise return -EINPROGRESS to
indicate ghes_notify_sea() found some work to do, but it hasn't
finished yet.

With this apei_claim_sea() returning '0' means this external-abort was
also notification of a firmware-first RAS error, and that APEI has
processed the CPER records.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
Tested-by: Tyler Baicar <tbaicar@codeaurora.org>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
CC: Xie XiuQi <xiexiuqi@huawei.com>
CC: gengdongjiu <gengdongjiu@huawei.com>

---
Changes since v7:
 * Added Catalin's ack, then:
 * Added __irq_enter()/exit() calls so if we interrupted preemptible code, the
   preempt count matches what other irq-work expects.
 * Changed the 'if (!arch_irqs_disabled_flags(interrupted_flags))' test to be
   safe before/after Julien's PMR series.

Changes since v6:
 * Added pr_warn() for the EINPROGRESS case so panic-tracebacks show
   'APEI was here'.
 * Tinkered with the commit message

Changes since v2:
 * Removed IS_ENABLED() check, done by the caller unless we have a dummy
   definition.
---
 arch/arm64/kernel/acpi.c | 23 +++++++++++++++++++++++
 arch/arm64/mm/fault.c    |  9 ++++-----
 2 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/kernel/acpi.c b/arch/arm64/kernel/acpi.c
index 803f0494dd3e..8288ae0c8f3b 100644
--- a/arch/arm64/kernel/acpi.c
+++ b/arch/arm64/kernel/acpi.c
@@ -22,6 +22,7 @@
 #include <linux/init.h>
 #include <linux/irq.h>
 #include <linux/irqdomain.h>
+#include <linux/irq_work.h>
 #include <linux/memblock.h>
 #include <linux/of_fdt.h>
 #include <linux/smp.h>
@@ -268,12 +269,17 @@ pgprot_t __acpi_get_mem_attribute(phys_addr_t addr)
 int apei_claim_sea(struct pt_regs *regs)
 {
 	int err = -ENOENT;
+	bool return_to_irqs_enabled;
 	unsigned long current_flags;
 
 	if (!IS_ENABLED(CONFIG_ACPI_APEI_GHES))
 		return err;
 
 	current_flags = arch_local_save_flags();
+	return_to_irqs_enabled = !irqs_disabled_flags(current_flags);
+
+	if (regs)
+		return_to_irqs_enabled = interrupts_enabled(regs);
 
 	/*
 	 * SEA can interrupt SError, mask it and describe this as an NMI so
@@ -283,6 +289,23 @@ int apei_claim_sea(struct pt_regs *regs)
 	nmi_enter();
 	err = ghes_notify_sea();
 	nmi_exit();
+
+	/*
+	 * APEI NMI-like notifications are deferred to irq_work. Unless
+	 * we interrupted irqs-masked code, we can do that now.
+	 */
+	if (!err) {
+		if (return_to_irqs_enabled) {
+			local_daif_restore(DAIF_PROCCTX_NOIRQ);
+			__irq_enter();
+			irq_work_run();
+			__irq_exit();
+		} else {
+			pr_warn("APEI work queued but not completed");
+			err = -EINPROGRESS;
+		}
+	}
+
 	local_daif_restore(current_flags);
 
 	return err;
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index e1c84c2e1cab..1611714f8333 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -642,11 +642,10 @@ static int do_sea(unsigned long addr, unsigned int esr, struct pt_regs *regs)
 
 	inf = esr_to_fault_info(esr);
 
-	/*
-	 * Return value ignored as we rely on signal merging.
-	 * Future patches will make this more robust.
-	 */
-	apei_claim_sea(regs);
+	if (apei_claim_sea(regs) == 0) {
+		/* APEI claimed this as a firmware-first notification */
+		return 0;
+	}
 
 	if (esr & ESR_ELx_FnV)
 		siaddr = NULL;
-- 
2.20.1

