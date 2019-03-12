Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFB0AC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72DDF2077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kPvcG3sz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72DDF2077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F6CF8E0017; Tue, 12 Mar 2019 18:34:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 484138E0002; Tue, 12 Mar 2019 18:34:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25B5D8E0017; Tue, 12 Mar 2019 18:34:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D7E8D8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:34:17 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f12so1908364pgs.2
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:34:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JZX5VXWRV31e/dorMIyOAZjwZx1Lnus1V/4dOHz/P7o=;
        b=PbxS8DWJrMbbw+cfFMyEB7rCqYaiY4f6nnlOXVKvrX/e/0UeUFFnkrVmAvgs6p5rOt
         HgK/IOWf3lnCCh6SlIETmSgMryd8d0ilbw672sFZNlGLU7vdYwlZJfxg7aitScYOHjci
         I107TYhZY88DvE87VrVVQbCLnJT/MPFcz+7U78UjKtIM0K8ZsUOiY9vAVK0LZOVpiVcQ
         zJUYhZIsZUBPSZ/oN5BHYSDTdugMgSkrQyw3ydVIE9kEZUmb66dIOdpP5I8VyFzHQln9
         Rpq+3u6k6lpbToiildg/GVbA+rtzbvcWhxADOeGOEdvWmSSdAD0RjOBZ3IjLYsPD7UaD
         b33g==
X-Gm-Message-State: APjAAAWUE82j6XbbKBvylYNCVMbP9F7ycf5LnVQs567nOOH/308WnzrN
	dCWwKDrnQZYJR6DXC2wkVQCXTwoX/PkVpHZgLrNmJaUdtO/VXoci+EZzVaz3xT41WmvgIF5h5cb
	TC5ExkrywlZ2ZxrzMQ/BeHRI2GxJaDxHS2xr4QFAF4s6hy9qLT+GzcSB3nF/ZgTlBD3jtYGzaOx
	uqesgo0mzW/Cth6WPGzT94pcuoGODiQrCrdc8OYbPwBDJjA2XB/f4UJnXicGrAABBV9XF89X6AB
	kn25DsHTFb5gSjVIqGvjO68u6NPIdKO64gUzVE+8LaKWr5FOa4E/VVzOSTKVsMR/QJ2WlL5nTy9
	nZlvar1BwS8zWR5vXtaN6RV1MGHPWku8AiXAFoCgm+RP7tq334AP8z9WXlEbH7PY/ZMFT7/3FfN
	f
X-Received: by 2002:a17:902:bf05:: with SMTP id bi5mr15730496plb.252.1552430057561;
        Tue, 12 Mar 2019 15:34:17 -0700 (PDT)
