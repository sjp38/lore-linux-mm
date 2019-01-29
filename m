Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D675BC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 986F820844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 986F820844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE7D28E001A; Tue, 29 Jan 2019 13:50:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9A348E0015; Tue, 29 Jan 2019 13:50:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A88A18E001A; Tue, 29 Jan 2019 13:50:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7928E0015
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:54 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y35so8313977edb.5
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j7b/Tpctf8lj076ai58Sj9p0zuBf66lnA97pNz2XZng=;
        b=Nb9RwbL2DBblkC6Z/UOkohft66oh/TKxyH0EzbFWvj+faLKVZVX228fVg1vuapzjx3
         Nw1fQWEFpjXIalEVyf4FVqS4fywAj6ULifwxXLEJlKepm2I1Rnn64lPPPegDZimW/KBz
         tVto/MjA+vH0JOGZ/liOWne+Vn/6agHPcUnisNA4yB2rpH9oDbHrP/S3O0UQTxX7EwYd
         kf7ZlZtJaqooyTwBQOt15PYk/v/Zpx9XJDk49+Mc6Sre1dKLXbs2RYVSsgFMt8F0zTwg
         QkOHkHcqiY07p0BEn2aRXhOc8vZJ1gPr9iL96kSNLPsM1LmPST8Rj8fsTSSmkLuIeBjA
         hQOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukdB1NYY2DXe6gz+JggkU9B+AuB1mhUr9rfvblebxPu3+OQSHxld
	Swt3aWv/QdXW8H96filhAn35HNrx9pFu6GXRsIf3pmBcJHrcpCGaqr5sUppR/z/jU/N3rF8A+dc
	0HURkuK7xAt5TYLeKuebkkMAo5spHNTFygxK1SH0QG+VvjIYdK9M4poe6OZBCcAPuwg==
X-Received: by 2002:a50:ad0b:: with SMTP id y11mr25790478edc.113.1548787853769;
        Tue, 29 Jan 2019 10:50:53 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7g3BYKVNH+JVXDooe0lu2HcJwucTDG8MbXZuIX+a+07aHRG0R3gWnA4lMTEz3M5vvrnX9h
X-Received: by 2002:a50:ad0b:: with SMTP id y11mr25790430edc.113.1548787852773;
        Tue, 29 Jan 2019 10:50:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787852; cv=none;
        d=google.com; s=arc-20160816;
        b=nHtI68q4AOxd68YK2EkomkmCr5sY1xra25xIzDctrv++GcJqJNJWZohmUKm2AMHeXM
         jVox3iaUEWpOVrNmk02SEWuoP0PDCQoKAd8m7vR6Nj5ZhTI2U3mWPA5B0/5NUAec+YTw
         l2WIcspcdDrlphszG8Qjk3rjnJUxsu6jmugvlyDnaQw2FpCJKzzjfi3CXdyDmzeK7CHo
         8aDPn086NJrq4WmyW5Gh4EHZ36YUisZYD4pBGaRsGi+5zFgXD/mPWpvFr572Z4ZSx4Bu
         NWO28ez1k2zdXkDq6jG5A1duJxCQeveBU2pcxqcq8NoM9wHnIHpe131fjxX1zbZuu7Fk
         1cIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=j7b/Tpctf8lj076ai58Sj9p0zuBf66lnA97pNz2XZng=;
        b=HFdjsnNY6KImGvTrUOL9ZC9lur+2EzXHvMYliWAr/1OmrPgkrX2jMDRICo3YOy+FAA
         rmrWrmASEYL3VCNL+IsNKtNDNzPT4h67+4zjOwFsYFoOn2CBd6GvOc1vy4q/VN7hTfYY
         igF9Wp/EegTy7jdLLtjKUmVeR5FBXFqLn7NQVgB6IkVcQgTDiZKBQBD1F6wIJxRu5Wc3
         X8QdRjcGQeM0sDTYFBfnx8ZE6KsvdYYTM75qIru+mTTmcbJCu82Z5g3LBkFYS8orP4DA
         fyFE9fkx6Xy/Fqf49CqV5l267phN8fdgd6Cf+qFS8Vjycal22o/Ml53nMwZD+2norS15
         Cx/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id mj22si71886ejb.56.2019.01.29.10.50.52
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:52 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BFB9815AB;
	Tue, 29 Jan 2019 10:50:51 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1EBD83F557;
	Tue, 29 Jan 2019 10:50:48 -0800 (PST)
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
Subject: [PATCH v8 25/26] firmware: arm_sdei: Add ACPI GHES registration helper
Date: Tue, 29 Jan 2019 18:49:01 +0000
Message-Id: <20190129184902.102850-26-james.morse@arm.com>
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

APEI's Generic Hardware Error Source structures do not describe
whether the SDEI event is shared or private, as this information is
discoverable via the API.

GHES needs to know whether an event is normal or critical to avoid
sharing locks or fixmap entries, but GHES shouldn't have to know about
the SDEI API.

Add a helper to register the GHES using the appropriate normal or
critical callback.

Signed-off-by: James Morse <james.morse@arm.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>

---
Changes since v4:
 * Moved normal/critical callbacks into the helper, as APEI needs to know.
 * Tinkered with the commit message.
 * Dropped Punit's Reviewed-by.

