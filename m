Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC0A5C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 634DD20844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 634DD20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B260B8E0005; Tue, 29 Jan 2019 13:50:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFFFF8E0003; Tue, 29 Jan 2019 13:50:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 979118E0005; Tue, 29 Jan 2019 13:50:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 36CF78E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:25 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id l45so8325822edb.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XZL3kiVvEBTmTsFpHsmD8zXMGbIAxkgsYweoSP+KAII=;
        b=jXo/vHtpf/EunBjDN1ZCwJ8oznL6dGURfOQXPXo4024JnyhiLyALEwfirYYd4XLlrY
         7bucrzuaryxdTYH+3Fji4TrDIAQuhdBLx+hzEPBw/sqILd4s+l7m4VjfXoh74/Q+v9wc
         rAPAE3Blz7FS24kWutsgo89evuWv9GeLSHzy6qAsf8UvFKyliDvGjsYt5Ia/obN3A+YC
         N5kVZLcTNnVp2aSNPPWTcDcSP+GyK+zCkobljxmrktftX4wpznQMdog6RG84R1yFzgjf
         zeBbKaAeIuvw3mDY4FtNcm3rw6mtUsS1pEL4JuqJQKnYv4uxKPQfu8TQN/HCqKzoqwJ7
         R3xg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukf9kVXHKQikxvvWs4sHHtUjbIEW2QmYjdahon2A91xE4wHZp/MJ
	x76OpD9E9fehdKBDDRS1eU2Aa/YyRYmPJmzao+L5MgOGMQkf/L2Qjlxl4RTm0UP8QDOc9WxcLZK
	Q5LF2d/83IpWpUWi377eNA5QME6vvn+6fcnoM+klQrk4V31HdYSrjJ99db8P6Ol4IRw==
X-Received: by 2002:a17:906:b749:: with SMTP id fx9mr6292147ejb.38.1548787824686;
        Tue, 29 Jan 2019 10:50:24 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6vmNWWDRHaGcaUHZETjUywlAhL4dF8nuFQEzzKaqncD2x6uhLU1EFom2hj2g1EH7mC/OoP
X-Received: by 2002:a17:906:b749:: with SMTP id fx9mr6292080ejb.38.1548787823458;
        Tue, 29 Jan 2019 10:50:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787823; cv=none;
        d=google.com; s=arc-20160816;
        b=zcfTQkBCejQMKVAc3w8Eng2HxbyHWHE38TUOXBpE/aWkRaRX0WiFXruLzAxyv/lhNG
         KeK5vz4IcDL0Qh0PnL+8ROhD8dXlywyAnTt8J1wqO64pjPhmMbDpNT6N3do9NUlsfc50
         I63fwONQ7M/q82B0gH6BX9bCQGMR21GNdq6fhxGikTxaEp2Oz3jUb3CXGLdRejq1eoX0
         9EZ0XuMbZD2+eRGvVBjb5/043yb0QVzfemqKnCLs4Pu+hRvxYOUJ8FfVJN5ijydW96yz
         Z4FKjflfaUVajyt2PBJPbE2xsS2w5nkqSGhoaO5Ktq8ZsBei0MPivCCctYHm1iWB3zOv
         vDQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=XZL3kiVvEBTmTsFpHsmD8zXMGbIAxkgsYweoSP+KAII=;
        b=05L35U9Wi/rVSafXQadxOltt3DS3BMZ+rRGZJ9VtKclgr8Z2wlmCP2BaXO2sArm6Nz
         xJPa1H+6Br3ZYtXkit+zaxBDhGVdokaNOkfMoPo4tPPr8iW/S+bT70+OvxBhAS4K982B
         KyrL7XbS5H1D0fJdXcT2ORZ7lTSNCoX8DMgnMTz3utatLuZAigIBy8fNgAtlJYI0S4pa
         eeMlRcm+DzyQJX09/wi+bvFB0ABg0EqqwlycPrEGWiClx0odwM3kxECIBvsr3ACVpYYd
         MLnOXp9IbPTrrUEC5RESaWTQbbvYXpKHZ777J2e2xcKHcBxtdFShCHg8/mEKo23rZSzk
         0Lmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u37si2009610edm.419.2019.01.29.10.50.23
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:23 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 722A61650;
	Tue, 29 Jan 2019 10:50:22 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C530E3F557;
	Tue, 29 Jan 2019 10:50:19 -0800 (PST)
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
Subject: [PATCH v8 15/26] ACPI / APEI: Move locking to the notification helper
Date: Tue, 29 Jan 2019 18:48:51 +0000
Message-Id: <20190129184902.102850-16-james.morse@arm.com>
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

ghes_copy_tofrom_phys() takes different locks depending on in_nmi().
This doesn't work if there are multiple NMI-like notifications, that
can interrupt each other.

Now that NOTIFY_SEA is always called in the same context, move the
lock-taking to the notification helper. The helper will always know
which lock to take. This avoids ghes_copy_tofrom_phys() taking a guess
based on in_nmi().

This splits NOTIFY_NMI and NOTIFY_SEA to use different locks. All
the other notifications use ghes_proc(), and are called in process
or IRQ context. Move the spin_lock_irqsave() around their ghes_proc()
calls.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Borislav Petkov <bp@suse.de>
---

Changes since v7:
 * Moved the locks into the function that uses them to make it clearer this
   is only use in_nmi().

Changes since v6:
 * Tinkered with the commit message
 * Lock definitions have moved due to the #ifdefs
---
 drivers/acpi/apei/ghes.c | 34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index ab794ab29554..c6bc73281d6a 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -114,11 +114,10 @@ static DEFINE_MUTEX(ghes_list_mutex);
  * handler, but general ioremap can not be used in atomic context, so
  * the fixmap is used instead.
  *
