Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C3C6C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:00:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2B3420840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:00:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DckgoRO/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2B3420840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A24898E0008; Thu,  7 Mar 2019 18:00:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9367E8E0002; Thu,  7 Mar 2019 18:00:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7878A8E0008; Thu,  7 Mar 2019 18:00:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3493A8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 18:00:45 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id h70so19603264pfd.11
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 15:00:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MfCrTGNmSaFUElZVoR94lwj3NK36d5qLYupM1vXTErA=;
        b=uknKFBkwCtE3+c+tI6mWin0sg2yTWKVajq+ycG/9mCce17lWOdCbD050lMprMvngzk
         Vwyv2KXJwJwNCbKgQkXKSIfMmd5kiRNMO43HDgA0KNYn5HYk+THpUFKf9L8XyIlxpYBp
         p7I54u8g7z0nwPw3/wBYzuq44/6eEjcQYHatwlqW8lLC4iYjprPc+9lOxjDsZ3bDKwCe
         mg/z9Qo2+fnVtD3bS9Mllb+4OVerm8fMxGsiNOlO/nD1hUJmPTrS8ISNsJfgo5CV4HQW
         5Q8BAi/DBEuW35AbwjARkjZFjMF3lhDJxizkTQrLJ4OsFZgWveOyMiAMnUqbiniXJuW1
         9DdA==
X-Gm-Message-State: APjAAAX7EmoBx6+J0ism6UDE86EvpNK+gmNc3ZoesYtcAABg1EeEwy42
	ZwAvRE59IyQGQsrsKE+50tkx6nG+aoc6NpPxCvy7v48D/Tp6Wg5OOxooulguZRggbZMp+73Pw5s
	HuDsdGigVnEa2ENQ/leKElFqtiScnJ7rGONFFgvY/d5jQA/1Po8sqEqEfmFYR1ZcuUZTjEmYjmt
	Vq7I4rewtVBACx0+Q5eRIWwytL0NIdS/gikdowZ+RdAxGGBUIAjS0cY3hdVXLKXiLQXBdZl6Z95
	7FiiK8603mLDSdqOKh1c9z13YVB3i2Lu0wZSUatHKYHVK5X22ICqgrzskmturkrwBOcoZfHQDAQ
	GXsov7ufOJ4bwRm35Re+DVDquCg7dYcxwZvEgXUBSxsDwne9D6eYWK+g4odMDTN4+TFRYvkcMqv
	T
X-Received: by 2002:a62:4743:: with SMTP id u64mr14908344pfa.95.1551999644869;
        Thu, 07 Mar 2019 15:00:44 -0800 (PST)
X-Received: by 2002:a62:4743:: with SMTP id u64mr14908132pfa.95.1551999642323;
        Thu, 07 Mar 2019 15:00:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551999642; cv=none;
        d=google.com; s=arc-20160816;
        b=CCRoOR04RZoGVHYHpgU7cdAFdC4qCYwT9oGoDjPW+knQIj90ucnPIWDR1a0bjGv3Q0
         ALXUaWo8Ks89ypqfXhPDPbcOmKVBu+tupud/UNg5qO7909lD7Y9B0Z8jLfyPRKgOU/2u
         w62aGxsxngjNFnYPFkpimIsx/YqI+Y92s/vvbQQqbRCoreFBEjMsYxqHnEVyFA3TMzQ4
         XXfJwkDJHigL/z+jemsS+kmKiG2Ov1oP/lScdWzOs20cnJDwUF+HWbeCgTisoAdgDwM/
         QL4tDNkXKvaMuWqG7uku83KbzRDJaLED+MnYYlswtCziMdyeEPi06j81iTwAQw2ReZik
         vEcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=MfCrTGNmSaFUElZVoR94lwj3NK36d5qLYupM1vXTErA=;
        b=RFYjwW/p3OTHjH9Z891A7jA5Zu4mZwY+hg0GA4nTh57Uwwd+IfrcQ4ppLefmN6iwun
         +0vqkNHapjJO6nR9x7+ZI9YwblhYA8wkRKJdF6vVn1zgV1LmvKzkqVY3FDmQrpUUufDg
         wV70FQKTBg2AVdnhdvIMTCbQVPwGOAhfsrijTyKXskfGkD4iazEL7J2zLDz29DMihAD/
         x/hhbWAQzS7XxHqrk+34F7ZS/h/LvELe1Y4Qe/lSR4hGqM7X1QYO8/loUtfY6Az8uah3
         egmQUfaIEJQzCBE/4rc7ZTVyMHg5RsW4ag95CeJduKmzf2hmK48wFmMs9sL6dJt4TXMW
         +6tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="DckgoRO/";
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u8sor9979896pgh.68.2019.03.07.15.00.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 15:00:42 -0800 (PST)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="DckgoRO/";
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=MfCrTGNmSaFUElZVoR94lwj3NK36d5qLYupM1vXTErA=;
        b=DckgoRO/Og9fpzx5eO2KFbjkYdOnR1jrMLl012hR598K9U/OkK69u0GSHHoaGMPmDl
         S4buq5J+Tv3pZTi+Kdt+wCGz5NPe489QYj47U0E4z9qym9QV5kbKgACI6w2MBFcasnf5
         lMenGSfadqVa9AEOW7wF8RYYuYhXOa54agdS1Q9xnVWSyU6ZnMBkcjFsl0w8dd4/CvO6
         M2oo5gELJ2m+CL8xrrMFgdlvIqSY61S4ubbL10igebd/2s+pIC98lfsUCu0j5VO46PqJ
         k5YZmwMTIKRp3gKUaluH6M0WPUd96ydqN/tarPBdgXh/bLAmAUX9oimU/ZJTP4Kd0kPP
         Ikpg==
