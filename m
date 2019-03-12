Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39D18C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D76B32077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:34:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gw9+V7Aw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D76B32077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 372788E0009; Tue, 12 Mar 2019 18:34:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FD188E0002; Tue, 12 Mar 2019 18:34:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E47788E0009; Tue, 12 Mar 2019 18:34:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B30E8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:34:14 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d128so4253953pgc.8
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:34:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WITBUxeGSIQmxb1SdGnY+GHNprTyqfSQ+9QDULNZwIA=;
        b=Zll7H4ujJS2lnuK/1bE2UrkAhJta2ZxoMQAdEg5YwI7PANLfKvAenI3PPJ13yknRT4
         6qsThl38qB1wwmuwghfx6EfavzJ4eR0KUDNItw0sR0a+dfaOq+0DT9U7hH7NI9CicSYb
         8he6l2Cx7RNgZOajS+qkbqylc5IvAlBiThVGQFc6uaWrtT2fF6lCSfcPlokaC6rXxQ1m
         FTqnN+TYmeZB7wVGK4lz0TEigduZCorTEtzTl7mTghG+0ijNgSXN9Y/cWFiINSQ23ma4
         muG4QzkGT6YfuI1nzyA3G+jeFH27/0JnoOjPCyjYJLQ837tqBr2iu2885fYdz8P/8ToX
         EypA==
X-Gm-Message-State: APjAAAXJrGRTm+QV2lPF5nM5w+BqHz7nJl/29joe3xcey+WNMKYebjLm
	L4LQgrE0QYiY30Rv5znWn/j138GmFbEPImdGzeXlY1sWha0DAf/oDyP3f8WPfHNjKKezezN3GO7
	ksXnA3E0mZxkgJi3jzC8+6kumRmWTvfvev00cLt9xnGbmQRL+Mj6v5Ftw6/DILQxbWurYCPNgQa
	529+svN4+JZWHlksUTKq/ZqrHiabIlKvwGWGxMnwQWeFt9QvpP/rElOz7EdYl9Ln44ggtxB4uf0
	OYiGWkHsTCY+lf2BYWuEP3xWco1zn11WvS4awYPnJb45EhH1LGclG4nx0ZlW+yCVocqiw0AKx/6
	7ssALXF0/k7as3V3daSifJ7jRiKDJI/zuaK2xJeKAzGrUL5/pl4jmiWpVEKJ/2VlzhpBVTDc2e/
	N
X-Received: by 2002:a17:902:e90b:: with SMTP id cs11mr41117478plb.197.1552430054298;
        Tue, 12 Mar 2019 15:34:14 -0700 (PDT)
X-Received: by 2002:a17:902:e90b:: with SMTP id cs11mr41117391plb.197.1552430052779;
        Tue, 12 Mar 2019 15:34:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552430052; cv=none;
        d=google.com; s=arc-20160816;
        b=CSOCvV0vhYZvp+f7XGRIUbcRcwc/mWP2eOPEBVDrCu1SDW6jeZ7gGf6CekV1aJffzF
         n9OHdYyQ95kNdT1TghtK8uZDIrmHGwLcmF1xSRvt12/NTpK/KrU94+sNwcR+aFRcnhAk
         5aEnrOdRKePc8gAEQnAARQSikAOWw9rjVn8JC2BYDGgeH44i96apKtPRxJVvjngn+Ucw
         HLzrjF06n8GClQBquG2TyuR+7/8HpOd6UhdPWLGEzCN7xuCiMxje03qDbBNb+fXeLpEn
         olD4oTwRW5lu+elbgHbQYc9B4bxU7Gv2xhL1XjwCurLTR1hwtzObXV+s+mglYiNR9+hy
         xIMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WITBUxeGSIQmxb1SdGnY+GHNprTyqfSQ+9QDULNZwIA=;
        b=LDBN9q3wmvm+JNrH0GY+Np+QkHKbiZtB725lHKdSFzTGovcI74CcNuNduUyLNbQwY3
         +KFwFmQirvuQu+DDRa+icGZT2DjXIViDyOF8dA6d7iBlUZvtojqMi9Ek6KUSTwoN0BHe
         Aggl9LPZZ25ioIILq4NymWQLeWpPV7VA7Kaxs74Rk/X/MBJx7ugu8S73ShbEAyg++vNH
         OdlYcqJQqwA4JXCY9Wf4r/ohcTs/lnuohvT0a8MiXZvoecNc/Xf9Ck4Xmv9nBR0sQ1NH
         7lb4QNpk+V5ApBzrTXJaYSU2/Af++8NFaOoc1DaXpzJVTL15dMaugyl9b+dMjFknc6Pu
         aLTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gw9+V7Aw;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r22sor3528196pgg.11.2019.03.12.15.34.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 15:34:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gw9+V7Aw;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=WITBUxeGSIQmxb1SdGnY+GHNprTyqfSQ+9QDULNZwIA=;
        b=gw9+V7AwT9BhELUS3izGcpK1i9cnVisDnS7huiwO0ueQQsRqDBRQcs9no5AD+mhOyZ
         exFVmMPw2TSbuSfU8RXhszBVIq2IRNjzA4mtCnLvggeTueonNHnhfmfvwJ+wWdMmuxif
         yfx6/r60CWxsOd4dvu0akIYSbexXfK9B4teuwUDLfkU5M1U/dIBlf6sk6I6RmOwOBDVZ
         ja8lbvLfjJk5bfajgTjeRrYumvVtsEtu3PLcP5IKHOiElvMZD5ehmsZ2yc5wfpWM81N6
         2TH47iyF59ke+rxd5q+hAEHm1suK/m//n0NPrp9baJtPSctDOiPqvetpX4V/0zHsad1W
         E3sQ==
X-Google-Smtp-Source: APXvYqwOCTEzdCd46KHhbLhv+IK8K9xe2Y6ShvmFeW2wxLpyyyNkLKjIUagfAk+pvoSIv5NI7DyUlg==
X-Received: by 2002:a63:7e0e:: with SMTP id z14mr37330494pgc.436.1552430052235;
        Tue, 12 Mar 2019 15:34:12 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::1:3203])
        by smtp.gmail.com with ESMTPSA id i13sm14680592pfo.106.2019.03.12.15.34.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 15:34:11 -0700 (PDT)
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
Subject: [PATCH v2 3/6] mm: release memcg percpu data prematurely
Date: Tue, 12 Mar 2019 15:34:00 -0700
Message-Id: <20190312223404.28665-4-guro@fb.com>
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

