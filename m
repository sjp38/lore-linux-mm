Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45D6AC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB2A8214DA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uYEaYUBO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB2A8214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90AFB8E0197; Mon, 11 Feb 2019 18:28:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BD088E0189; Mon, 11 Feb 2019 18:28:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D0B18E0197; Mon, 11 Feb 2019 18:28:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9138E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:28:26 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id e14so231651wrt.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:28:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=hnmNnr9YQbwfaI93UrUGE24zBu/XKqtY3CcuY5KmkdU=;
        b=qc+4ZrWBhS5lat9N38c7azJGytstjirpRoqoAkq3eMUe0XwK11dw2k1YuOtAk/ybdN
         4Hr1f1TmZ3NlYCcch+7zXtTFB31MrmJcy7GXk/sbocW7Z5oAOrPFUdeTvdzeCtB55CnZ
         cQyko2+5CJ9Z8Wwv3oqvDh32QaACI9IBtX7eUdlnXATyQHrwiawJvD0J71Pt6d0Cmml3
         rh96aCqAE9fe0HPwgg9k3el+ccEJEkLL9X8zYs3KFNMbN2qRFDiYHMyIT5pH/ddH5FOD
         zFoDkL6nln/ngDz3xMqvviG5uCaZaCFFSOm8wxinZVVNdpkJ1RQXG1UemCDVwzs8U4zs
         zL4A==
X-Gm-Message-State: AHQUAuZ6T+cVQULoq2X8Ym0pGOIR7OWptnBri+/uldceAxz+nReEXu13
	3zJbdcXnNt44iKgJ5twMOgc1O0iLrPNjDl3CoNAtvyexuGFNe7pyDr4dt8swv+Jyy3LqZCCVtR9
	JigGcC982zBpDzS1Prg5E9vjHfdCHohW/eOgKFMRRzg/PrHpGHc9sF/sBBF5tkUekWJiYMl6CLa
	j+qmJE+l1cYbt5SpAKXQDzOo9PA41VrYPJSskPlPmMzQA4zrpIW4Lgsc47fFLkUwpUQAn+5n1u3
	CWi6mT12YFSmuKzMEYwwFnaI5TSfEbaKVZR/H2psmxd30g6GyDMcbmnrhGUkMbE7Jc77IiZ6Ikc
	k/Rl/jewgUAcGCRHOgTkFVGK05InMtcQyi+DNXUjr9qAXPDAPbrWUuiyIIL6VXTNQgBGjfRYhqx
	h
X-Received: by 2002:a1c:be09:: with SMTP id o9mr486338wmf.3.1549927705718;
        Mon, 11 Feb 2019 15:28:25 -0800 (PST)
X-Received: by 2002:a1c:be09:: with SMTP id o9mr486290wmf.3.1549927704730;
        Mon, 11 Feb 2019 15:28:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549927704; cv=none;
        d=google.com; s=arc-20160816;
        b=MrvN5JYDmZOUV8Tfgd39fZCLVNOy36aw8w/mvk7DDUZKCZf5mhUhju/BiEddkXvH5+
         8YNtyckCiDTVsm3b0OqNO4bnUl4xMsRxrvgMweyFOJoHKqAO7GKFEkHfZbb/tOQaKk1W
         183LyioC1eqAdXQIWETybhI63oYvwO9k3I4wlV2oXpyQ8lTTyOuRjpCW37Z2LYvTnznz
         nDKezftsLsMn+XJq6en6JlzPsrlnRtLlXljWSHoNI7jJrHVE+Lq3B8/CNxkH2R6rlyg1
         iG0xehEux1N6CfwmS9V2NiIYlINKHDuAEIDNTQ1e1xItNhgv1bTB/b9xU3cEoZmQtBnu
         LSIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=hnmNnr9YQbwfaI93UrUGE24zBu/XKqtY3CcuY5KmkdU=;
        b=EcqWmDmOUgU/8qc6B71BIccjY1frGvyiMmMVUcWkgpxufZebzJzVm8Y3KJfCoCoJXx
         +ZTdFC/pL39NwdeNiW3ylj74q2zABIOGTHJNAofpv9HzD091ANb17qrAsQIp5OVRsU5y
         SCDMnzS7byJzx8a0uugtqhFwo7icP3aHLJGllHX5FcySOrqQXjV5gDuAMtJAYqrMiSWp
         yNUiZmyKsZPLRM7rxDHKot/ochNdpZWrkXGRlS0URe9ebGnA9CV15pHyW1ZIlfF+ZMZl
         xKEbdxGQmkZ4T/IgQi9gJ+YA0LnrShQkWwNmNZYJTi5MvxMKxAKGOFEyU8b29QAIlgiy
         L1Iw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uYEaYUBO;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x3sor7007056wrw.47.2019.02.11.15.28.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 15:28:24 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uYEaYUBO;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=hnmNnr9YQbwfaI93UrUGE24zBu/XKqtY3CcuY5KmkdU=;
        b=uYEaYUBOjZ1m5B6He86ZkAdxBgB6xG90lpl13Gk1Hrdiy2liTU2fpge+1cP7+Qcn6P
         emp1I3cfdW/eFM5ehGcXia7aD5KRIrcUO5KLp3y0d03SJnHlYa9M1Nrk/j9WlOBZd5vM
         NPhVHQ5yjo3jg+IdDZgstra/VE5OEv5TkKDW60i2fCnhn1M3rHve7RRlJI3pwQX0i2oO
         nzXQ3Y1hVyuu7hiWSI6AAJ/iJgoifRyEzUCYAW/WTwTbuJ/c3kKLtIYUUXTTl2s4MABn
         myO9A78iPisLHHaZdLR9c6eEk1EQBlg6qs5wdKYl6B1b1EbFoU++Ygll3gD7Mvu2THwr
         kJMA==
X-Google-Smtp-Source: AHgI3IZ5giTTjGoZ5V4UEH/aAowb6QbzDCVtz5Ak4aVSloW6V3hsGpwN/xytbf9yxR8h2JyjNIwF9Q==
X-Received: by 2002:adf:9f48:: with SMTP id f8mr488678wrg.151.1549927704399;
        Mon, 11 Feb 2019 15:28:24 -0800 (PST)
Received: from localhost.localdomain (bba134232.alshamil.net.ae. [217.165.113.120])
        by smtp.gmail.com with ESMTPSA id e67sm1470295wmg.1.2019.02.11.15.28.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:28:23 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
X-Google-Original-From: Igor Stoppa <igor.stoppa@huawei.com>
To: 
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v4 06/12] __wr_after_init: arm64: enable
Date: Tue, 12 Feb 2019 01:27:43 +0200
Message-Id: <3aa3892bcef3aa8613df74c911c56a3d07599630.1549927666.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1549927666.git.igor.stoppa@huawei.com>
References: <cover.1549927666.git.igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Set ARCH_HAS_PRMEM to Y for arm64

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 arch/arm64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a4168d366127..7cbb2c133ed7 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -66,6 +66,7 @@ config ARM64
 	select ARCH_WANT_COMPAT_IPC_PARSE_VERSION
 	select ARCH_WANT_FRAME_POINTERS
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
+	select ARCH_HAS_PRMEM
 	select ARM_AMBA
 	select ARM_ARCH_TIMER
 	select ARM_GIC
-- 
2.19.1

