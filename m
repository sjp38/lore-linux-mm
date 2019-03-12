Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A5DBC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDDB52177E
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hlmEsoAp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDDB52177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19E108E0016; Tue, 12 Mar 2019 18:34:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 125D98E0002; Tue, 12 Mar 2019 18:34:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8F9B8E0016; Tue, 12 Mar 2019 18:34:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0108E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:34:16 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d5so4712502pfo.5
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:34:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0AseUfXAAtgM7xE37ALVmimobdOHrae++QaZmnVS3p0=;
        b=LPQt1R3LJKLbWf0AmTsqwRqUnctLprPlneiQqWfX1/8bUVAoq9ICr5lQqJX8dEawMK
         uegyIzhIUYUYQEp2mqiKhJyPBrOlxt1oPbgJGS7MQ3XL6Bxm7BwjAIMEyFyRP60sdni0
         ENn7ogIBbUkTEj5YHE78PHbEH13QTgrfi2CU9/UDUL1oty/uJyodQQQBk/BMvLXU/Ijx
         v/CLHePyiv3FdOnc3AYoHrD0eVeJPe80XJIADO8tWpIg9wMKgT4pyoi1lN16Sfd5qlu0
         MyVrUCJalQvJnm50fhrc0s14va9tXBbxrDBP80SD4yb9NutABpVZteuy58+s9y6LfJTY
         kAnA==
X-Gm-Message-State: APjAAAVKPgJ2RJVNbpHD9jbjR2/UCIHiRqpnJ29rKRH0eCPwa6cmOueh
	FOTIVGETp3TrUiFmKtIu2GzezkecPp/jVZWRV4n6a9TQcL0rv4X71kw+YxB3iDEEzHVKUiBztMI
	vhs9cNVyS3NyeJBKWLO8CdT5DOcqow1qUa3XqSX6o1idWfQR0RtSqXDtjzdB8uQLLV0H5lGPzrZ
	wyjf+dUMLoM88hquQF0TTT8fK3+nyGDZA5+18HFnUQOWUwNNqfW9xwNBZchwDY0yGQ9wWqlycIu
	In/qQJ7xV9C04wEJU9nKJkqMdVZTQFxPb+lgZgVs1FzM+4WiWU+DI/ZvRYUg5+DOi5mmbXIvArD
	gmWFI8tgatfCJmNNjJM48QQJ0xBK3TEK+Twh6qfnLIPWa3uq8KqzKdG/rJV6Sd6mbpmM4YB8K2r
	O
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr20272419plb.246.1552430056312;
        Tue, 12 Mar 2019 15:34:16 -0700 (PDT)
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr20272332plb.246.1552430054959;
        Tue, 12 Mar 2019 15:34:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552430054; cv=none;
        d=google.com; s=arc-20160816;
        b=luD9qDRSyqrot6kIdKlKoM1qTf1x1VVOurjPIZB/o9ZPwvX3iw6zc0JYYeHIagNAP+
         EbdXBXIvQHI0Uy+OoVBzVEIlZbv5SmUfwNq+xA8FYZKlJG+fBohQHvHY9HUif9O6ZBcv
         eBMaT67WPaRG6mHQwrCw2Kyyg0ChelZ5zUahBOe83qmsh4K6N5Pc+vuHVbm7yQjB8LfY
         lQIppuc4PXlSqIX7er+fP8/apA6IQunhQkgebddEc8/8UarbXnaZfQuUf4LIeneLS1L1
         aIf2qvBgoYXULJcLsmhrtw/59eJvI4Po5Bo9SYhLFhOVyfo7XBzB1DqnsZS5E27H4DsI
         /lJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0AseUfXAAtgM7xE37ALVmimobdOHrae++QaZmnVS3p0=;
        b=zxpEKmOj9WveSsdcc/Q45mGwFfOnZXlHdHOBaRE7UPjMRbNIYtvTHvf5pAqOa5NHoK
         6vzs75f5LBYnLOMuPt8q1YLmEfD522ly/qZkEgXox+JRAd3xuB2k/dLKtceSeJU4GCm9
         kq+ljcJShjq1kFhDsaceTpDn8g92ClLfwlJPW0AjEQjiJFKQ+G7svfFYtyxnkDzC79C5
         JA7zx/J/uYfWIQEpgnifuV3wOiHcfyVrLDDLlhlkKAkgBMBLley7VD17n9fMYPbsdA/L
         vWv89j3jQi3iK6/H73TkyprfG2oK7dCNx8mjbm4+aRvb0AWWsUuywrCBvBnmCmoZuVUr
         49qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hlmEsoAp;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x1sor15122845plb.45.2019.03.12.15.34.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 15:34:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hlmEsoAp;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=0AseUfXAAtgM7xE37ALVmimobdOHrae++QaZmnVS3p0=;
        b=hlmEsoApvA/mPdl0iBW06MNbW54pe9uXKLI0ahcw+KfOFDqPsNwozyuf/2FhiVycfD
         knJ0Vxm7F0KP7fmIjk3HSFKX7vxKdbqVR/ncWSecT8LiNZj8ed3QWLFwKx4cNWGcvC9l
         U+r7VBADW1oe+7Q32r16t4eTIfTU/p6TXMKLGiJbf9dHzgUYXD/79078ZFmDbKAEotUk
         GY0aTSay4wBRp5nV4d/00Yon9XA6n8xKekA/Di4Nn6DeVujfOekkgZdqIS1BykhG95E1
         Wh/Sd0PNA2IlQP24StTYHp5SWr4M+KoUkYW35t9ukZTak76552zqkiyBUFTdIRHC23Lv
         3QkQ==
X-Google-Smtp-Source: APXvYqw+oQJ4ndnWt7iHQgCj/cQPi1Rt1P8zv210NZF5fOTuQOXgHm6K3xRS+YSiomUIUFri8uU6TA==
X-Received: by 2002:a17:902:968b:: with SMTP id n11mr42163572plp.316.1552430054499;
        Tue, 12 Mar 2019 15:34:14 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::1:3203])
        by smtp.gmail.com with ESMTPSA id i13sm14680592pfo.106.2019.03.12.15.34.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 15:34:13 -0700 (PDT)
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
Subject: [PATCH v2 5/6] mm: flush memcg percpu stats and events before releasing
Date: Tue, 12 Mar 2019 15:34:02 -0700
Message-Id: <20190312223404.28665-6-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190312223404.28665-1-guro@fb.com>
References: <20190312223404.28665-1-guro@fb.com>
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

