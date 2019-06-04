Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF31DC28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:58:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7E6424E07
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:58:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="mVr5fzjs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7E6424E07
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CE046B000A; Tue,  4 Jun 2019 02:58:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37E146B000C; Tue,  4 Jun 2019 02:58:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26D3D6B000D; Tue,  4 Jun 2019 02:58:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id B14D66B000A
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 02:58:53 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id o20so4186164lfb.13
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 23:58:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=miy+F0UoMi0lHDhsda5tGypnZkgAe9GPxZhd/GwR4u4=;
        b=Uh+Cww4yQa+fBfbh/IubhHwJcqJiK78QfNNh4z2pvA8gIoKsra+cB8weQkB2H0Ediw
         3ka8gW96kC99xt0ehZ2yXjAyYPq7VXum5q3+zzkI5c3AysSwudjDgWalBelcsJyi3rkc
         fiVz0NZRaXWGU485U1iJunyv8J/PUeyRY+bnCRkPHq4s2ZeSBJDhNNnBGhll0uDDNXRh
         2Dacp4aVJUvlxIYeFyQH4gUWsvRhZLQBgeJvWCkn56oLZT+8/gBeIw/LK++4hohGgAN1
         UXmmKTlFlF5f0WIhR1b1zg9R6/GiWtPSakFWHMwwr6xg/u7ruN77hDX1uhDyW54Ix+Qu
         PBPA==
X-Gm-Message-State: APjAAAXZQ3afgRgzoIUOKqai6QO1NRvBjukLSnZDIxnXMjTFoRHliRFd
	1STOs6mhWuq3pqWlrnxxp7XaKm156R2ZxfDqW/5CFkI4Vne7h5U9wR1ViH+cZ9/e8cwak30j6pK
	8X223BEy5LEvm2cGvIqh2L/PXCLDgOJKGTp6xzQe3WaHSqWPOfLgpV66tI33p4NpWig==
X-Received: by 2002:a2e:63d9:: with SMTP id s86mr4427559lje.92.1559631532948;
        Mon, 03 Jun 2019 23:58:52 -0700 (PDT)
X-Received: by 2002:a2e:63d9:: with SMTP id s86mr4427542lje.92.1559631532257;
        Mon, 03 Jun 2019 23:58:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559631532; cv=none;
        d=google.com; s=arc-20160816;
        b=Ex4tSG/kElKF9kikLpY9RrKRa1Ro/JFmIn9d3fc16T+l7QRRewRKo1vdQrAN/BUIqW
         7/6TlMTtlCL9aKekbK0iqp8xClTmrwud3uAHymp5WWyYswF+ielqltwVbg3jxq9OXgg5
         kM6PIva+uewzo7j1otJyTvwCyEvh0tipsCtdWjWK90F5NOsvCf+/YC4/nHjJ4VZVDocD
         NEwjJ60rY6cSfyd/RwZtNhjfpbhxapZhAZ+fcIiHfbGrd+ZpeCTAI8syYfBuEI+U6OHQ
         TJDDEPyPx8ubIkXXHxA4NEu0DrVWL/gtTnlckE/Irb0PwHdt2rhDg5cW3LCSLh1DC+5m
         1j0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=miy+F0UoMi0lHDhsda5tGypnZkgAe9GPxZhd/GwR4u4=;
        b=AffNrNZVsT41UuLS7blq6N6xWyJMq8cZvAkaq4XZu9pilTuR35c74FYLRa9RrGxHrV
         qXB166KTxns+IBRzl54c21Q2dLCVDEHYmQ/ykV/cTuODmJbwYpujzg8S3E9k//7ZQy1a
         KBYxYYhJbjOqUTi86MlD38dBtCG9nouO/wi955cqpdpghhJW5lnyuVZ+C7mgGB7Oxx5m
         QS6jD+B0KPAy3M0yji8GT0t6pDqCXZVg5NxkFoSN1ZQF9ZEXYb7M2OUrYIaRLc1MbI/f
         r1LCFl4mEx2TyKf0rl2LfjLrCovKXn86HxRl24ETd06wnNTFLM8liQ30JszdZ4+EQhTS
         gwIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=mVr5fzjs;
       spf=pass (google.com: domain of anders.roxell@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=anders.roxell@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a5sor9909562ljf.4.2019.06.03.23.58.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 23:58:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of anders.roxell@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=mVr5fzjs;
       spf=pass (google.com: domain of anders.roxell@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=anders.roxell@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=miy+F0UoMi0lHDhsda5tGypnZkgAe9GPxZhd/GwR4u4=;
        b=mVr5fzjsLR1nkrv+kdyuXyQZYPVgVYh780mkZNBtzql5tdvV6xYIXziep7mAHvlpgr
         wgVyucCn9Q+gRs9xdpx5DDJBkgsWgpVO758qfmyjDY+nq/AGEVHSIj6TD8fqoVO6NuB2
         gmN9XNCHZemMWo7MBLZf9LlwZdrVYmZpT4HX/YhK8tgItVFx1+9PVUn4axVECn2cPbiR
         xaZ9JlI8wU4yhQ5NKlasEhRA9N5TlsYY08c9dTH9lwSnisaGNESI7RSrQuR+URHoqolU
         7sWzDFpg5l+yS+IUyV3P5ZwDTQ9RdxIoM9FShhqodspBm7i0OQ2BQQ+n7YVmD1emI5gi
         c3RA==
X-Google-Smtp-Source: APXvYqzs6Jwh4UF70YPDT+9ZM8x2yVImFgcqBfuOAwxH86MX/JoTCM2AAKQTK0oKPr9S/2mco/Dh9Q==
X-Received: by 2002:a2e:9654:: with SMTP id z20mr3491108ljh.52.1559631531818;
        Mon, 03 Jun 2019 23:58:51 -0700 (PDT)
Received: from localhost (c-1c3670d5.07-21-73746f28.bbcust.telenor.se. [213.112.54.28])
        by smtp.gmail.com with ESMTPSA id r11sm2978344ljh.90.2019.06.03.23.58.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 23:58:51 -0700 (PDT)
From: Anders Roxell <anders.roxell@linaro.org>
To: minchan@kernel.org,
	ngupta@vflare.org
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Anders Roxell <anders.roxell@linaro.org>
Subject: [PATCH] zsmalloc: remove unused variable
Date: Tue,  4 Jun 2019 08:58:26 +0200
Message-Id: <20190604065826.26064-1-anders.roxell@linaro.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The variable 'entry' is no longer used and the compiler rightly
complains that it should be removed.

../mm/zsmalloc.c: In function ‘zs_pool_stat_create’:
../mm/zsmalloc.c:648:17: warning: unused variable ‘entry’ [-Wunused-variable]
  struct dentry *entry;
                 ^~~~~

Rework to remove the unused variable.

Fixes: 4268509a36a7 ("zsmalloc: no need to check return value of debugfs_create functions")
Signed-off-by: Anders Roxell <anders.roxell@linaro.org>
---
 mm/zsmalloc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 1347d7922ea2..db09eb3669c5 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -645,8 +645,6 @@ DEFINE_SHOW_ATTRIBUTE(zs_stats_size);
 
 static void zs_pool_stat_create(struct zs_pool *pool, const char *name)
 {
-	struct dentry *entry;
-
 	if (!zs_stat_root) {
 		pr_warn("no root stat dir, not creating <%s> stat dir\n", name);
 		return;
-- 
2.20.1

