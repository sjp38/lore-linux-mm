Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91CDDC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 474DA2177E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TrX0uTyr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 474DA2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D26F48E0008; Wed, 13 Mar 2019 14:40:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C63668E0001; Wed, 13 Mar 2019 14:40:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB35C8E0008; Wed, 13 Mar 2019 14:40:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DAC48E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:40:08 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f12so3210089pgs.2
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:40:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZKgL4zeK+z0St01hNMYKSt6dKMvw92MkjAHduvDs3M4=;
        b=SO41XlPORO7O3EvAl3horS9/7rFS9PkggcjhrMH29Vm3l3L8Zg/Nd/xh/Gs9TyapkD
         T7RLthumZAvtlVmy1bhaZnqymrtvwiUTMYt2aHuCqAmrJbAmTfEqGtNcs+28jII7PG8x
         htqKwx5kGD1SGcnFnBmXkZ2zI4zhidL0B8ijVmQ1dZmM3ToEGMHd9jHNeTSKzuH4HHo7
         OVKaE1DIEYs3yAxMj+/2XODFjG7tLbt42Cw77/p61N+HeRcY1wSPDxVF1wrkgJbA8kQ8
         BMLQvk/MN7PnIMzFM6SVrK5ZTrC7N17tRuHyt/LidfbIscTbBgNVuF8/06gVjc/h4hyZ
         QwHA==
X-Gm-Message-State: APjAAAU3Qs+sVKHmURVE9BtZsJnVu770/eGaNL5jJ6lcDhoFLpwqrOTJ
	IoHyay4x1fqFzPQOHtF8HlraInPdf6pTRMjA5RSm6pUTVeEydpLrNTmjPNaY9RyQBZL2nEedHb8
	L44iX39HHFox3CRYjmRD66TvTsv2ej4AAQY5tmLUDqdxJ7tC+4LqvPBA+/25Wm8E3K47aG5xpPY
	Wqsku9KsYUiYU8mvaDpblB4v0/sceLLbEqbgccisThxLm36xk+4rrjl/eZFtF5ltyUw+SU+EGjg
	Z+aKDQbQgxqHKOcQIHhRCFmA4kqlrYOiIVWBg/S/kyB6Rrsr9hAOl6LUXAR8gO2dVbnfEXsZzdE
	JCXkGZlCcfa599rQzn55n9o1tiuMYMHGL4uUymNDV+Uto7K06dd+7aKl6z8+Wk4F/aQtItMghBl
	n
X-Received: by 2002:a17:902:784c:: with SMTP id e12mr46569360pln.117.1552502408137;
        Wed, 13 Mar 2019 11:40:08 -0700 (PDT)
X-Received: by 2002:a17:902:784c:: with SMTP id e12mr46569272pln.117.1552502406730;
        Wed, 13 Mar 2019 11:40:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552502406; cv=none;
        d=google.com; s=arc-20160816;
        b=jNcJglDab4GLDRPAOBsg88+qWIqYIMxNgFgsqvH6O4L+Lic9YOlI5ZD14JjkhgpI/u
         Dot5UDwz9G4N2xWFZtx5GgZxthIpfJvE3tLdxTgjZegnyVXTRtiYoNZPkdSolhAgiZ7v
         oJmzRSI0HruJ5flWqWVGBTxUvKC+0L9+91V9JuBHEsYvSE2AKlR8NUtzBxVvtvOHR4nI
         ljqo/odAB33V/lslx8eqe+yM2R/wKLzM290evm90HOifbhn0nKjOijWzy0qliMnJzmWR
         Vjko/ltSoiZGAaWBkjlEdmOcPo2eBQxqCFbf9KyZg7wCRfXkhOqRmkXDsAqIsYYb3dKh
         BCZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZKgL4zeK+z0St01hNMYKSt6dKMvw92MkjAHduvDs3M4=;
        b=pQ6M1C4C4+mndphaEj22eI812Ix7TsIwfqjMJoNWztuzuRQx3i46k9xgy0mUmmNeaQ
         U5duAan4EALxa3FaKuBblRtsz9idJpCvFHtIX07kkumYAQT3Mz1+gCCDHfu0YfY83B/J
         jMszeJdYtOhjC4pCVybyu8Y4OHP1I2hVtM89Rpldi5s0w9OZBj+KRafMVau+6Yrvw4vu
         DSBNTElzcIy4AWscW7KlhKsDjfiA5H3i7QRxXvecZ03UVqKF5p4u5D3m9/k3lKq8j4pj
         aOKzMTJksXXDUSO+T9Ybsz1gStFTr71gafdHX0y8UAaCFFQEjGM7wIYbPxMk8OoapDCa
         8oDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TrX0uTyr;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34sor2430917plp.24.2019.03.13.11.40.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 11:40:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TrX0uTyr;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ZKgL4zeK+z0St01hNMYKSt6dKMvw92MkjAHduvDs3M4=;
        b=TrX0uTyrR8JGkApkgIGcwFbP61RnpY6vKQwkP3/WLW7+611dwmic3jm/UWC51wVBzv
         ZxmlfoRbLDOV/svdWScPzZ/35vHi6eAsW2cpY8KPHcmb/cksQIqgn3y0kW3HqrYsAViU
         PARJAv80Ak4rosKlqFWfUugSTU+uhn9jnGEMIaeC64cakf8i7ChAiCsDE+0A9ZwEGCge
         FYEJhOYXTTU3uD2MQVw2/thiMnBJdqoCRJOKTPFBfU/2O590YceAv1YBFw8evhN+Zv2A
         cTfzhAI9/zmULZ+hon4mYfTi8ukHQe/72jihu//A4YZaOWgfgWZWS/peYsKluEf3cG2l
         xV2g==
X-Google-Smtp-Source: APXvYqxV2blt47QtOVx+WggwDQ01SnXjX2Y9PFVIr3pxDFvknWA+oQdov2HJkEBELj1nvrrU2TpWmg==
X-Received: by 2002:a17:902:3:: with SMTP id 3mr41784620pla.114.1552502406117;
        Wed, 13 Mar 2019 11:40:06 -0700 (PDT)
Received: from castle.hsd1.ca.comcast.net ([2603:3024:1704:3e00::d657])
        by smtp.gmail.com with ESMTPSA id i13sm15792562pgq.17.2019.03.13.11.40.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 11:40:05 -0700 (PDT)
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
Subject: [PATCH v3 4/6] mm: release per-node memcg percpu data prematurely
Date: Wed, 13 Mar 2019 11:39:51 -0700
Message-Id: <20190313183953.17854-5-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190313183953.17854-1-guro@fb.com>
References: <20190313183953.17854-1-guro@fb.com>
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
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
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
index efd5bc131a38..1b5fe826d6d0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4460,7 +4460,7 @@ static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	if (!pn)
 		return;
 
-	free_percpu(pn->lruvec_stat_cpu);
+	WARN_ON_ONCE(pn->lruvec_stat_cpu != NULL);
 	kfree(pn);
 }
 
@@ -4616,7 +4616,17 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 static void percpu_rcu_free(struct rcu_head *rcu)
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
 
@@ -4625,6 +4635,18 @@ static void percpu_rcu_free(struct rcu_head *rcu)
 
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

