Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B06C4C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 708DE2192C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="0GgY+/ly"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 708DE2192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E2B98E0008; Fri, 15 Feb 2019 13:14:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 994CD8E0004; Fri, 15 Feb 2019 13:14:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7995F8E0008; Fri, 15 Feb 2019 13:14:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52ECB8E0004
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:14:39 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id p198so1666514yba.6
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:14:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VwVlGm18jJ9MvrZQxMUmMoYva3opswVp+UNaldGjONU=;
        b=OXXo7Ba4j9ReW4nIZur5/IDHR9Hk2y+Lwm1cNSksdZHHFaRYuSrIrTvWrqH6qZ5Igc
         HacULGNJZD9AkRJXQ++kIbdrnF/TRq6ah2FV4H/bigOAOr08uvdbVGC67UnhEN/JIeAQ
         BiRkLn5VH8qAfanu4++pQxnIYZ42pxmzzMHbmv9NFh/uSWljlYKvnkdroRcllyjCu2GP
         tenOhSJOZWux2AMKnSv04gA/t2xk8UUasHObJUJE9bk5pXTk6OGaZCoRJOOE8MSnPB8c
         Th9eGJwyodOksxOV4vcTSC4v/axRJBgFiFIx/nUgWJUgY6pmlAfJrKClL56PgDdWCvzG
         DoAQ==
X-Gm-Message-State: AHQUAuYkGFWrqf+m+zG5B30Qks8bn4tws1FXT9csYq6oEp6rSLiYE0WU
	iG5WEjExYvKHsj2AItZnUevnMm+VfexrOMAAg1yWAa1DBe5rtYGGdrarQyT8WiCznqCL3ogEGF0
	eT4r0x82zWSsAd/PnqZvoYUHpt1SSy+C6mlrsfNUbT8heDc/p4dHXgNbWSVn/IfyRTcYIH9tksI
	aRyK9dsOMi1xcDOL3/txddpUvBfHP2H7MCXXFx4fVS5SabL+hzIhxhGc3/XEejXNAmNoY0w/buN
	gf1SSd9oqyvIwBTY5jg3a3YUx4EbUIoar0jsyJHENiFLhFxIfqwpUjvVfHO0tquqwjPBOKzjA88
	GOZqTLn8VV7MawThjNJGmbPkLs5lLISKRqXWpld1EDF/LGEzsayQx/8s4dci4xOr3VwGxCikqGN
	1
X-Received: by 2002:a81:180b:: with SMTP id 11mr8652391ywy.431.1550254479083;
        Fri, 15 Feb 2019 10:14:39 -0800 (PST)
X-Received: by 2002:a81:180b:: with SMTP id 11mr8652335ywy.431.1550254478279;
        Fri, 15 Feb 2019 10:14:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550254478; cv=none;
        d=google.com; s=arc-20160816;
        b=pDznUnXCLwVcaXXgrIE/qVYjWzUG7z4nLh5EPjsoNvwN+OAI9f/TWjR79ezZY5pbCF
         ACxidjYN33LlX1sBwqUzZ4iB+OWgzxyzPOiVi0kdQItCMgnr4ZUmUx8RT3xaHu4/nYqs
         zj8TEuF+iuguf45odW6DVtZTiXlTC9kD3ga6k8zxhgfPLVXqcmiYGpqLOUXlE4RsNpBz
         Y+ieu9imtcyt6UzzN938Gmm+dX0LIE9A6YxMOaci15D5YRBLkI7b7hk1yvIoi6Jf9gXh
         fbaUVlrmfdrrfngh7YZUn3BIbFimvGyaOr95bZuqaWbc629ysQY/cPA6kpzbCiHN0Aln
         HbzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=VwVlGm18jJ9MvrZQxMUmMoYva3opswVp+UNaldGjONU=;
        b=FB5X093In0hpgzBd3lc5zYj9hwacvt7h58Txd/4w6jN235iz6sKTk8UifhPMQrao1k
         OP20mXAETPYvPTltY1H4pMC27s1mmqRn0qLkijoCq3uCM/5qzwJ1QHPq2ds2Q0l3fR6V
         QAcolW2nGUHiv3kOjj+c8eekr6zP3voZvm8+8g9nIpSb9joEJ1ji70akmViq1xV0GzaL
         3Wa7JUBI8DxYBj5dAVdZDxVeaZHuyThdG1k8TjSoSwCJ498yQp3dQSFoRfFOmq3aWTGI
         G1L4J8usxRrmanxdi+CqbLo8sdbiI/hio2NqHTjhPL9jL0HvLFCDyhsIIVaYvGjmzKtv
         v5ew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="0GgY+/ly";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j128sor1069733ywa.15.2019.02.15.10.14.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 10:14:38 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="0GgY+/ly";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=VwVlGm18jJ9MvrZQxMUmMoYva3opswVp+UNaldGjONU=;
        b=0GgY+/lyZgElU35qV0NY61NN6hK+ek8EPJ3kLmflCoskr0PqbHkKUWeEIn+moimd23
         iO5cQdlDPZuB/VYeXSIVCt4gZASOIW2xhSpKnyI10nZeQEq69hwlkfUY3Nf1uyGA7koP
         8QCFrkw2XDm8Fw7urfaRmBiZbXWz5YtHI60ox1sBg95RjpK6bqKhDo01fCyu+ABeMqP4
         2V8yrChKQwZp0dR+oMK9As8ZBefzQf+A/1BskTWmeqoNINjJpUf1KRCbTrcR7Zsol8MV
         Oc6NjARafUnZxtzcX0pP8N4iTNychzLH518/RqvPLqpxeu+JY57k2WvlznoitRvG8mwm
         M1Rw==
