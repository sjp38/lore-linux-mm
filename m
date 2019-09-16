Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C1A6C49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:41:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF90D214AF
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:41:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="oSAgnCbh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF90D214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67D156B0005; Mon, 16 Sep 2019 11:41:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62B9B6B0006; Mon, 16 Sep 2019 11:41:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F25C6B0007; Mon, 16 Sep 2019 11:41:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0075.hostedemail.com [216.40.44.75])
	by kanga.kvack.org (Postfix) with ESMTP id 2573D6B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:41:03 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D5BBA180AD802
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:41:02 +0000 (UTC)
X-FDA: 75941197164.19.anger84_434ddf3218756
X-HE-Tag: anger84_434ddf3218756
X-Filterd-Recvd-Size: 3629
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:41:02 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id w2so444324qkf.2
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 08:41:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=2u752yS3oLnDaYH6yTgBbPOp6ynQQ7UEDYNUBRkEYzU=;
        b=oSAgnCbhD4qDdHEm2xKg8gd+frd0gplSiPL7p871e/IbQ3Xl+AoJriMi48+WtFfMiH
         Er7h6Ina/mwJDFGre4pqWP4axz9nWEaIsC0Mhg4jWWlTxJLjxt2PTXBMZIrdR7ueylMQ
         JjnBypKA663HUGsAUZdZa+CJSiDEk7HeQOtW8iN1K2wpYE6VphkL0B7aNMOaXbqeI4fq
         g7hWJaYnXgwqAaotMNT3gfqh6eze7k6/zlkaN/LbASqJE+8AKlLGIYlLCCa69g0youHX
         5nbYx0F2ArTT0i4inpzgu4YzObm7Q/JOwgvXXPrTcIMrcswjP8l3AOMi6LPSITs/lgVR
         ZhFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=2u752yS3oLnDaYH6yTgBbPOp6ynQQ7UEDYNUBRkEYzU=;
        b=untkxP0F+rN8IWSqkThKKo1Lb4LIiLBNeKEB2EPd16XiJ8V1T611W5OLvko3HecR37
         sCpoQ5TS1lc/aLXT/8I9gcL8kubgixtukexyx49B+owbjdhy01kfLzbZkWXA0Fh+um+n
         LRonSKBbyXXp+beuRr+OJ7cglmUMzY2dlT7k/r/kBaaVM9rD340hqbeYSk5FlCKeKCcI
         ABRC83NyU4x2quO6HQDf3jsmBYFQ5NPxcrsHoTTAEySjfi7wJ6EquacyOUa0VrGwbcvA
         MSgGA3wj45rKtHgAY76BZokxD+ZIqH5cVcwdsf2wvKAUGCMTjk1WZjDNIAdRhJMlZYQP
         I3Tg==
X-Gm-Message-State: APjAAAXLWIhrAwxSQvxjNX67EGAI3L3qgm8m8hmvE6I8Hr6/Hf7ithyl
	Ang4U5oF2JcIEskSjzZmnRPdQw==
X-Google-Smtp-Source: APXvYqxNJDHhdXo/lPdcN5eN3wfR3/ruQiO+FQksjwQu3q6+KQ4rkXWYO3AyeTVSdow3GMBnLY3bCg==
X-Received: by 2002:a37:aa02:: with SMTP id t2mr643049qke.154.1568648461865;
        Mon, 16 Sep 2019 08:41:01 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id o28sm3162570qkk.106.2019.09.16.08.41.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Sep 2019 08:41:01 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org,
	mhocko@kernel.org,
	vdavydov.dev@gmail.com,
	cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/memcontrol: fix a -Wunused-function warning
Date: Mon, 16 Sep 2019 11:40:53 -0400
Message-Id: <1568648453-5482-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mem_cgroup_id_get() was introduced in the commit 73f576c04b94
("mm:memcontrol: fix cgroup creation failure after many small jobs").

Later, it no longer has any user since the commits,

1f47b61fb407 ("mm: memcontrol: fix swap counter leak on swapout from offline cgroup")
58fa2a5512d9 ("mm: memcontrol: add sanity checks for memcg->id.ref on get/put")

so safe to remove it.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/memcontrol.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9ec5e12486a7..9a375b376157 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4675,11 +4675,6 @@ static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
 	}
 }
 
-static inline void mem_cgroup_id_get(struct mem_cgroup *memcg)
-{
-	mem_cgroup_id_get_many(memcg, 1);
-}
-
 static inline void mem_cgroup_id_put(struct mem_cgroup *memcg)
 {
 	mem_cgroup_id_put_many(memcg, 1);
-- 
1.8.3.1