X-Google-Smtp-Source: APXvYqyNrdFaTzkRpNlZuAWstlgn+HzqsgGmG/ZykiNpz92+GrArj5J170eRpoAbjVwIyx5oQFwreQ==
X-Received: by 2002:a63:8542:: with SMTP id u63mr13751923pgd.323.1551999641771;
        Thu, 07 Mar 2019 15:00:41 -0800 (PST)
Received: from tower.thefacebook.com ([2620:10d:c090:200::2:d18b])
        by smtp.gmail.com with ESMTPSA id i126sm11864806pfb.15.2019.03.07.15.00.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 15:00:41 -0800 (PST)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org,
	kernel-team@fb.com
Cc: linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH 4/5] mm: release per-node memcg percpu data prematurely
Date: Thu,  7 Mar 2019 15:00:32 -0800
Message-Id: <20190307230033.31975-5-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190307230033.31975-1-guro@fb.com>
References: <20190307230033.31975-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Similar to memcg-level statistics, per-node data isn't expected
to be hot after cgroup removal. Switching over to atomics and
prematurely releasing percpu data helps to reduce the memory
footprint of dying cgroups.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/memcontrol.h |  1 +
 mm/memcontrol.c            | 24 +++++++++++++++++++++++-
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 569337514230..f296693d102b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -127,6 +127,7 @@ struct mem_cgroup_per_node {
 	struct lruvec		lruvec;
 
 	struct lruvec_stat __rcu /* __percpu */ *lruvec_stat_cpu;
+	struct lruvec_stat __percpu *lruvec_stat_cpu_offlined;
 	atomic_long_t		lruvec_stat[NR_VM_NODE_STAT_ITEMS];
 
 	unsigned long		lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8c55954e6f23..18e863890392 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4459,7 +4459,7 @@ static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	if (!pn)
 		return;
 
-	free_percpu(pn->lruvec_stat_cpu);
+	WARN_ON_ONCE(pn->lruvec_stat_cpu != NULL);
 	kfree(pn);
 }
 
@@ -4615,7 +4615,17 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 static void mem_cgroup_free_percpu(struct rcu_head *rcu)
 {
 	struct mem_cgroup *memcg = container_of(rcu, struct mem_cgroup, rcu);
+	int node;
+
+	for_each_node(node) {
+		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
 
+		if (!pn)
+			continue;
+
+		free_percpu(pn->lruvec_stat_cpu_offlined);
+		WARN_ON_ONCE(pn->lruvec_stat_cpu != NULL);
+	}
 	free_percpu(memcg->vmstats_percpu_offlined);
 	WARN_ON_ONCE(memcg->vmstats_percpu);
 
@@ -4624,6 +4634,18 @@ static void mem_cgroup_free_percpu(struct rcu_head *rcu)
 
 static void mem_cgroup_offline_percpu(struct mem_cgroup *memcg)
 {
+	int node;
+
+	for_each_node(node) {
+		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
+
+		if (!pn)
+			continue;
+
+		pn->lruvec_stat_cpu_offlined = (struct lruvec_stat __percpu *)
+			rcu_dereference(pn->lruvec_stat_cpu);
+		rcu_assign_pointer(pn->lruvec_stat_cpu, NULL);
+	}
 	memcg->vmstats_percpu_offlined = (struct memcg_vmstats_percpu __percpu*)
 		rcu_dereference(memcg->vmstats_percpu);
 	rcu_assign_pointer(memcg->vmstats_percpu, NULL);
-- 
2.20.1

