Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A524AC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:51:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6542220844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:51:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6542220844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFE6B8E001B; Tue, 29 Jan 2019 13:50:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAE0A8E0015; Tue, 29 Jan 2019 13:50:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A11B8E001B; Tue, 29 Jan 2019 13:50:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3618E0015
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:57 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e29so8408095ede.19
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z0mOO2ifhiBIvsjdnVsmHqOe6F85CHxFTHq9HFgxSC0=;
        b=BFIXn3JyJOB4BbhgJAZp1ZWhQrs5f3j7S5tD7CRBkvMm16rYzaNYjS93iKB5loerel
         XWH2qoIDw94RWDd2Sh0oag3XM7F7W3d2KMSjBskAWlLnFZfsQdrU0etq7XWrR5NKXbna
         uxWPpvtuHA+lZIni2dx8EaRjsfn72hsg1cGMf+WpNG+x3+qTZMjCH8I6J1+yx1B1maq7
         WmjAXeC8W6VlNhenm1XHK7W+QAg55MmCue7OxJjqZkT8D/VxsF1PRfU93qfLJ6hZcUSB
         oge3Puv9YesdM19L/pb8NgfVExIPevi/3lxXePnmZul2czHlHrlVPzxOEuE8Y2tkB5VO
         puhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukdGtKd5es2rNNRSE2VOaMcPFDPrKYRzFae9XFkJxV/FrpeELIMn
	LaVuytPlzDdDTZT8hbZXQ+GNPhkNAXnAMKv5vDIZuxTdUqXVkI/yMHLsaOVNmWElg00kK6Armpz
	NKgZzEkFVuY0cBRGVnorNJ9dnYZMgle8S7LxLRbulDOK8MK1FxeUKvEoTgCaNzd81BQ==
X-Received: by 2002:aa7:d1d7:: with SMTP id g23mr22395413edp.217.1548787856699;
        Tue, 29 Jan 2019 10:50:56 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4+SCxCv+v0ciJllZZSt1gizu2FLtH1GhZH9Pqg/UZOJ3D4wAV8BCsNApSveI/K/4xhxZMY
X-Received: by 2002:aa7:d1d7:: with SMTP id g23mr22395352edp.217.1548787855673;
        Tue, 29 Jan 2019 10:50:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787855; cv=none;
        d=google.com; s=arc-20160816;
        b=KbI4qeS5MfyIsnAZ7UW6IhWgeYt4NBRTx7SRDHwdNa9LXqp4+fAZEg+OpY6vq0ycbE
         Ag+JQFjvJ3oe3FBbNzX6QRYF0MjgT0/+Z7TwH12WhrjT5aEfVTwdMAml4scnWtRBhOVM
         +GzAGI/wyIZr1DvaJYWAaImtkOJRDRII79oVh+X+Z1WMlTEtz7JTrulAMARFaWVundjN
         9S8e4BOp1SEJfdx/ssXrIxfl2HylFgieqx6u9+WSc6n4oFe37l4t/uC8cE7KiM22uAlZ
         OaOa9bkw2Mo4zILJNrzvIDkLvqvPzoXA61k9k1sTbECAy2vMlxDyQ4BGG7bLJtRWtrG6
         MaLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Z0mOO2ifhiBIvsjdnVsmHqOe6F85CHxFTHq9HFgxSC0=;
        b=escheT5ppDZ9OlI/HxKePa5okWf2j8fwQmJCwHWeIZC+JXFyn1wEdCNauwbQjgnBwd
         b4MoCVHikcEvRRif4V0U9L0fS2wauBrNL2H1OqJBMuaBlxMunIvHdL6PigQfY4tAmj3g
         3vSOZCx+lIubeiq66DKY9Vra1AdqFeHWcSWNiPHTZAGNMcqxxAHMmlJkmdZHJM3qyIeq
         OTbpPOC/bwnokNZBqQ0BPvtCA19NNqa1qu3PxlMs5VZlBy0nANYejyPKrjFAVN3WP7yM
         n8R6Loc7XUDOaLKBR/fsnBjaXhBKYTTLP/K7OnQTFuHe0gWV1+VPf/Opr+7pgR88lRSb
         CcqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b17si2746782eja.195.2019.01.29.10.50.55
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:55 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AB4FA15BF;
	Tue, 29 Jan 2019 10:50:54 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0A4D13F557;
	Tue, 29 Jan 2019 10:50:51 -0800 (PST)
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
Subject: [PATCH v8 26/26] ACPI / APEI: Add support for the SDEI GHES Notification type
Date: Tue, 29 Jan 2019 18:49:02 +0000
Message-Id: <20190129184902.102850-27-james.morse@arm.com>
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

If the GHES notification type is SDEI, register the provided event
using the SDEI-GHES helper.

SDEI may be one of two types of event, normal and critical. Critical
events can interrupt normal events, so these must have separate
fixmap slots and locks in case both event types are in use.

Signed-off-by: James Morse <james.morse@arm.com>

--
Changes since v7:
 * Use __end_of_fixed_addresses as an arch-agnostic invalid fixmap entry
 * Move the locks definition into the function that uses them to make it
   clear these are NMI only.

Changes since v6:
 * Tinkering due to the absence of #ifdef
 * Added SDEI to the new ghes_is_synchronous() helper.

---
 drivers/acpi/apei/ghes.c | 85 ++++++++++++++++++++++++++++++++++++++++
 include/linux/arm_sdei.h |  3 ++
 2 files changed, 88 insertions(+)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index dfa8f155f964..d0f0a219bf8f 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -25,6 +25,7 @@
  * GNU General Public License for more details.
  */
 
+#include <linux/arm_sdei.h>
 #include <linux/kernel.h>
 #include <linux/moduleparam.h>
 #include <linux/init.h>
