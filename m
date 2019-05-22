Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0646BC193F2
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 09:19:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCA9221479
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 09:19:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCA9221479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 376D16B0003; Wed, 22 May 2019 05:19:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 326E46B0006; Wed, 22 May 2019 05:19:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F0276B0007; Wed, 22 May 2019 05:19:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4B196B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 05:19:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 18so2769839eds.5
        for <linux-mm@kvack.org>; Wed, 22 May 2019 02:19:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lMElx65Axj93ye3zkwy7bUqF5kBfrAiHucP2i3h/184=;
        b=FFtdNaFpYF8IzTSGbhMZQVjcPJROx+xNzRiz6fYlWrx2C6vOTDsOWGn8ayAuEHfajh
         p63wPe8MOLMBGYC7Xhk8W77n7sGX5ZC19xgve5ZM6WUhOpjljEkFPnuOsCL733qfREUx
         cryFaz80lpe9sPBvIidmOltr5xaCuKfONRdyEWnjED68NBxJOxkoysJuyzuAJMe7geTm
         fTG91zdVv07hRf3ZiuJu01d7FYm8AU9lB7XuQjihrQ1GNVaQ0RsxeyZrMwa2VhvCOZ8P
         fzrq3W0JO2aPfUWFr+q7srKjtiB43/IMyZYx1pFOcCyRJQpG1ykY7OExkesqllXf77+J
         67Xg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jslaby@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jslaby@suse.cz
X-Gm-Message-State: APjAAAWb05jb8Do+wyhaBiLFFR90BGJ4ZMwrKoD5W+FEgPEVw08xVjTX
	2l9g+7y8gLTHxLWxyAMZ3VKXzv9dhBgnb1qrJg/YB1WzYiv2tK3S3BMpfakK9fLcTXXjwr6tvbv
	bcB9nzldyYWGmUw6zAjHkzph7V0/zMjAqFY4D5Fj7G/nzeS39Lc/VaGbU6eQQNPCDcw==
X-Received: by 2002:a17:906:c44a:: with SMTP id ck10mr41644385ejb.41.1558516784355;
        Wed, 22 May 2019 02:19:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnZ6TBEVS/wCYedl0rtb61WPDPLFLqwBixq8iXhMKq0pPGDHLxmADiQkPK5ZBrEV+/v+RE
X-Received: by 2002:a17:906:c44a:: with SMTP id ck10mr41644318ejb.41.1558516783247;
        Wed, 22 May 2019 02:19:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558516783; cv=none;
        d=google.com; s=arc-20160816;
        b=GtbHl2bBBhcQmOt706EOpvnx8B1QJAhHoL4nFEaSoeBoJIGW+mVToi/bNgl/JtLonX
         nuUU+hxNoPfN4egNgSxX3NzBtq2y/tmRcQbbXl1fYe9WkuWkoWcJKFL9ty0fuzcSrqBV
         g5KrAxrVI3RX4R9jdAkwnxg5rC3aT/Z/oMpdp9I360UC9n9+7QpHuK2Rdbzju5o+Yanf
         UssrftDsGWRbCinY8RLFhu39n3iS4AIOf7RtCR/NMlIcxeer+LOggyQJzwWRlDQwRtf2
         Fel+B+iMe1/w+xpmkxSnVbNvFQ87/T2BzUa5G65Iq7vgGMNPFOt8BuYLFG9b+Igilucd
         gjBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=lMElx65Axj93ye3zkwy7bUqF5kBfrAiHucP2i3h/184=;
        b=oR1YVZuIZbV3dP/2jegfI/hU3cxGQLHmkug7uMBnLbos5FJyBf8yR5AQaPfk29MVvS
         s6s7mCgDW2f5CO+l3bGGX/oxEOzBSOvQfWT2eTmFaWQE/gwf+j6gs4PhXagnYBmsFUwy
         01/5vVezJtpiz21D5XtOZFsqWvoWKDfLUulK8Qvyp1D2sS/krqigjaV+u3a7rbT8Cx9k
         AdNHZmN/zwfCMy0MByRoXpF7fV4Lbqaph+hDEU1U+Np11X8jT1Ze4Cn2kV8neLErVMZs
         kUg/vCMh4yKB/sfKR9bh7eSl1O164h6zrp+f8FaMpHGaJdQ8pPZHU9fXOxicAiAIvL+d
         KU5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jslaby@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jslaby@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b58si6598575edb.218.2019.05.22.02.19.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 02:19:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jslaby@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jslaby@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jslaby@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 843E1ADEC;
	Wed, 22 May 2019 09:19:42 +0000 (UTC)