- * These 2 spinlocks are used to prevent the fixmap entries from being used
+ * This spinlock is used to prevent the fixmap entry from being used
  * simultaneously.
  */
-static DEFINE_RAW_SPINLOCK(ghes_ioremap_lock_nmi);
-static DEFINE_SPINLOCK(ghes_ioremap_lock_irq);
+static DEFINE_SPINLOCK(ghes_notify_lock_irq);
 
 static struct gen_pool *ghes_estatus_pool;
 static unsigned long ghes_estatus_pool_size_request;
@@ -287,7 +286,6 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 				  int from_phys)
 {
 	void __iomem *vaddr;
-	unsigned long flags = 0;
 	int in_nmi = in_nmi();
 	u64 offset;
 	u32 trunk;
@@ -295,10 +293,8 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 	while (len > 0) {
 		offset = paddr - (paddr & PAGE_MASK);
 		if (in_nmi) {
-			raw_spin_lock(&ghes_ioremap_lock_nmi);
 			vaddr = ghes_ioremap_pfn_nmi(paddr >> PAGE_SHIFT);
 		} else {
-			spin_lock_irqsave(&ghes_ioremap_lock_irq, flags);
 			vaddr = ghes_ioremap_pfn_irq(paddr >> PAGE_SHIFT);
 		}
 		trunk = PAGE_SIZE - offset;
@@ -312,10 +308,8 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 		buffer += trunk;
 		if (in_nmi) {
 			ghes_iounmap_nmi();
-			raw_spin_unlock(&ghes_ioremap_lock_nmi);
 		} else {
 			ghes_iounmap_irq();
-			spin_unlock_irqrestore(&ghes_ioremap_lock_irq, flags);
 		}
 	}
 }
@@ -729,8 +723,11 @@ static void ghes_add_timer(struct ghes *ghes)
 static void ghes_poll_func(struct timer_list *t)
 {
 	struct ghes *ghes = from_timer(ghes, t, timer);
+	unsigned long flags;
 
+	spin_lock_irqsave(&ghes_notify_lock_irq, flags);
 	ghes_proc(ghes);
+	spin_unlock_irqrestore(&ghes_notify_lock_irq, flags);
 	if (!(ghes->flags & GHES_EXITING))
 		ghes_add_timer(ghes);
 }
@@ -738,9 +735,12 @@ static void ghes_poll_func(struct timer_list *t)
 static irqreturn_t ghes_irq_func(int irq, void *data)
 {
 	struct ghes *ghes = data;
+	unsigned long flags;
 	int rc;
 
+	spin_lock_irqsave(&ghes_notify_lock_irq, flags);
 	rc = ghes_proc(ghes);
+	spin_unlock_irqrestore(&ghes_notify_lock_irq, flags);
 	if (rc)
 		return IRQ_NONE;
 
@@ -751,14 +751,17 @@ static int ghes_notify_hed(struct notifier_block *this, unsigned long event,
 			   void *data)
 {
 	struct ghes *ghes;
+	unsigned long flags;
 	int ret = NOTIFY_DONE;
 
+	spin_lock_irqsave(&ghes_notify_lock_irq, flags);
 	rcu_read_lock();
 	list_for_each_entry_rcu(ghes, &ghes_hed, list) {
 		if (!ghes_proc(ghes))
 			ret = NOTIFY_OK;
 	}
 	rcu_read_unlock();
+	spin_unlock_irqrestore(&ghes_notify_lock_irq, flags);
 
 	return ret;
 }
@@ -913,7 +916,14 @@ static LIST_HEAD(ghes_sea);
  */
 int ghes_notify_sea(void)
 {
-	return ghes_in_nmi_spool_from_list(&ghes_sea);
+	static DEFINE_RAW_SPINLOCK(ghes_notify_lock_sea);
+	int rv;
+
+	raw_spin_lock(&ghes_notify_lock_sea);
+	rv = ghes_in_nmi_spool_from_list(&ghes_sea);
+	raw_spin_unlock(&ghes_notify_lock_sea);
+
+	return rv;
 }
 
 static void ghes_sea_add(struct ghes *ghes)
@@ -946,14 +956,17 @@ static LIST_HEAD(ghes_nmi);
 
 static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 {
+	static DEFINE_RAW_SPINLOCK(ghes_notify_lock_nmi);
 	int err, ret = NMI_DONE;
 
 	if (!atomic_add_unless(&ghes_in_nmi, 1, 1))
 		return ret;
 
+	raw_spin_lock(&ghes_notify_lock_nmi);
 	err = ghes_in_nmi_spool_from_list(&ghes_nmi);
 	if (!err)
 		ret = NMI_HANDLED;
+	raw_spin_unlock(&ghes_notify_lock_nmi);
 
 	atomic_dec(&ghes_in_nmi);
 	return ret;
@@ -995,6 +1008,7 @@ static int ghes_probe(struct platform_device *ghes_dev)
 {
 	struct acpi_hest_generic *generic;
 	struct ghes *ghes = NULL;
+	unsigned long flags;
 
 	int rc = -EINVAL;
 
@@ -1097,7 +1111,9 @@ static int ghes_probe(struct platform_device *ghes_dev)
 	ghes_edac_register(ghes, &ghes_dev->dev);
 
 	/* Handle any pending errors right away */
+	spin_lock_irqsave(&ghes_notify_lock_irq, flags);
 	ghes_proc(ghes);
+	spin_unlock_irqrestore(&ghes_notify_lock_irq, flags);
 
 	return 0;
 
-- 
2.20.1