Changes since v3:
 * Removed acpi_disabled() checks that aren't necessary after v2s #ifdef
   change.

Changes since v2:
 * Added header file, thanks kbuild-robot!
 * changed ifdef to the GHES version to match the fixmap definition

Changes since v1:
 * ghes->fixmap_idx variable rename
---
 arch/arm64/include/asm/fixmap.h |  4 ++
 drivers/firmware/arm_sdei.c     | 68 +++++++++++++++++++++++++++++++++
 include/linux/arm_sdei.h        |  6 +++
 3 files changed, 78 insertions(+)

diff --git a/arch/arm64/include/asm/fixmap.h b/arch/arm64/include/asm/fixmap.h
index 966dd4bb23f2..f987b8a8f325 100644
--- a/arch/arm64/include/asm/fixmap.h
+++ b/arch/arm64/include/asm/fixmap.h
@@ -56,6 +56,10 @@ enum fixed_addresses {
 	/* Used for GHES mapping from assorted contexts */
 	FIX_APEI_GHES_IRQ,
 	FIX_APEI_GHES_SEA,
+#ifdef CONFIG_ARM_SDE_INTERFACE
+	FIX_APEI_GHES_SDEI_NORMAL,
+	FIX_APEI_GHES_SDEI_CRITICAL,
+#endif
 #endif /* CONFIG_ACPI_APEI_GHES */
 
 #ifdef CONFIG_UNMAP_KERNEL_AT_EL0
diff --git a/drivers/firmware/arm_sdei.c b/drivers/firmware/arm_sdei.c
index c64c7da73829..e6376f985ef7 100644
--- a/drivers/firmware/arm_sdei.c
+++ b/drivers/firmware/arm_sdei.c
@@ -2,6 +2,7 @@
 // Copyright (C) 2017 Arm Ltd.
 #define pr_fmt(fmt) "sdei: " fmt
 
+#include <acpi/ghes.h>
 #include <linux/acpi.h>
 #include <linux/arm_sdei.h>
 #include <linux/arm-smccc.h>
@@ -887,6 +888,73 @@ static void sdei_smccc_hvc(unsigned long function_id,
 	arm_smccc_hvc(function_id, arg0, arg1, arg2, arg3, arg4, 0, 0, res);
 }
 
+int sdei_register_ghes(struct ghes *ghes, sdei_event_callback *normal_cb,
+		       sdei_event_callback *critical_cb)
+{
+	int err;
+	u64 result;
+	u32 event_num;
+	sdei_event_callback *cb;
+
+	if (!IS_ENABLED(CONFIG_ACPI_APEI_GHES))
+		return -EOPNOTSUPP;
+
+	event_num = ghes->generic->notify.vector;
+	if (event_num == 0) {
+		/*
+		 * Event 0 is reserved by the specification for
+		 * SDEI_EVENT_SIGNAL.
+		 */
+		return -EINVAL;
+	}
+
+	err = sdei_api_event_get_info(event_num, SDEI_EVENT_INFO_EV_PRIORITY,
+				      &result);
+	if (err)
+		return err;
+
+	if (result == SDEI_EVENT_PRIORITY_CRITICAL)
+		cb = critical_cb;
+	else
+		cb = normal_cb;
+
+	err = sdei_event_register(event_num, cb, ghes);
+	if (!err)
+		err = sdei_event_enable(event_num);
+
+	return err;
+}
+
+int sdei_unregister_ghes(struct ghes *ghes)
+{
+	int i;
+	int err;
+	u32 event_num = ghes->generic->notify.vector;
+
+	might_sleep();
+
+	if (!IS_ENABLED(CONFIG_ACPI_APEI_GHES))
+		return -EOPNOTSUPP;
+
+	/*
+	 * The event may be running on another CPU. Disable it
+	 * to stop new events, then try to unregister a few times.
+	 */
+	err = sdei_event_disable(event_num);
+	if (err)
+		return err;
+
+	for (i = 0; i < 3; i++) {
+		err = sdei_event_unregister(event_num);
+		if (err != -EINPROGRESS)
+			break;
+
+		schedule();
+	}
+
+	return err;
+}
+
 static int sdei_get_conduit(struct platform_device *pdev)
 {
 	const char *method;
diff --git a/include/linux/arm_sdei.h b/include/linux/arm_sdei.h
index 942afbd544b7..393899192906 100644
--- a/include/linux/arm_sdei.h
+++ b/include/linux/arm_sdei.h
@@ -11,6 +11,7 @@ enum sdei_conduit_types {
 	CONDUIT_HVC,
 };
 
+#include <acpi/ghes.h>
 #include <asm/sdei.h>
 
 /* Arch code should override this to set the entry point from firmware... */
@@ -39,6 +40,11 @@ int sdei_event_unregister(u32 event_num);
 int sdei_event_enable(u32 event_num);
 int sdei_event_disable(u32 event_num);
 
+/* GHES register/unregister helpers */
+int sdei_register_ghes(struct ghes *ghes, sdei_event_callback *normal_cb,
+		       sdei_event_callback *critical_cb);
+int sdei_unregister_ghes(struct ghes *ghes);
+
 #ifdef CONFIG_ARM_SDE_INTERFACE
 /* For use by arch code when CPU hotplug notifiers are not appropriate. */
 int sdei_mask_local_cpu(void);
-- 
2.20.1