X-Received: by 2002:a17:902:bf05:: with SMTP id bi5mr15730412plb.252.1552430056127;
        Tue, 12 Mar 2019 15:34:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552430056; cv=none;
        d=google.com; s=arc-20160816;
        b=dDF5Zw0mWtKvYTI6qKyDMLQSvDhwo++JVHXiBLsh7RAFI9dv6O1Xmg2OY+z4cb/ddl
         JxgpTkMTBu11TjvLapZL1+qhrdf6yuRD+KZ+uo3AT9AGy5EEusemW9Nem1CjcpjgkzWN
         4ah+w1UXAtbLaYbsV+u5nE4jGJiKxWmpnJ8oy2o4BAl4Ir7G7j3jITd+jkb8SCt5OPGZ
         Nw/cgVIz0jLVB90GydmfvDJFHc52b5nMbUDcTETMF6YgKS7jZ3+5wAR8xZvOX+jP/+yb
         xvOEQaeOE1xPaagV27OpYCDwslEhaakPoIL024K84lG954ga/0UHEFrhnN3V69jOqC1R
         pT5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=JZX5VXWRV31e/dorMIyOAZjwZx1Lnus1V/4dOHz/P7o=;
        b=ccqLFCRCRskus2zMXKK6r9tI/h9A4K9ebfiJS8QRz+g5JtPzejR8D9EDdTeGHJqZ9F
         5pj6zJXrTW4w2aBpHImjSVHdUaFEeBMjBGQrCSyt+0Ft+vITfP7KZI/JgY5XmvsoCFfS
         ItLFwh/MXjlLlvWO9UJgv3SKg+Bjo6erK34DA7efCBmS5n4cZUb1fm0DzouUvjWrIIWP
         JLX/ZGTqQYbZtN5s41aMLJJsE8oTWiAvME71xUUPVNc5f/mMIFWIKq4lw9moDC3g8GuS
         MgKso7wY+CvmAphKdAVLHLSlyFnZtjoxz/lkuXKtwx8LVy3Da8EFQjDZFTM19XuP7ZVz
         vmEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kPvcG3sz;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c24sor15220354plo.69.2019.03.12.15.34.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 15:34:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kPvcG3sz;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JZX5VXWRV31e/dorMIyOAZjwZx1Lnus1V/4dOHz/P7o=;
        b=kPvcG3sz1oIMN+A5deEm4FkV/2Og21S/ZdzmlBgWCta1VoPocpURg5BTxxL66IPeGW
         KebfneTeQknBMcv0RIODkHuIJ26KPqoOKTxWylOx80IgIWFxLgY+F7NNbYkjXL/u42EP
         48K9fomPliCJxLp2CCvydxaRJ+MEH6B9Txe++8T7+1tbAK/Nh+xfThDUNjxeYlOv+7O8
         e3jWD8BZTDObwiZvbqGhtTnRyjwIn+HA8OHG0nTDXsmHXpsbX1I/CDAJL9kE9Peb1PK4
         wA0iNVQ3Cai5d5t2+VGgnJgjCVY6fQkOLEOWIu/d6Uy/hAmr4kaNQrNCGCx9g9u9l2bI
         ZHqw==
X-Google-Smtp-Source: APXvYqzD1PVjUf4iM9o/YE+Z9nZ4TfeCb+Wf1JEL8VMwvOoex1fD36Y17trO1RbFs/TmANuws+r/Lg==
X-Received: by 2002:a17:902:8c8a:: with SMTP id t10mr5501547plo.160.1552430055663;
        Tue, 12 Mar 2019 15:34:15 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::1:3203])
        by smtp.gmail.com with ESMTPSA id i13sm14680592pfo.106.2019.03.12.15.34.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 15:34:14 -0700 (PDT)
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
Subject: [PATCH 5/5] mm: spill memcg percpu stats and events before releasing
Date: Tue, 12 Mar 2019 15:34:03 -0700
Message-Id: <20190312223404.28665-7-guro@fb.com>
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

Spill percpu stats and events data to corresponding before releasing
percpu memory.

Although per-cpu stats are never exactly precise, dropping them on
floor regularly may lead to an accumulation of an error. So, it's
safer to sync them before releasing.

To minimize the number of atomic updates, let's sum all stats/events
on all cpus locally, and then make a single update per entry.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/memcontrol.c | 52 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 18e863890392..b7eb6fac735e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4612,11 +4612,63 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	return 0;
 }
 
+/*
+ * Spill all per-cpu stats and events into atomics.
+ * Try to minimize the number of atomic writes by gathering data from
+ * all cpus locally, and then make one atomic update.
+ * No locking is required, because no one has an access to
+ * the offlined percpu data.
+ */
+static void mem_cgroup_spill_offlined_percpu(struct mem_cgroup *memcg)
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
 static void mem_cgroup_free_percpu(struct rcu_head *rcu)
 {
 	struct mem_cgroup *memcg = container_of(rcu, struct mem_cgroup, rcu);
 	int node;
 
+	mem_cgroup_spill_offlined_percpu(memcg);
+
 	for_each_node(node) {
 		struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
 
-- 
2.20.1