X-Google-Smtp-Source: AHgI3IYcRe3wIW9kBX8bDCesOGs4eqG5QEdDUrT6bTq55lNHWHcECKieUpmkkWiYe9mLdhGBtSpYsQ==
X-Received: by 2002:a81:8147:: with SMTP id r68mr8592233ywf.89.1550254478063;
        Fri, 15 Feb 2019 10:14:38 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:33c1])
        by smtp.gmail.com with ESMTPSA id 77sm2282676ywr.19.2019.02.15.10.14.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 10:14:37 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 5/6] mm: memcontrol: push down mem_cgroup_nr_lru_pages()
Date: Fri, 15 Feb 2019 13:14:24 -0500
Message-Id: <20190215181425.32624-6-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215181425.32624-1-hannes@cmpxchg.org>
References: <20190215181425.32624-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mem_cgroup_nr_lru_pages() is just a convenience wrapper around
memcg_page_state() that takes bitmasks of lru indexes and aggregates
the counts for those.

Replace callsites where the bitmask is simple enough with direct
memcg_page_state() call(s).

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 73eb8333bc73..6d0c3374669f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1354,7 +1354,7 @@ void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
 
 		for (i = 0; i < NR_LRU_LISTS; i++)
 			pr_cont(" %s:%luKB", mem_cgroup_lru_names[i],
-				K(mem_cgroup_nr_lru_pages(iter, BIT(i))));
+				K(memcg_page_state(iter, NR_LRU_BASE + i)));
 
 		pr_cont("\n");
 	}
@@ -2987,8 +2987,8 @@ static void accumulate_memcg_tree(struct mem_cgroup *memcg,
 				acc->events_array ? acc->events_array[i] : i);
 
 		for (i = 0; i < NR_LRU_LISTS; i++)
-			acc->lru_pages[i] +=
-				mem_cgroup_nr_lru_pages(mi, BIT(i));
+			acc->lru_pages[i] += memcg_page_state(mi,
+							      NR_LRU_BASE + i);
 	}
 }
 
@@ -3418,7 +3418,8 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 
 	for (i = 0; i < NR_LRU_LISTS; i++)
 		seq_printf(m, "%s %lu\n", mem_cgroup_lru_names[i],
-			   mem_cgroup_nr_lru_pages(memcg, BIT(i)) * PAGE_SIZE);
+			   memcg_page_state(memcg, NR_LRU_BASE + i) *
+			   PAGE_SIZE);
 
 	/* Hierarchical information */
 	memory = memsw = PAGE_COUNTER_MAX;
@@ -3909,8 +3910,8 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 
 	/* this should eventually include NR_UNSTABLE_NFS */
 	*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
-	*pfilepages = mem_cgroup_nr_lru_pages(memcg, (1 << LRU_INACTIVE_FILE) |
-						     (1 << LRU_ACTIVE_FILE));
+	*pfilepages = memcg_page_state(memcg, NR_INACTIVE_FILE) +
+		memcg_page_state(memcg, NR_ACTIVE_FILE);
 	*pheadroom = PAGE_COUNTER_MAX;
 
 	while ((parent = parent_mem_cgroup(memcg))) {
-- 
2.20.1

