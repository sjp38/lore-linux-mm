Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69A1FC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:28:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25D4820811
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:28:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="nYNHnr2Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25D4820811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4363A8E0005; Wed, 13 Feb 2019 08:28:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3948F8E0001; Wed, 13 Feb 2019 08:28:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E8418E0005; Wed, 13 Feb 2019 08:28:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id B9F068E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:28:39 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id y129so1485963wmd.1
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:28:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SvFSLn76SFJDwEu/S0bVHnKlVxmVyL4jfmZ7pu7W45E=;
        b=H0yakNdNBCeBoGP1ZAhloYijdVYTtvj/eh+VDqAn/uEAvOjYGYbOpwIPYcsbIZOhgf
         YTQkL5BKrwa0VZPp8GtF0SVAucw0A/q0Krau1aLnZJ2pE7UYbDwSM3IIzUk1qNlMBDjH
         wde3tirhMK9OrKNfkHjbTZ6HK9JX6lEMEsHDnP624WE+mQk3/lwGZqqzNaph3XgSqXN4
         kxm9q+jDjZCRwNQf3TQoVdXdx2IivGBq3pH2/qoX/ZvN1aKyK6ZXxs4y6qPLLWjyXiz8
         k5c5B+GgS4NDzqD8bGkBMg2ejnr/wT0sVFiN7Zj97CNggNebsPSwyLgSBUbTJF+tf6l2
         /YNw==
X-Gm-Message-State: AHQUAubRKF14fn4m7gKIGYUh57RxN2mkcTiSMZptBTPeII83Gk2NxwBr
	nzrd+KFsZ19eL4joVvpVXnkb2DriTzxAEmjYnelnu6wMb/EM9IZNms7scTo68/aiYm/HCe84dhn
	wePU24rPTokLgXSFRUTgx/9EPtkRExYPlBislypUtxXoYnFnGldL47weunXb13V2XziGLgCF/Al
	1x0BiuzOmkRjujmQEqarCBfgJ2VS+DNxotjaW0dnIO2jwTQPmilZFNvA60yxiyuL/iD7e9Pdtxo
	iINjNELn6q1zGGm3gnCvv/Cyp9wdXBdPOmMthe2a4CmKOGfKrV6/1WfgRSJke4Ujl4gWWRJtM3D
	C9i5zd2U22NeGHCy+KRk+ya5OFM2HEeqfFQ49ZwPHr8sZosBmScBhfGC/WOsjHi+4BOGCh027SW
	1
X-Received: by 2002:adf:deca:: with SMTP id i10mr402756wrn.312.1550064519290;
        Wed, 13 Feb 2019 05:28:39 -0800 (PST)
X-Received: by 2002:adf:deca:: with SMTP id i10mr402713wrn.312.1550064518451;
        Wed, 13 Feb 2019 05:28:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550064518; cv=none;
        d=google.com; s=arc-20160816;
        b=qvJIhrqd8zkjfcGVM/MZGCTTOqhp0Sy7+0QUNPE/J1OTS2aDK1H8qMUCHJD4gYolEL
         9sJhTzbcYbwtaEjoX2j5mUTiK6vTIJuRzN00ySD20oA6ezXjJLlMoatrdAIzjYTLEFj0
         ZwC/JbTRXT/mQB0NV6EgmEoCDTvdYSxHcWtUJKf52PZR4FHJk2VOttSKC068q5vQoZY7
         ZRJcCg5Au/JISfdeVzPCIAzbVowiF12W7KBLkJ21c6ucJ4askxLK23+HiQF8JMZgIVxr
         autOy5z1uV5e1XCJBBzDvD1izJ3xr28t85/5MK6NMsHWJ3YxqCQXTU0BG4C6Avh5TEaS
         AeVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SvFSLn76SFJDwEu/S0bVHnKlVxmVyL4jfmZ7pu7W45E=;
        b=WExS3ffnbfGaALA9yX1h/LyUOhRLEKOQ3zcmEztHdWfXKOm2RS5MJkt9ZLjCIiP4f+
         CbmGcY+yyIx+PsjPkJFHif0xCJHQXCnIg3s0ybxKFi4dp8x/5tujVv3n2LxkWY8Lp+My
         ZtEWc9PDIFLqSc22N2u8rNjxOFBhupDznQxzHFjYZ4Q7kwFyX2Mf4bCq+QDUf1Yt4X2y
         2QhEgmNbKVoQBM6lS0cdJhRqXybpSPzF+05f9cHeL8LghRMtJTohhtPIYIcDp2U9HKPg
         d8Ii/SoBfaXmVs9mpMurmWgFcbioI5dFS0PAZwohE4B/rZ2YXDS0QJzMumENqA9XcAru
         r+bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=nYNHnr2Z;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g13sor10685034wrq.7.2019.02.13.05.28.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:28:38 -0800 (PST)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=nYNHnr2Z;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=SvFSLn76SFJDwEu/S0bVHnKlVxmVyL4jfmZ7pu7W45E=;
        b=nYNHnr2Zsxh+UaDXNN6yzU0ly6IkH762vDdfRfYhFGRyB9VVEUhGSKXoIhjVWQ29Bt
         l2yS5gAG5bivhvIuH0KftYXcDIWlzChYzt8+KrCFslMDBc9AieVDkLJ84502Gr6BKIUv
         74QqC+GSpz2LRAsaf+0fS+l0UCI4NBnbriNKoblA6yN2j4sTfAZYqAxr7bkQ+Pc6a7z6
         wc6XYmVEWEcK/Yo+ukBHyLnIlHl8bULoeyucuYm8aaN4NS4MdkhKx0wukq6yCP/kZcZL
         2eZLLQzFUC3BFc9hN1aD2HD1GE2dpll2qP3LLEGP6wmqJfLJeYp5NXI0lhY5YG7sV3sb
         Wt7w==
