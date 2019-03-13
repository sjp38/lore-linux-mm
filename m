Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41C13C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDC352184E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Sj7e7KrT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDC352184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 276538E0009; Wed, 13 Mar 2019 14:40:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 201C98E0001; Wed, 13 Mar 2019 14:40:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 053AA8E0009; Wed, 13 Mar 2019 14:40:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB8F28E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:40:09 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f12so3210152pgs.2
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:40:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2cvW24YvYXEUFU3KxBgLfjLN1zP9HeM/T5I/fane4LI=;
        b=p4eldCgAt4tikuf+ZY2WUZ4Wai7ut7uHfocEPy1SxPcWeKPYU2dgapyAxcC3Tu3o+0
         HXfY08sHsV6t2Q2T8Nvaq/28IbviBmcFGW1Lsdn0j6nNR3ht/ob+7UXDueRvfZrlcWhN
         tvaXonwEUzRmaqYqTOZBaMhyw9pG4YL7El29Q2Vt5UTkeeJkDbjlEzufpmtSFHKrUKMd
         McqXz8YdaPsHXH1v3ENI+uq/F2AK2XKeLPCDaThHij5ozmwnAJiU45igelB8d/+ENnA6
         frEmonawqDWok3s/d670Unyh+Lot4u5uFQef9PJlytdkXVSXuLaifLe3FGF+Vlw0VBDG
         j7Tg==
X-Gm-Message-State: APjAAAV4cbu3kAt7A7eeEjXOs91w54kXDJ/JDdfNqHz48jtg/qUFWt63
	RSQXB4IgdaUgXM6XxDNpx40mSGvAaXte6PSMofBwnstw91pnTbHZ63VXUR++uCpWMDq2hRdwO4P
	P2S1IjMvJIOaOuZT7doIJyUoTyWK9pGvd38lR0HE63UjzCdaQw0hZIN/dD2gQaniG6EaYHbjjHG
	OYVKXKlVRuldqQSY+MM3mAOEIQMFOnTKxircYVgnZsyvkyX5S3F1wmIscK7+I+0wvuSjmlHQXE9
	cqX+QWAPKqs6Y+JQ8DL0L72w6LPaqaXZSWINmru5VEQIX+bQVUvJXD6Zj5tV9vZ9QYU5w2BwHWV
	L1fGrRjhSTlMAjbty97645dzEd3nhBW0OILzuxx5iB1SththWkpmv6VInWiPA58uTo4DSGWw2j0
	q
X-Received: by 2002:a17:902:2e01:: with SMTP id q1mr463901plb.253.1552502409445;
        Wed, 13 Mar 2019 11:40:09 -0700 (PDT)
X-Received: by 2002:a17:902:2e01:: with SMTP id q1mr463813plb.253.1552502408085;
        Wed, 13 Mar 2019 11:40:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552502408; cv=none;
        d=google.com; s=arc-20160816;
        b=lSyvu6D67Va+MvQCXoXp9Mu9ozXBwVwM03m1Jt+0Q0DBGGRi/NzuW5dcqjZtumFS3j
         Ha0Amchy8jXrXIWH6AcHkDxlTmsay5bjrQUV6LJSN192IO0SJOXOn1DL/4lDa5X69HuL
         S1Po3ILzSRSKCWazKIHRIDt3/r4dyZpYQoCvP3Ig1mR1GAyeFDMBMvRy1PM0bTj2ZseK
         pJFypA8fBLCPdzLobYaCtyUW2L1OsdaQjXbvk4FJhNxLu8yHckIYKmA41dX0GGlb1ANL
         6H/6RTbsZ0D1JLRgubZTGxx2AqX1/35L7AYK11OJ8lMnpuxZmtfcB7O/dk3rPI/WDoob
         q9cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=2cvW24YvYXEUFU3KxBgLfjLN1zP9HeM/T5I/fane4LI=;
        b=ZbyP9JQzShzojQ1wglly++0iitOoNhyZS8Y8ue5oHRJ8TuILbaka3879jtPwKcnk6S
         Dz4xmnJiXJA996R8ttUbbsfjzh+D0H4+99qu3JkhGlDap8U+EL/RXBjnWu6TOGsLN6Mk
         FudE9xcZkdyWwF1HOZx0UI8P7Bhp9Rhc84RfnZN6CD8akRjod1a4Zp9sl8c/d/SUMbjx
         G4lI3iU9FbWaKxwp6DhjbbGvrcvGwLjr7P/l0vad1yjOlvyMkf61GbRnSkoCAfGBKIFc
         sJqGFqtFTOc4ynUsOv4bao9l2tuKur1qP4ojCVVcH2NyLGi70vw6O3PqWaro4NPX0N49
         k64Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Sj7e7KrT;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d17sor2398843pll.50.2019.03.13.11.40.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 11:40:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Sj7e7KrT;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=2cvW24YvYXEUFU3KxBgLfjLN1zP9HeM/T5I/fane4LI=;
        b=Sj7e7KrTxGgjBtBVwW3+pppFo1OluqFpgx9p+e0I2eslI0IX76GxI56FyMr0Ujn61G
         n1uwAi30e7xrRWMomWR9vdILS1jqnjUhGAy5SN5E3wk3gci8ouk2KGOxzM091kLH4psW
         caD1lAzHKoQUdqLU0neRW1iZ+UbJuolybIwG/RnT0S4Bf6qnocRv8R4aDfhhWpIcz/N2
         VHXy5jPc34xUBgtkCA5Unh9g/nR69Htojaxs8hmdEN6sLd9DHj0vmv0f4bCjQYcTmKc1
         pht4bgTrWHV8QEdJqc3QEU56m6n+9htJvRLPcJWs6IpSra+W7soIv9swTAFQo2B7cjbw
         gkpg==
