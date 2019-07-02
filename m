Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF292C06513
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 13:02:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7718C208C4
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 13:02:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pw4CVxvB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7718C208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8B696B0005; Tue,  2 Jul 2019 09:02:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D15378E0003; Tue,  2 Jul 2019 09:02:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDC498E0001; Tue,  2 Jul 2019 09:02:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 84EBE6B0005
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 09:02:08 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f18so2996359pgb.10
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 06:02:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id;
        bh=khyDU3y3brXaa9hnvY2oQK5kO8QsNPfjkHRRye2R9w0=;
        b=UOmDlTffmU1kmm5wjyTh9K0+eqD/NcXJpfbtl7KMDp8PaqwuGDMT/TAkyPF+iTW3v8
         YKqefAaJQFoEiE6z3KKrrpV/B3sDlJhxiXxUy9y7LnBnOEui7lNPz0CGdLrC00KmNCJ1
         07l4mO4xM3N+LfdV3XYeu4x0awa/TSaA7KTyZeruPAa8B/ucxSvLY2C0p/8wPSuGAmxO
         YPURygWm/fu6oXv3jdEWnyNOFm9LzyOHDuE7QMrU4LGyipiUzxdbMP4rzkC1WA5F3inq
         5XfRoE+D7Jbs4/pZPCj/j+MJwOt5a71HOgz4TgigcxqhzyeqWNzUDXixcicvtJSPJPSP
         5TTQ==
X-Gm-Message-State: APjAAAVPEm6KhxsbvYMr/Dyt3a1aRPALW+54buX43+O71FyjllMpaXbF
	vdFni6UMyiTXzKoKdIYyK9uUMzG2bLdMdn7eejgWW04aTSsykXin1Rweh2kD7rShHW97DtY7tQt
	1vKaEjMZxeT/7CM/zxJG2TAC3pDzV/8ssAiXkv7IK4G88v5yG2IOrNtERAJQOnB4=
X-Received: by 2002:a17:90a:ac14:: with SMTP id o20mr5591895pjq.114.1562072528078;
        Tue, 02 Jul 2019 06:02:08 -0700 (PDT)
X-Received: by 2002:a17:90a:ac14:: with SMTP id o20mr5591792pjq.114.1562072527122;
        Tue, 02 Jul 2019 06:02:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562072527; cv=none;
        d=google.com; s=arc-20160816;
        b=rrCFw2kqKyOdldKCp+0gC5MmTsbfTZV2T7mfTmWsh0Z7acYqwo50fxxhnZb8/8S5mb
         7OLUP8ovcp3nCBL/GS8j+30cfDWCqpSVoJWu5ZNTj0jimwlDt8lyTMq8XnsnAynyxRwn
         fkhqitX+EIhyMsEAzM/bMvA7gVlEXg3dwciQAu6e+uwDpnl2uDeCarTHE2bVg5WSVcsi
         FEoWI67PYBSBPE1lKMcd5NcXqjC0r103CbZbHESypVt0GiJLdgLEusfLoIpLECZzkeZZ
         FmdaLh/yN6WsTHSGLho6oLEP2zdom3ti6fmPHuqGY5YPaeyELIqBBB7K/hT3V3Mk/exI
         4ohg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=khyDU3y3brXaa9hnvY2oQK5kO8QsNPfjkHRRye2R9w0=;
        b=g8VWNh9nc1D4HYABL5HUv9/tVIuMcJuhWABFtI+PsdCMKaYtFZPA1P/s8NAzN/8A0e
         la5L0cz4zlqd+eHyi1kFARMfIFLZ9rbdbWtejcCMzN4iBxljzWuMuF0PXcmeWZzhLrjM
         2mDLXb/kuIizvV9G/j6Y7LHbjmWnJqtqkVQSscBbTWlv2gOLGrb/t6vJ9b1RLEMig+4p
         b58sfUo56w2xaeF9QmkEuZuksDBZHwi9YhPv3yqE6wSzyURhcyn0SYEKPDZcorkMRjFl
         2N9ueWn59DcklIEzhcfWlt5omT1WMZv/TwbAStAJ9K29yoS6209NYwE4cExeLkMuFsV/
         UGMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pw4CVxvB;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m39sor16043483plg.49.2019.07.02.06.02.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 06:02:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pw4CVxvB;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id;
        bh=khyDU3y3brXaa9hnvY2oQK5kO8QsNPfjkHRRye2R9w0=;
        b=pw4CVxvBDMiI9DQXD67VcLNExsOKGO6Zdy5ZP+qlcS8miUB1MOr0/i+v96aAF6xyFM
         CmT33pBdJkWArwAqk/lsrdmlxAgq9gjOm3ExOQRf3ezYc4KwEC75XoeC3uZL9uMEzzFK
         sw4fO/94cXLyEkjHpEBHeDH9tuW4eSzm567+gvBGpnzwTUlEXuAjjnh48qq/00SgIozW
         9P8TLdZgqvNMB9VodK6G0wU0A0n15/BCL3jEqCgyOD/QmI5xUfPdwA4G4evZQC+pfFxH
         kBX1ye9eVireEvfCwY7gTyNgH94dU2KrCFoXlxQJeePUOaUkFp5fWhyXz6mIUxtB+bkn
         rUVA==
X-Google-Smtp-Source: APXvYqzB1pF/qUqyAlCHdAxDN/p/CNLQWGgTzgY98AvJhwovS+uWV6NhSEOB0TQnHROUBBMuc/ZzeA==
X-Received: by 2002:a17:902:2868:: with SMTP id e95mr32933747plb.319.1562072526735;
        Tue, 02 Jul 2019 06:02:06 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id z22sm10855267pgu.28.2019.07.02.06.02.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 06:02:05 -0700 (PDT)
From: Guenter Roeck <linux@roeck-us.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Robin Murphy <robin.murphy@arm.com>,
	linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next] mm: Mark undo_dev_pagemap as __maybe_unused
Date: Tue,  2 Jul 2019 06:02:03 -0700
Message-Id: <1562072523-22311-1-git-send-email-linux@roeck-us.net>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Several mips builds generate the following build warning.

mm/gup.c:1788:13: warning: 'undo_dev_pagemap' defined but not used

The function is declared unconditionally but only called from behind
various ifdefs. Mark it __maybe_unused.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index 7dde2e3a1963..95a373bd8f21 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1785,7 +1785,8 @@ static inline pte_t gup_get_pte(pte_t *ptep)
 }
 #endif /* CONFIG_GUP_GET_PTE_LOW_HIGH */
 
-static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
+static void __maybe_unused undo_dev_pagemap(int *nr, int nr_start,
+					    struct page **pages)
 {
 	while ((*nr) - nr_start) {
 		struct page *page = pages[--(*nr)];
-- 
2.7.4

