Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74440C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:36:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32DB72082F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:36:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="axViJ2b9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32DB72082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06A4B6B0007; Fri, 29 Mar 2019 04:36:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 017496B0008; Fri, 29 Mar 2019 04:36:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6ED16B000C; Fri, 29 Mar 2019 04:36:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A63796B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 04:36:57 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a90so1226661pla.11
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 01:36:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=l0b0WniSTnG+KNqcDNYZsKuv8WXhdpbpfgthVMuVfIA=;
        b=EClavQ5WZF9ZC+aiNp2WdBj4m9pI2Gq7y8IDojlJeB7y7avmt3r2IjqkREa6Orx+8T
         ppXjdqtju0D20wqnu429e7Mgk7vjOWIfwq3RKn/lUwmAofvDFvdchpOkCffUQVce5VQ0
         rHLcAlrg8uCctnup7Z7DSfUOQGl8pb2AO1Ow3rXFTFPIRck5Z9jZ5LGBOpyu8seWw0ez
         87ctGMypq2+78oYG624h4BMAmFE7/6EW+jXfsWPlL1Hqe49y5aN95aVAV09Mdm7glH2+
         UYHUYUOf9yk2aC6chE62hQ1bOZFRquslhH17pZGErVDroy0ntAdFPj3n/0iy+aysEw4G
         MkoQ==
X-Gm-Message-State: APjAAAVIe07dwC6vDADtN1HGoyZxQmSGWKn/graYbAgoHbeaLDJErZrg
	Ovr9cGsO7+gBM1vW58LFI6i5C2a9FHvyRFaMdGgXd0Dh9WOs09HtdqXdzmcv3DfdFz80hvyw72w
	/4V5BJMED2mis82V8O2cO1NCm4m1mFBvj7xgmb35fw+qLwtKVC4sTQ2Uv4LdURO10Rw==
X-Received: by 2002:a65:50c4:: with SMTP id s4mr3946170pgp.33.1553848617231;
        Fri, 29 Mar 2019 01:36:57 -0700 (PDT)
X-Received: by 2002:a65:50c4:: with SMTP id s4mr3946111pgp.33.1553848616196;
        Fri, 29 Mar 2019 01:36:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553848616; cv=none;
        d=google.com; s=arc-20160816;
        b=aa3TFGkqCml3myhHE/MRREt3bsc6w2I2D0xgzNcBMPI2NQJoCC3us7qF6bFV6LzXPa
         fcCe5YnxbC/mKJkGMl6dD4Ieq2N6YEh0l9eroFvSPQcov0KO08h2YleSWg7hRFkSrHgH
         jpWNUo5KSrz7c3+kJh/REMQzGPEaM1+GzhF0zNtoX6z6O417/e60d3vAQJ6hZoJaWu+h
         CWkuA1hXp5kYmeNx/uVi3zMJX5bzojyUQ1cg3lzQ4cxwGrD2sob6Cb4q1/IXoo0zo7kz
         w/dcONtiCxjEb1IGMFFJ+wZHg4xaWxCRplinhS1VxKyB40iZ56kMGoaiSD/fnjW8c13G
         wYwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=l0b0WniSTnG+KNqcDNYZsKuv8WXhdpbpfgthVMuVfIA=;
        b=KxGqzuWbcqkcYY+jMX1AB4h/UWmOx2vxV9LFkk0Mox2N0gt5cWpcn8BMhabT/3MDrd
         4iGq8C2o4cwK+KRJGiC6P2MxP0A6FpUrN1QQ+OhMuAKHeIEhR6mIyaIPgokAGj0XL+U9
         kguVapmrqDiWP49N5d6xYrUI+h05Pe+OiqZy83y5TZ4RoVd7a9b4T6EufxPlAA+AonTQ
         J+NyKYiH+rISrUR8zcqFJrquydr+yVucy2AEe8Sk2IWem6Du16WhZdwEZIIjIyGLgcsw
         H2ZowqPF6F8n3WcgOybH/pc9nvFkK3Hrd6YEDSCsOymCLJcaWxdrLkKLK1q0lE130ie0
         fJAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=axViJ2b9;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z18sor1526804plo.58.2019.03.29.01.36.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 01:36:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=axViJ2b9;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=l0b0WniSTnG+KNqcDNYZsKuv8WXhdpbpfgthVMuVfIA=;
        b=axViJ2b9pnFeFBKZjWf2JzBZLlyHuvNb7OvBojLq31DECUw5haXNIaM7WmTEwPOZls
         SaryHcfemugn58zQtILFDccpq2SNXSvvKhFDZiH/470uvXMRza7UPNKA1PSARqRx3LG4
         Z9UMcPtAz7WCMidL9IPi87NOeXdFGKop+2lGIDBy2GNbXsJ0r+3buouzgTVPCOv+2+OF
         g1/UENO0U7AiyjxPpmbCy4Pd22QXg9/yS/Q3EgNuKqTMKpmSInHv2BqVNB1QwDNAN+ML
         GPm7Xtp30amckxbcA82bw2mLZEE2hfCl4BxkLFVrWEuoFW/qNdr2tsV9uknUu5bmfiEq
         7t0w==
X-Google-Smtp-Source: APXvYqy6N1FvwAkA58abZFYxacPBOpWzM6n3e9/THO6+TIvGLmq/Gjty2jFeDqzV0km1zg/BgFm/4Q==
X-Received: by 2002:a17:902:8c89:: with SMTP id t9mr37126952plo.265.1553848615943;
        Fri, 29 Mar 2019 01:36:55 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id u14sm1920178pfm.66.2019.03.29.01.36.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 01:36:54 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	vbabka@suse.cz,
	mgorman@techsingularity.net
Cc: akpm@linux-foundation.org,
	linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/compaction: fix missed direct_compaction setting for non-direct compaction
Date: Fri, 29 Mar 2019 16:36:39 +0800
Message-Id: <1553848599-6124-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

direct_compaction is not initialized for kcompactd or manually triggered
compaction (via /proc or /sys).
That may cause unexpected behavior in __compact_finished(), so we should
set direct_compaction to false explicitly for these compactions.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 98f99f4..ba2b711 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2400,13 +2400,12 @@ static void compact_node(int nid)
 		.total_free_scanned = 0,
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
+		.direct_compaction = false,
 		.whole_zone = true,
 		.gfp_mask = GFP_KERNEL,
 	};
 
-
 	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
-
 		zone = &pgdat->node_zones[zoneid];
 		if (!populated_zone(zone))
 			continue;
@@ -2522,8 +2521,10 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		.classzone_idx = pgdat->kcompactd_classzone_idx,
 		.mode = MIGRATE_SYNC_LIGHT,
 		.ignore_skip_hint = false,
+		.direct_compaction = false,
 		.gfp_mask = GFP_KERNEL,
 	};
+
 	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
 							cc.classzone_idx);
 	count_compact_event(KCOMPACTD_WAKE);
-- 
1.8.3.1