@@ -86,6 +87,15 @@
 	((struct acpi_hest_generic_status *)				\
 	 ((struct ghes_estatus_node *)(estatus_node) + 1))
 
+/*
+ *  NMI-like notifications vary by architecture, before the compiler can prune
+ *  unused static functions it needs a value for these enums.
+ */
+#ifndef CONFIG_ARM_SDE_INTERFACE
+#define FIX_APEI_GHES_SDEI_NORMAL	__end_of_fixed_addresses
+#define FIX_APEI_GHES_SDEI_CRITICAL	__end_of_fixed_addresses
+#endif
+
 static inline bool is_hest_type_generic_v2(struct ghes *ghes)
 {
 	return ghes->generic->header.type == ACPI_HEST_TYPE_GENERIC_ERROR_V2;
@@ -1088,6 +1098,63 @@ static void ghes_nmi_init_cxt(void)
 	init_irq_work(&ghes_proc_irq_work, ghes_proc_in_irq);
 }
 
+static int __ghes_sdei_callback(struct ghes *ghes,
+				enum fixed_addresses fixmap_idx)
+{
+	if (!ghes_in_nmi_queue_one_entry(ghes, fixmap_idx)) {
+		irq_work_queue(&ghes_proc_irq_work);
+
+		return 0;
+	}
+
+	return -ENOENT;
+}
+
+static int ghes_sdei_normal_callback(u32 event_num, struct pt_regs *regs,
+				      void *arg)
+{
+	static DEFINE_RAW_SPINLOCK(ghes_notify_lock_sdei_normal);
+	struct ghes *ghes = arg;
+	int err;
+
+	raw_spin_lock(&ghes_notify_lock_sdei_normal);
+	err = __ghes_sdei_callback(ghes, FIX_APEI_GHES_SDEI_NORMAL);
+	raw_spin_unlock(&ghes_notify_lock_sdei_normal);
+
+	return err;
+}
+
+static int ghes_sdei_critical_callback(u32 event_num, struct pt_regs *regs,
+				       void *arg)
+{
+	static DEFINE_RAW_SPINLOCK(ghes_notify_lock_sdei_critical);
+	struct ghes *ghes = arg;
+	int err;
+
+	raw_spin_lock(&ghes_notify_lock_sdei_critical);
+	err = __ghes_sdei_callback(ghes, FIX_APEI_GHES_SDEI_CRITICAL);
+	raw_spin_unlock(&ghes_notify_lock_sdei_critical);
+
+	return err;
+}
+
+static int apei_sdei_register_ghes(struct ghes *ghes)
+{
+	if (!IS_ENABLED(CONFIG_ARM_SDE_INTERFACE))
+		return -EOPNOTSUPP;
+
+	return sdei_register_ghes(ghes, ghes_sdei_normal_callback,
+				 ghes_sdei_critical_callback);
+}
+
+static int apei_sdei_unregister_ghes(struct ghes *ghes)
+{
+	if (!IS_ENABLED(CONFIG_ARM_SDE_INTERFACE))
+		return -EOPNOTSUPP;
+
+	return sdei_unregister_ghes(ghes);
+}
+
 static int ghes_probe(struct platform_device *ghes_dev)
 {
 	struct acpi_hest_generic *generic;
@@ -1123,6 +1190,13 @@ static int ghes_probe(struct platform_device *ghes_dev)
 			goto err;
 		}
 		break;
+	case ACPI_HEST_NOTIFY_SOFTWARE_DELEGATED:
+		if (!IS_ENABLED(CONFIG_ARM_SDE_INTERFACE)) {
+			pr_warn(GHES_PFX "Generic hardware error source: %d notified via SDE Interface is not supported!\n",
+				generic->header.source_id);
+			goto err;
+		}
+		break;
 	case ACPI_HEST_NOTIFY_LOCAL:
 		pr_warning(GHES_PFX "Generic hardware error source: %d notified via local interrupt is not supported!\n",
 			   generic->header.source_id);
@@ -1186,6 +1260,11 @@ static int ghes_probe(struct platform_device *ghes_dev)
 	case ACPI_HEST_NOTIFY_NMI:
 		ghes_nmi_add(ghes);
 		break;
+	case ACPI_HEST_NOTIFY_SOFTWARE_DELEGATED:
+		rc = apei_sdei_register_ghes(ghes);
+		if (rc)
+			goto err;
+		break;
 	default:
 		BUG();
 	}
@@ -1211,6 +1290,7 @@ static int ghes_probe(struct platform_device *ghes_dev)
 
 static int ghes_remove(struct platform_device *ghes_dev)
 {
+	int rc;
 	struct ghes *ghes;
 	struct acpi_hest_generic *generic;
 
@@ -1243,6 +1323,11 @@ static int ghes_remove(struct platform_device *ghes_dev)
 	case ACPI_HEST_NOTIFY_NMI:
 		ghes_nmi_remove(ghes);
 		break;
+	case ACPI_HEST_NOTIFY_SOFTWARE_DELEGATED:
+		rc = apei_sdei_unregister_ghes(ghes);
+		if (rc)
+			return rc;
+		break;
 	default:
 		BUG();
 		break;
diff --git a/include/linux/arm_sdei.h b/include/linux/arm_sdei.h
index 393899192906..3305ea7f9dc7 100644
--- a/include/linux/arm_sdei.h
+++ b/include/linux/arm_sdei.h
@@ -12,7 +12,10 @@ enum sdei_conduit_types {
 };
 
 #include <acpi/ghes.h>
+
+#ifdef CONFIG_ARM_SDE_INTERFACE
 #include <asm/sdei.h>
+#endif
 
 /* Arch code should override this to set the entry point from firmware... */
 #ifndef sdei_arch_get_entry_point
-- 
2.20.1

