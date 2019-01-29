Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8813DC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46B0720844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46B0720844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EABCB8E0004; Tue, 29 Jan 2019 13:50:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E322C8E0003; Tue, 29 Jan 2019 13:50:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D22778E0004; Tue, 29 Jan 2019 13:50:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD878E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:04 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b7so8302790eda.10
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IaVEJgJnSKvnLaX5eMVFN2DgBpxjFPyX7OIO8GDCklo=;
        b=aCjIYYuE4tjR6RQJY2tNM7oUj+jR7yVo45xdK3qtKFdMGvC9AgFerawgF9Q2ign2iU
         BjATs7I7GRMYj7ruwsCqHHv4+ody5qcXn789A4sBgHKRNuO+jWDGLU9p9BRVCJfX6vOV
         TH/W/C5FM+TdZOFot1jxWgGnpX8fkTfXehSkz/eaiY03UJwDxolIAEplhXcNsO7LvH0J
         zpF37/7cWNStT/N0eMl45555t6Bw6fVmmvK1LKZAZb67FLvWG2hV6xdUrY/tmKq6PHp/
         EFO6SKF/kjI56FzEamQFrAfelqiqIpmrRZ8wM8aR2FJmcyfoMKi4U3Jh0wMve0sBpMJw
         x4XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukdTMW6NPAIVCEAQb4gzQeE6kvWXuX49ppe1LXcvofjMsKz419AT
	AiSI56hWSgqTxtlSJJbWo3AZLi2EEMbFuewTVslI3pYwRP2cCfO7Adjib3K7LOf0B/v93v5/onT
	Ph/sQd9ByZDw6suAUBOm/0aHCOoeBZRc9HIt1DNKJQFr/m/wljs7Shp17fGCLklyy/g==
X-Received: by 2002:a17:906:394e:: with SMTP id g14-v6mr4997240eje.0.1548787803931;
        Tue, 29 Jan 2019 10:50:03 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5JZM5u8M3GM6PYeIx0sDK+7e14r3f2qMZtZtNk3Jd1Ze9WFWEiBfL5CKlEJSSKOfbvRPmk
X-Received: by 2002:a17:906:394e:: with SMTP id g14-v6mr4997192eje.0.1548787802910;
        Tue, 29 Jan 2019 10:50:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787802; cv=none;
        d=google.com; s=arc-20160816;
        b=Bgx/8ZwNpmIMsj1gLbbHS2e5LPSy0B+hqbp/gyDlkKCU8ZF+lI5MyMHtfl/PuGpbsi
         2/Mn0NdNcVsYU4D9L6LQsAnKZj8SDGB2QCeURnPXwDQDyJmsEvakWxi/7VO0+7c04Sk1
         hcFzTn/Ldk45em64i0yTwb5DqCZhfBmUoQuMHFpa/kOagrdH+TU0ti5RmA9lOtp+QaYb
         qhchxtOD9s6xR+qqKMuPVX8vDaoh0M7iSMal454Q8mOVUIJsvQi6pFYor0WmNTCrCjO+
         BOEvTTtkiNlpnuQu9GNNZvxqstxZ+Jdos9o4yV5M87jmUvD03ooIgJUOpcTQcUQsbDO7
         BbOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=IaVEJgJnSKvnLaX5eMVFN2DgBpxjFPyX7OIO8GDCklo=;
        b=ebWs6Ftggf6kVcyBZWbftYRqIVcc6tvfBQ2HJPT1jfUEBlVUaHvYkITEnjhGwbLTOa
         9p18j0ij78jdcFdVQiIIKGQWi04Qf7sadkbwCznlEmVkQdRq24TFYTLHJYO2kcvO/gae
         r9nUpaJTg3hx7ICKqhQWvJSftaVbuPgA518bdytlAQQkqu80ovO0ku//alb50iRo/F6r
         quCTQyLxNgylnkJfNZRTZJ0nyhZWlBUIU3Vr11MWron9m1Usxk4g8DF80PojZ3uvZb0h
         YfO+ul2OtXMFdJEqmWwC/FyVpyHeB3W9nwFMjecnWOb7gZc77o7IKbM/60tCtWXnIhiB
         kASQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d29si333189ejn.154.2019.01.29.10.50.02
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:02 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0A08DA78;
	Tue, 29 Jan 2019 10:50:02 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5CF633F557;
	Tue, 29 Jan 2019 10:49:59 -0800 (PST)
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
Subject: [PATCH v8 08/26] ACPI / APEI: Don't update struct ghes' flags in read/clear estatus
Date: Tue, 29 Jan 2019 18:48:44 +0000
Message-Id: <20190129184902.102850-9-james.morse@arm.com>
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

ghes_read_estatus() sets a flag in struct ghes if the buffer of
CPER records needs to be cleared once the records have been
processed. This flag value is a problem if a struct ghes can be
processed concurrently, as happens at probe time if an NMI arrives
for the same error source. The NMI clears the flag, meaning the
interrupted handler may never do the ghes_estatus_clear() work.

The GHES_TO_CLEAR flags is only set at the same time as
buffer_paddr, which is now owned by the caller and passed to
ghes_clear_estatus(). Use this value as the flag.

A non-zero buf_paddr returned by ghes_read_estatus() means
ghes_clear_estatus() should clear this address. ghes_read_estatus()
already checks for a read of error_status_address being zero,
so CPER records cannot be written here.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Borislav Petkov <bp@suse.de>

--
Changes since v6:
 * Added Boris' RB, then:
 * Moved earlier in the series,
 * Tinkered with the commit message,
 * Always cleared buf_paddr on errors in the previous patch, which was
   previously in here.
---
 drivers/acpi/apei/ghes.c | 5 -----
 include/acpi/ghes.h      | 1 -
 2 files changed, 6 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index c20e1d0947b1..af3c10f47f20 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -329,8 +329,6 @@ static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr)
 		return -ENOENT;
 	}
 
-	ghes->flags |= GHES_TO_CLEAR;
-
 	rc = -EIO;
 	len = cper_estatus_len(ghes->estatus);
 	if (len < sizeof(*ghes->estatus))
@@ -357,15 +355,12 @@ static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr)
 static void ghes_clear_estatus(struct ghes *ghes, u64 buf_paddr)
 {
 	ghes->estatus->block_status = 0;
-	if (!(ghes->flags & GHES_TO_CLEAR))
-		return;
 
 	if (!buf_paddr)
 		return;
 
 	ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
 			      sizeof(ghes->estatus->block_status), 0);
-	ghes->flags &= ~GHES_TO_CLEAR;
 }
 
 static void ghes_handle_memory_failure(struct acpi_hest_generic_data *gdata, int sev)
diff --git a/include/acpi/ghes.h b/include/acpi/ghes.h
index f82f4a7ddd90..e3f1cddb4ac8 100644
--- a/include/acpi/ghes.h
+++ b/include/acpi/ghes.h
@@ -13,7 +13,6 @@
  * estatus: memory buffer for error status block, allocated during
  * HEST parsing.
  */
-#define GHES_TO_CLEAR		0x0001
 #define GHES_EXITING		0x0002
 
 struct ghes {
-- 
2.20.1

