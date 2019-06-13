Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72E77C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 13:56:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3376F20896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 13:56:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a6/puSGg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3376F20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAEC26B0008; Thu, 13 Jun 2019 09:56:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A61376B000C; Thu, 13 Jun 2019 09:56:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 951546B000E; Thu, 13 Jun 2019 09:56:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8146B0008
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:56:23 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i26so14498006pfo.22
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:56:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=XCBmCQAGlno7hOelHBvXRdaEhdi1flkwX2MvvNrF9Z8=;
        b=bLKLSl/Fdwz8lAfMYQqpPBX1TDA8WBxVPcPCfvTQULt1cC6VSn87d0XbBwnr3GHgDU
         zmOP3+hVzHyw/PfuXribeSnWqfWnPs2c9/CvDaSdVWn6zB3oAzPADwLr8wYIKHyZAvnM
         PJw35TrIx8e/jdnAsNKeH7D2k/mX4vYT6IlWidLOji+6+U0sC7NP11aS02BjelPc5pXm
         bnWJEI//PA/Qm+wnjW6ccWScADdQNRjYMXD6K0tFJEAjketkTCufQXovvmzpKZgTYYFq
         E2QdMPmgF9WaSUt0Tz5fcp7IwGez4bXSLK38zKInRPondV+enis1qcIyZ4Z5bNtI3nCJ
         WFGA==
X-Gm-Message-State: APjAAAXoaeux9NRsumW6kmPiDrPIu6rQ/Kexpwgrcco0LyhIEM872jdl
	Fwe1EwtC5PGJtDgS77Qw/o7PYpBo7QjXRZeE0nkfa6qJb+L5VPR93iDsitO+IJD6qtttlvtCDsk
	d+j8dhsMZGvaGyH7ETweNl1k1HENGXFzdHCN4VoQSOmTu13VifxSxUcDIbM6oOKE0FQ==
X-Received: by 2002:a17:90a:bf84:: with SMTP id d4mr5693482pjs.124.1560434182870;
        Thu, 13 Jun 2019 06:56:22 -0700 (PDT)
X-Received: by 2002:a17:90a:bf84:: with SMTP id d4mr5693402pjs.124.1560434181672;
        Thu, 13 Jun 2019 06:56:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560434181; cv=none;
        d=google.com; s=arc-20160816;
        b=jT5ky98cIdqOCRKjNDNccTzGFeMD5GkTiqTPULihD8Taku4L6MhRhKiuM60dzp28qq
         ErDX03e8MOHZkEZQDIZGTuRnq+Nr7+vHY1kXOgtNOJTp+b+KuUiMfYKv/YnAIxwRif3g
         Dw4AFZrJLSygbNsHrN9qA9qaX/xuQNCJmSccx+aphCAWIN2ptoPXXNLi8292v3D64cvb
         hPKFmB6tMfw509b2wvN9kb43tJlz5kGb4cN82YGbuHXksEyDML98I1yvKOntd2cG84Ed
         SI0s+JvkFlVYvNlyAbm/h+nNe/Hs9h1oFNnNXL6zm7fthbNiQKMFvCrsBB+LKZQvglYi
         LKEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=XCBmCQAGlno7hOelHBvXRdaEhdi1flkwX2MvvNrF9Z8=;
        b=tJVXFVOyVGGgMLu3Bb10CVe+Un3kyNavLaDv9YGSDQd5iDSMzKZHHabBxOIoW5saFW
         W/cV8GwrFn+qjitJD9oZ72696iYf2xdohMAhVpDi4ERPqFNrgt+WSdHdwEtEXV/BKmV5
         eWLLr5VBGG7KkTTZGxmOGpKAtrS992nlkRMo7cuLlQTgx8sB7fJBNbRe43KtfuaLa8KL
         9jLqcnejtUOU8HmMLY6r1LYNf1NRvuDosPBDACl4FwauLUrImk8EBqkTWBoaP8p1Y8Mh
         DcajWiliVz8NYyD+TrszfUV5QZ98bBIksut+ISo+vQow8Y2yzfdZg/+vbvL1c8sywKGN
         YPqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="a6/puSGg";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 17sor3773182pjh.9.2019.06.13.06.56.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 06:56:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="a6/puSGg";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=XCBmCQAGlno7hOelHBvXRdaEhdi1flkwX2MvvNrF9Z8=;
        b=a6/puSGg3i1VWmxG5l7h8/vz19OEUp0U6dQUyd5lBAHiW3ZDitgUNfN6qammZplu1l
         ch6EzuG5CHc49kVXvZmYfzvIn32FbzwIKQQ4Ime23z6LQcWteZHkARdprq83115+xAYO
         DTnEOJkASzt+uTF/HiBRT5r5PmwzjHl52kqh7fE88kJXrDZ86De7D7bq5hkisDTSJU1W
         SkF9L+CRqQretrCxQcWeLCqtmJPaZbz/WsLdjOVNOQa/gt5SBEduk7IRKVclDdJ1E6z0
         UWD1GiBEnHIxIszABT7TT6gRQJebQq7ztUAmM6lyUL+rj4h37joK0DuvpgrkNJs/lkEX
         aHJA==