X-Google-Smtp-Source: APXvYqxN6T26cpU/i7gJrXRMqYa2D+TtQXlmh9inTy8ofpUF4HZSJ/PCcVKIq40FliL0BRe0lBbtlw==
X-Received: by 2002:a17:902:bd97:: with SMTP id q23mr45933336pls.94.1552502407449;
        Wed, 13 Mar 2019 11:40:07 -0700 (PDT)
Received: from castle.hsd1.ca.comcast.net ([2603:3024:1704:3e00::d657])
        by smtp.gmail.com with ESMTPSA id i13sm15792562pgq.17.2019.03.13.11.40.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 11:40:06 -0700 (PDT)
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
Subject: [PATCH v3 5/6] mm: flush memcg percpu stats and events before releasing
Date: Wed, 13 Mar 2019 11:39:52 -0700
Message-Id: <20190313183953.17854-6-guro@fb.com>
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

Flush percpu stats and events data to corresponding before releasing
percpu memory.

Although per-cpu stats are never exactly precise, dropping them on
floor regularly may lead to an accumulation of an error. So, it's
safer to flush them before releasing.

To minimize the number of atomic updates, let's sum all stats/events
on all cpus locally, and then make a single update per entry.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 52 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1b5fe826d6d0..0f18bf2afea8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2119,6 +2119,56 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
 	mutex_unlock(&percpu_charge_mutex);
 }
 
+/*
+ * Flush all per-cpu stats and events into atomics.
+ * Try to minimize the number of atomic writes by gathering data from
+ * all cpus locally, and then make one atomic update.
+ * No locking is required, because no one has an access to
+ * the offlined percpu data.
+ */
+static void memcg_flush_offline_percpu(struct mem_cgroup *memcg)
+{
+	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
+	struct lruvec_stat __percpu *lruvec_stat_cpu;
+	struct mem_cgroup_per_node *pn;
+	int cpu, i;
+	long x;
+
+	vmstats_percpu = memcg->vmstats_percpu_offlined;
+
+	for (i = 0; i < MEMCG_NR_STAT; i++) {
+		int nid;
+
+		x = 0;
+		for_each_possible_cpu(cpu)
+			x += per_cpu(vmstats_percpu->stat[i], cpu);
+		if (x)
+			atomic_long_add(x, &memcg->vmstats[i]);
+
+		if (i >= NR_VM_NODE_STAT_ITEMS)
+			continue;
+
+		for_each_node(nid) {
+			pn = mem_cgroup_nodeinfo(memcg, nid);
+			lruvec_stat_cpu = pn->lruvec_stat_cpu_offlined;
+
+			x = 0;
+			for_each_possible_cpu(cpu)
+				x += per_cpu(lruvec_stat_cpu->count[i], cpu);
+			if (x)
+				atomic_long_add(x, &pn->lruvec_stat[i]);
+		}
+	}
+
+	for (i = 0; i < NR_VM_EVENT_ITEMS; i++) {
+		x = 0;
+		for_each_possible_cpu(cpu)
+			x += per_cpu(vmstats_percpu->events[i], cpu);
+		if (x)
+			atomic_long_add(x, &memcg->vmevents[i]);
+	}
+}
+
 static int memcg_hotplug_cpu_dead(unsigned int cpu)
 {
 	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
@@ -4618,6 +4668,8 @@ static void percpu_rcu_free(struct rcu_head *rcu)
 	struct mem_cgroup *memcg = container_of(rcu, struct mem_cgroup, rcu);
 	int node;
 
+	memcg_flush_offline_percpu(memcg);
+
 	for_each_node(node) {
 		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
 
-- 
2.20.1

