Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6651C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 10:46:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C6592087C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 10:46:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QT/kFVEn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C6592087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA32B8E0003; Wed, 13 Mar 2019 06:46:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B28C68E0001; Wed, 13 Mar 2019 06:46:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CAE48E0003; Wed, 13 Mar 2019 06:46:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57CE98E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 06:46:32 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id o67so1654060pfa.20
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 03:46:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=HigmNAvwN2lG22Cmxzs9DLQh5G2dWiqeo/UYc5c1fVw=;
        b=JL5CavFUrThK3rcjTRb4rH0sfhPO66YfKEGTV0qr3F9GQEcPQKLv2Vd8bQ5xFBEkbu
         dXDjZpOFvndDqfYGxKRXRQxjJK1XlUjQYQr2pPoK67qb6iSzwjbtAGnUfmyuos96bMGS
         NoXDKkN/ebo9L4U1jhrWtRPDAOQE7gucgckbm7R30LiP9EnUxXF3vaDL2lW7MKgVyBLz
         nTfrH9mhlsdvSkRN5wTgFbq5tVOV/6izX5f1LQK8Yst3mIUPN7+VgzPl81JfOw7Z+O/w
         mkXuA33RGk8vHkXl0MYuBddySbmRzb+f5S/Vqcnd/C5F7D3JMf34epqx5YmXuBcM4WLT
         oXlA==
X-Gm-Message-State: APjAAAVzjDJXjhvoGNJKRh8aBZdl8hxwTfp+2WKGN4+Y+ON/thlSjXsj
	sTpFf1p66y2LdQ2086fIMezbdoBEiw0tRr4KRgtXheWzV2gY3iwSIfmS1I2Hs3P8oay/mCIv719
	aqtkrMLCDNphiogNbGxO4+l8SGzwjEutwsTI9+MBeSeGanLMKLOyBmlTa/WAQwi0QugSOySPo1V
	m96LabkKv2cb1gmNcKjIonIjCZAsydjyuqsOJsHgMCc2zcHI7bKTb6R28GAj/+JlGkMjGB5MU2h
	u8PFUHAVKp1nSETKCVwIvSYp+OAgxCPBrEwwHUa864DT7ZBaeWX6Mu+UeAOT1AbywOJ+qHy7jA8
	OO7ToA34T8/oxp4UbH0/Iipk2qvb+/bGweW5zNEWC8XdfrSqhX0T2NnYnbgrvING3dTU5LRZdns
	w
X-Received: by 2002:a63:e506:: with SMTP id r6mr15039279pgh.251.1552473991878;
        Wed, 13 Mar 2019 03:46:31 -0700 (PDT)
X-Received: by 2002:a63:e506:: with SMTP id r6mr15039228pgh.251.1552473990958;
        Wed, 13 Mar 2019 03:46:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552473990; cv=none;
        d=google.com; s=arc-20160816;
        b=QsBjYhcq92PJSWuRaGpeh8mdzSDqx4bYcEmgIW6ZSsYOBCcq6Ej+4PzYETy2UPok36
         jCR3BFYUkOaSS1hlqndNr176tasWCkRlmWJWFSpuTXE2QkfSwmb2rHWrEaMEKF3q6rVq
         An+IimUffV3oxGmf17NnH8YpCVCDm6R8tO8KQvScAcZUJXfnaM2C/Okc5vxn9P0MOEpn
         muP47QE7ZkPiBTfZXyiyzFvty17f45HkGvoavamDk2tyIrm//9EvAgM1qNXQxSjzYCjc
         gXVqEukpFLts4c9FJqmcv/7P842leP4iUY4480YcBTF6Mmr5yx5fg58ZnYwcFIqmml9m
         hZvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=HigmNAvwN2lG22Cmxzs9DLQh5G2dWiqeo/UYc5c1fVw=;
        b=GK4iVxCCWs+9nCWTqUfh6xEyIB26Lgd/Cqz5Dt3XODbxfeqICWD4Zn6ORlnj7C3JSK
         4sREfjFcq+lq+/5xE+cxvmIy55QRDA+GUfD1luIJOeDFIFS1mDelKrRULhJ7atFCivXl
         c3t5T4GUecJiRmzF8EStdTk0h6n4oIQwMShzblT3To2l9CxWm1T4N8j67XtTGw5sY2gz
         15+pbTiQ615FCHZEGJMgeBDqKSiQqxuA9L3MRX+qdeKOvFbCFgF9Q7XYmZFszNOcneUY
         tmHASiIUW4SHMWALWDFRWa6Pr4lX5QG1CvPImALA9tcmSzJsinua/9yEQVzyQQIHhU+8
         ej1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="QT/kFVEn";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b27sor17926687pfj.16.2019.03.13.03.46.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 03:46:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="QT/kFVEn";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=HigmNAvwN2lG22Cmxzs9DLQh5G2dWiqeo/UYc5c1fVw=;
        b=QT/kFVEnF5dulh8qknRBTrNOAiKyJtHPFuk24PhBKyPrNx+f9VQNlUGP7I9UTbmNOj
         xAPsHUdhWchLIi29kkNsGQhOLSZEpMhs1BtymC12+6xFCA3PgusH6/nzBzAf8Ky322YQ
         i/43EK+GQ9gRbaS/s2j+T1EF2h2rfJh2xA+vQR747mnwXJGzPyqfJuXKREWX3oWSi1Pu
         9LfhxF2SvDOCsF0HYZk/AUFUX6bnmEkzgWrHGCWDqUWcTMr7sf7Ci/1qA6wGKFJjEIT/
         5rKIiUzX6t8Y+7lfD8ySv7FiPT2F/eQ9Kt/RCG6gbFK0WqxJMSvneClzHqnJrALQMGI4
         e6HQ==
X-Google-Smtp-Source: APXvYqwOxmULa34lP4u7luRS2zvhX9cyBMeE0lBvrrCKLLkfqefSeL+MDmHoVV3w2qkOL5FCTntwEw==
X-Received: by 2002:aa7:885a:: with SMTP id k26mr43322719pfo.70.1552473990638;
        Wed, 13 Mar 2019 03:46:30 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id x23sm40231087pfe.0.2019.03.13.03.46.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 03:46:29 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v2] mm: vmscan: drop zone id from kswapd tracepoints
Date: Wed, 13 Mar 2019 18:45:31 +0800
Message-Id: <1552473931-4808-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000043, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is not clear how is the zone id useful in kswapd tracepoints and the
id itself is not really easy to process because it depends on the
configuration (available zones). Let's drop the id for now. If somebody
really needs that information the zone name should be used instead.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/trace/events/vmscan.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a1cb913..d3f029f 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -73,7 +73,9 @@
 		__entry->order	= order;
 	),
 
-	TP_printk("nid=%d zid=%d order=%d", __entry->nid, __entry->zid, __entry->order)
+	TP_printk("nid=%d order=%d",
+		__entry->nid,
+		__entry->order)
 );
 
 TRACE_EVENT(mm_vmscan_wakeup_kswapd,
@@ -96,9 +98,8 @@
 		__entry->gfp_flags	= gfp_flags;
 	),
 
-	TP_printk("nid=%d zid=%d order=%d gfp_flags=%s",
+	TP_printk("nid=%d order=%d gfp_flags=%s",
 		__entry->nid,
-		__entry->zid,
 		__entry->order,
 		show_gfp_flags(__entry->gfp_flags))
 );
-- 
1.8.3.1

