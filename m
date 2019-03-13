Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC637C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84476217F5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:40:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hDD+JwIe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84476217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7D7A8E0007; Wed, 13 Mar 2019 14:40:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD59F8E0001; Wed, 13 Mar 2019 14:40:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB32F8E0007; Wed, 13 Mar 2019 14:40:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD998E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:40:07 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n24so3156188pgm.17
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:40:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WITBUxeGSIQmxb1SdGnY+GHNprTyqfSQ+9QDULNZwIA=;
        b=AEdkU0OFrA0LhorZKSs3UxtpyoQyg1IP6LPi17H3t/E89Js5ggiJKx39chKVeBbj7O
         KxnvgAMx93PmyCE5Bu70x2zHAEXVpPnOnnSAEYLuxymA8DeS/HFTSlBuW8/F9RgeptbF
         rm47Uz8vSvXn7OHOE6vddq06VcUprO7ehu37hKjzSyGSa0bWU+oBJ47Rfs8J2IlQ6E3N
         QV4x/N6OlKuClNdpBCsHwLEkK3Fzfr7bT4JpWnsH9cCjZ0b0q96z5JKa6QgvCnR1gqds
         D9cJ6CULtmCTA+oZqpzrvBmBUG7QSGMQsRPn4YIZa01v9QP/mwGS5ic3FZMJ9cBi/tv+
         5ydA==
X-Gm-Message-State: APjAAAV4vE6aSoEUJ8uwm2Xfd6XLWR0moKRkvV7yXdfLCGNE2/44gLVB
	cfcGUvEgvPPFFhrXj3n8WVXfXv36QGma6NHpnu1NPuPa6lzgjTah9kMtr4wt8pmULmz4Q2brb5D
	sNicppIxvq49TJ3DQ3huhJEQ71BtTUA6O1QCBTboNW/IXGow0H6/l0DmWSClkcUbDs7cQYZ3Mig
	vAlQIoNNj81LaQ1BcZobYzPSB3xJ052lAKEEuOvDP/7FVy3iO70swg/BdQn7ICrHyR6JDna1Oj/
	n6C4+XLy6QS+MrHCt7Ay0+Q+JQxmjgumxoQm0hVIfg8JNR3xN63lUN0yrwryz3N4RXVGOy9m8X3
	Rr+8TE/XZAO3/UnFZHeHNY0IWsK/tkHzKH0Lhd0FLLdi86+/9O6PoAgf91aRLZJwlsITreJ9QYF
	+
X-Received: by 2002:a65:628f:: with SMTP id f15mr41805323pgv.410.1552502407094;
        Wed, 13 Mar 2019 11:40:07 -0700 (PDT)
X-Received: by 2002:a65:628f:: with SMTP id f15mr41805220pgv.410.1552502405325;
        Wed, 13 Mar 2019 11:40:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552502405; cv=none;
        d=google.com; s=arc-20160816;
        b=IrHIBO+Q/EeJAcEqcFBkZhorO85S+KbyxTLQ0lYzvzmoLaAQZZS/CW7T2Q3bX4DZtu
         7dt7j+vyozCsuMkLM52PQ0tiAal2jK2Xyc7Oe9jhyCqo7xJ2LEcf61NZz+4zCSPBDPqq
         HheBtQG++tlOq3W5YoX7qlvGd+/4Kp26K/obyrD19jjk47yrumzSsZwwNfMlkaTOMevB
         YKzuNzYcg8RwgpZG6Ni0+5M2YwIQ5stn3V7F/DdqOPiT/PEX7LeplxnS/69GDWP3FOGH
         DjFpNMpfWPicHMXTm3livyWJnpJBeYOTyqMYG5zwbji8KbpA61IgWKzo6VowItbWI3H/
         qpIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WITBUxeGSIQmxb1SdGnY+GHNprTyqfSQ+9QDULNZwIA=;
        b=ko1bc6rnkDgXCeJE7n/NFKtJ+YMQZcs684o49UPHFFJmFJqPQ0DZmDQRmjLpriHUxZ
         pvrP3P/BEdVjTwYTlnrIzVwtiWVU5HZqM0PooO2j6R9IMPrOBh4DURLZlAeMpmDAjd22
         7cKoscn2rBBEPTpQMb12oY2ychGQQq8TpcPeg5osEHYV9p5O+9JARJyL/HSo8CUEp/jZ
         vGkuXvmrCsbFhVylMxUwAr81VqyQOVbv6WqYwsDqdWigNoLMrmPEB7rrBc8T6v32t4Rx
         xwjoEIM61geqqYlgDpnHRn3z0RoRifbVBLFnbYy//nKYQWCR48LycTL5iaezu/Bd0BMg
         G5NA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hDD+JwIe;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e15sor19428312pgv.66.2019.03.13.11.40.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 11:40:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hDD+JwIe;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=WITBUxeGSIQmxb1SdGnY+GHNprTyqfSQ+9QDULNZwIA=;
        b=hDD+JwIeip0gJspQJIlifBLo3RZkJBVwzeLhOJ71FgqywT6SXzvZP9DGDEs867pwdR
         WO8p8O0KNF1rt/jZhEK7qRkFmJuWonuupzsv25wmsIUlubrGq2+uI/WUOazBl55WoERs
         6UGSTlw8yD5nIom+ZJg9sOINX3RB3BWpRWxKCIaOMpU3i5NEQIlcg9w7rqfEpTjqevdR
         Ld2PdY9k3jCJEkbbVafk5rGX8TJUQ4ZkcPAQoycBwKqG3ienRmFTdSplpjS6WxomRczi
         beS9hglAoeVCRuUSVrSHU2CeKJUnBfeBNkiuJhuizLUdgu8x9wOBdrgC0POHx/euvdoo
         Zy9Q==