X-Google-Smtp-Source: AHgI3IZVubh1ey1AnRQ8u+x4lnSZlgsf8/ratFtS4LSrAz+twyaMAqm54+WCe3g/zrNVCc7jXNwozg==
X-Received: by 2002:adf:fa0d:: with SMTP id m13mr402593wrr.93.1550064518026;
        Wed, 13 Feb 2019 05:28:38 -0800 (PST)
Received: from localhost.localdomain (aputeaux-684-1-27-200.w90-86.abo.wanadoo.fr. [90.86.252.200])
        by smtp.gmail.com with ESMTPSA id x3sm22841195wrd.19.2019.02.13.05.28.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:28:37 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: linux-efi@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Marc Zyngier <marc.zyngier@arm.com>,
	James Morse <james.morse@arm.com>,
	linux-mm@kvack.org
Subject: [PATCH 2/2] efi/arm: Revert "Defer persistent reservations until after paging_init()"
Date: Wed, 13 Feb 2019 14:27:38 +0100
Message-Id: <20190213132738.10294-3-ard.biesheuvel@linaro.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190213132738.10294-1-ard.biesheuvel@linaro.org>
References: <20190213132738.10294-1-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This reverts commit eff896288872d687d9662000ec9ae11b6d61766f, which
deferred the processing of persistent memory reservations to a point
where the memory may have already been allocated and overwritten,
defeating the purpose.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/kernel/setup.c               | 1 -
 drivers/firmware/efi/efi.c              | 4 ----
 drivers/firmware/efi/libstub/arm-stub.c | 3 ---
 include/linux/efi.h                     | 7 -------
 4 files changed, 15 deletions(-)

diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index 4b0e1231625c..d09ec76f08cf 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -313,7 +313,6 @@ void __init setup_arch(char **cmdline_p)
 	arm64_memblock_init();
 
 	paging_init();
-	efi_apply_persistent_mem_reservations();
 
 	acpi_table_upgrade();
 
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 4c46ff6f2242..55b77c576c42 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -592,11 +592,7 @@ int __init efi_config_parse_tables(void *config_tables, int count, int sz,
 
 		early_memunmap(tbl, sizeof(*tbl));
 	}
-	return 0;
-}
 
-int __init efi_apply_persistent_mem_reservations(void)
-{
 	if (efi.mem_reserve != EFI_INVALID_TABLE_ADDR) {
 		unsigned long prsv = efi.mem_reserve;
 
diff --git a/drivers/firmware/efi/libstub/arm-stub.c b/drivers/firmware/efi/libstub/arm-stub.c
index eee42d5e25ee..c037c6c5d0b7 100644
--- a/drivers/firmware/efi/libstub/arm-stub.c
+++ b/drivers/firmware/efi/libstub/arm-stub.c
@@ -75,9 +75,6 @@ void install_memreserve_table(efi_system_table_t *sys_table_arg)
 	efi_guid_t memreserve_table_guid = LINUX_EFI_MEMRESERVE_TABLE_GUID;
 	efi_status_t status;
 
-	if (IS_ENABLED(CONFIG_ARM))
-		return;
-
 	status = efi_call_early(allocate_pool, EFI_LOADER_DATA, sizeof(*rsv),
 				(void **)&rsv);
 	if (status != EFI_SUCCESS) {
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 45ff763fba76..28604a8d0aa9 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -1198,8 +1198,6 @@ static inline bool efi_enabled(int feature)
 extern void efi_reboot(enum reboot_mode reboot_mode, const char *__unused);
 
 extern bool efi_is_table_address(unsigned long phys_addr);
-
-extern int efi_apply_persistent_mem_reservations(void);
 #else
 static inline bool efi_enabled(int feature)
 {
@@ -1218,11 +1216,6 @@ static inline bool efi_is_table_address(unsigned long phys_addr)
 {
 	return false;
 }
-
-static inline int efi_apply_persistent_mem_reservations(void)
-{
-	return 0;
-}
 #endif
 
 extern int efi_status_to_err(efi_status_t status);
-- 
2.20.1