From: Jiri Slaby <jslaby@suse.cz>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org,
	Jiri Slaby <jslaby@suse.cz>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@suse.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	cgroups@vger.kernel.org,
	stable@vger.kernel.org,
	linux-mm@kvack.org,
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH -resend v2] memcg: make it work on sparse non-0-node systems
Date: Wed, 22 May 2019 11:19:40 +0200
Message-Id: <20190522091940.3615-1-jslaby@suse.cz>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190517114204.6330-1-jslaby@suse.cz>
References: <20190517114204.6330-1-jslaby@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We have a single node system with node 0 disabled:
  Scanning NUMA topology in Northbridge 24
  Number of physical nodes 2
  Skipping disabled node 0
  Node 1 MemBase 0000000000000000 Limit 00000000fbff0000
  NODE_DATA(1) allocated [mem 0xfbfda000-0xfbfeffff]

This causes crashes in memcg when system boots:
  BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
  #PF error: [normal kernel read fault]
...
  RIP: 0010:list_lru_add+0x94/0x170
...
  Call Trace:
   d_lru_add+0x44/0x50
   dput.part.34+0xfc/0x110
   __fput+0x108/0x230
   task_work_run+0x9f/0xc0
   exit_to_usermode_loop+0xf5/0x100

It is reproducible as far as 4.12. I did not try older kernels. You have
to have a new enough systemd, e.g. 241 (the reason is unknown -- was not
investigated). Cannot be reproduced with systemd 234.

The system crashes because the size of lru array is never updated in
memcg_update_all_list_lrus and the reads are past the zero-sized array,
causing dereferences of random memory.

The root cause are list_lru_memcg_aware checks in the list_lru code.
The test in list_lru_memcg_aware is broken: it assumes node 0 is always
present, but it is not true on some systems as can be seen above.

So fix this by avoiding checks on node 0. Remember the memcg-awareness
by a bool flag in struct list_lru.

[v2] use the idea proposed by Vladimir -- the bool flag.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Fixes: 60d3fd32a7a9 ("list_lru: introduce per-memcg lists")
Cc: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Suggested-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Cc: <cgroups@vger.kernel.org>
Cc: <stable@vger.kernel.org>
Cc: <linux-mm@kvack.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---

This is only a resent patch. I did not send it the akpm's way previously.

 include/linux/list_lru.h | 1 +
 mm/list_lru.c            | 8 +++-----
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index aa5efd9351eb..d5ceb2839a2d 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -54,6 +54,7 @@ struct list_lru {
 #ifdef CONFIG_MEMCG_KMEM
 	struct list_head	list;
 	int			shrinker_id;
+	bool			memcg_aware;
 #endif
 };
 
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 0730bf8ff39f..d3b538146efd 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -37,11 +37,7 @@ static int lru_shrinker_id(struct list_lru *lru)
 
 static inline bool list_lru_memcg_aware(struct list_lru *lru)
 {
-	/*
-	 * This needs node 0 to be always present, even
-	 * in the systems supporting sparse numa ids.
-	 */
-	return !!lru->node[0].memcg_lrus;
+	return lru->memcg_aware;
 }
 
 static inline struct list_lru_one *
@@ -451,6 +447,8 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
 {
 	int i;
 
+	lru->memcg_aware = memcg_aware;
+
 	if (!memcg_aware)
 		return 0;
 
-- 
2.21.0