X-Google-Smtp-Source: APXvYqxzzbM/MFlLxjuHpmP6KX0axaY9Lafxux16+KzrEoLu+V7QAQzjaab0q/3VX2sULrFg9Mt73w==
X-Received: by 2002:a17:90a:2562:: with SMTP id j89mr5739774pje.123.1560434181187;
        Thu, 13 Jun 2019 06:56:21 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id b15sm2876327pfi.141.2019.06.13.06.56.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 06:56:20 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/oom_kill: set oc->constraint in constrained_alloc()
Date: Thu, 13 Jun 2019 21:55:50 +0800
Message-Id: <1560434150-13626-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In dump_oom_summary() oc->constraint is used to show
oom_constraint_text, but it hasn't been set before.
So the value of it is always the default value 0.
We should set it in constrained_alloc().

Bellow is the output when memcg oom occurs,

before this patch:
[  133.078102] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),
cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=7997,uid=0

after this patch:
[  952.977946] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),
cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=13681,uid=0

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/oom_kill.c | 35 +++++++++++++++++++++++++----------
 1 file changed, 25 insertions(+), 10 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5a58778..075e5cf 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -261,29 +261,37 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 	struct zone *zone;
 	struct zoneref *z;
 	enum zone_type high_zoneidx = gfp_zone(oc->gfp_mask);
+	enum oom_constraint constraint;
 	bool cpuset_limited = false;
 	int nid;
 
 	if (is_memcg_oom(oc)) {
 		oc->totalpages = mem_cgroup_get_max(oc->memcg) ?: 1;
-		return CONSTRAINT_MEMCG;
+		constraint = CONSTRAINT_MEMCG;
+		goto out;
 	}
 
 	/* Default to all available memory */
 	oc->totalpages = totalram_pages() + total_swap_pages;
 
-	if (!IS_ENABLED(CONFIG_NUMA))
-		return CONSTRAINT_NONE;
+	if (!IS_ENABLED(CONFIG_NUMA)) {
+		constraint = CONSTRAINT_NONE;
+		goto out;
+	}
 
-	if (!oc->zonelist)
-		return CONSTRAINT_NONE;
+	if (!oc->zonelist) {
+		constraint = CONSTRAINT_NONE;
+		goto out;
+	}
 	/*
 	 * Reach here only when __GFP_NOFAIL is used. So, we should avoid
 	 * to kill current.We have to random task kill in this case.
 	 * Hopefully, CONSTRAINT_THISNODE...but no way to handle it, now.
 	 */
-	if (oc->gfp_mask & __GFP_THISNODE)
-		return CONSTRAINT_NONE;
+	if (oc->gfp_mask & __GFP_THISNODE) {
+		constraint = CONSTRAINT_NONE;
+		goto out;
+	}
 
 	/*
 	 * This is not a __GFP_THISNODE allocation, so a truncated nodemask in
@@ -295,7 +303,8 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 		oc->totalpages = total_swap_pages;
 		for_each_node_mask(nid, *oc->nodemask)
 			oc->totalpages += node_spanned_pages(nid);
-		return CONSTRAINT_MEMORY_POLICY;
+		constraint = CONSTRAINT_MEMORY_POLICY;
+		goto out;
 	}
 
 	/* Check this allocation failure is caused by cpuset's wall function */
@@ -308,9 +317,15 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 		oc->totalpages = total_swap_pages;
 		for_each_node_mask(nid, cpuset_current_mems_allowed)
 			oc->totalpages += node_spanned_pages(nid);
-		return CONSTRAINT_CPUSET;
+		constraint = CONSTRAINT_CPUSET;
+		goto out;
 	}
-	return CONSTRAINT_NONE;
+
+	constraint = CONSTRAINT_NONE;
+
+out:
+	oc->constraint = constraint;
+	return constraint;
 }
 
 static int oom_evaluate_task(struct task_struct *task, void *arg)
-- 
1.8.3.1