X-Google-Smtp-Source: APXvYqwpwjKd2OLLFUS/RUgUqKYXyrVqeFcG3DA+RFLUuCtoNO4f0ufr+hHUm2yNJIlTPoM2CaI/SQ==
X-Received: by 2002:a63:cd02:: with SMTP id i2mr41652810pgg.111.1552502404731;
        Wed, 13 Mar 2019 11:40:04 -0700 (PDT)
Received: from castle.hsd1.ca.comcast.net ([2603:3024:1704:3e00::d657])
        by smtp.gmail.com with ESMTPSA id i13sm15792562pgq.17.2019.03.13.11.40.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 11:40:03 -0700 (PDT)
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
Subject: [PATCH v3 3/6] mm: release memcg percpu data prematurely
Date: Wed, 13 Mar 2019 11:39:50 -0700
Message-Id: <20190313183953.17854-4-guro@fb.com>
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

To reduce the memory footprint of a dying memory cgroup, let's
release massive percpu data (vmstats_percpu) as early as possible,
and use atomic counterparts instead.

A dying cgroup can remain in the dying state for quite a long
time, being pinned in memory by any reference. For example,
if a page mlocked by some other cgroup, is charged to the dying
cgroup, it won't go away until the page will be released.

A dying memory cgroup can have some memory activity (e.g. dirty
pages can be flushed after cgroup removal), but in general it's
not expected to be very active in comparison to living cgroups.

So reducing the memory footprint by releasing percpu data
and switching over to atomics seems to be a good trade off.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  4 ++++
 mm/memcontrol.c            | 24 +++++++++++++++++++++++-
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8ac04632002a..569337514230 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -275,6 +275,10 @@ struct mem_cgroup {
 
 	/* memory.stat */
 	struct memcg_vmstats_percpu __rcu /* __percpu */ *vmstats_percpu;
+	struct memcg_vmstats_percpu __percpu *vmstats_percpu_offlined;
+
+	/* used to release non-used percpu memory */
+	struct rcu_head rcu;
 
 	MEMCG_PADDING(_pad2_);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5ef4098f3f8d..efd5bc131a38 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4470,7 +4470,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
-	free_percpu(memcg->vmstats_percpu);
+	WARN_ON_ONCE(memcg->vmstats_percpu != NULL);
 	kfree(memcg);
 }
 
@@ -4613,6 +4613,26 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	return 0;
 }
 
+static void percpu_rcu_free(struct rcu_head *rcu)
+{
+	struct mem_cgroup *memcg = container_of(rcu, struct mem_cgroup, rcu);
+
+	free_percpu(memcg->vmstats_percpu_offlined);
+	WARN_ON_ONCE(memcg->vmstats_percpu);
+
+	css_put(&memcg->css);
+}
+
+static void mem_cgroup_offline_percpu(struct mem_cgroup *memcg)
+{
+	memcg->vmstats_percpu_offlined = (struct memcg_vmstats_percpu __percpu*)
+		rcu_dereference(memcg->vmstats_percpu);
+	rcu_assign_pointer(memcg->vmstats_percpu, NULL);
+
+	css_get(&memcg->css);
+	call_rcu(&memcg->rcu, percpu_rcu_free);
+}
+
 static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
@@ -4639,6 +4659,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	drain_all_stock(memcg);
 
 	mem_cgroup_id_put(memcg);
+
+	mem_cgroup_offline_percpu(memcg);
 }
 
 static void mem_cgroup_css_released(struct cgroup_subsys_state *css)
-- 
2.20.1

