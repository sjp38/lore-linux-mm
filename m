Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4D00C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:00:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32518217F4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:00:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eQ8CaCgL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32518217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A3BD6B0003; Thu, 11 Apr 2019 08:00:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9533C6B0008; Thu, 11 Apr 2019 08:00:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F56E6B000A; Thu, 11 Apr 2019 08:00:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4016A6B0003
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:00:16 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x9so3980982pln.0
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 05:00:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=mOz4LJIx6oY4+IvkYn925JGORlAdzALmC6ZHeKJ/DLk=;
        b=aqyuAIOdymw84kSKLb1h8hn88xHs2mzVVu0QlF4yUybFoyfqm9KcTO+pCbyUDNHzRP
         96iVSpYB9lrxML6i16M0oo7hKA73Q10osF660q5C70n+j8WXsZ2YhJFzIGUJHnadDw1/
         IO7MOC2ZN+p4qhYxEH9k3sXmoe6QivbZc66uyCvc/FQxuenJKzQC62027nPTrVFPfoNB
         OGrFX2BZVfCp9R7xRcdAX/E6cI0SmFZBgdHCWjsSLx/i7A3TGtNGRF76+t83Ka8k9X6O
         x0umCudo95bMT1WYpyT0OlEuD5nhjI6kW0hc1MxEORLFPIn3gaZF5ePuhpok1P6XKfsZ
         9lHg==
X-Gm-Message-State: APjAAAVh9Ra8ZmJNaiKFw+fiNdWdTvoiiEJwoPNgz3wQ8jCZTWxnRdwL
	SI46VmdR6mSC+MCxTYs5u+1rU0k17PJGH1HJb2k/GJA87zZ5GMINdrwjMe6mylb1Pv6XqfclQAO
	ZFcgXqhAb6jpKhM8hjBRZda47CmZqpwqon1+oh2AIgk1O9yGc9hVTCaUXFKaIipJwuw==
X-Received: by 2002:a63:1003:: with SMTP id f3mr45189487pgl.227.1554984015665;
        Thu, 11 Apr 2019 05:00:15 -0700 (PDT)
X-Received: by 2002:a63:1003:: with SMTP id f3mr45189315pgl.227.1554984013729;
        Thu, 11 Apr 2019 05:00:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554984013; cv=none;
        d=google.com; s=arc-20160816;
        b=N8vfhaHS4hVGwe9/njpExSt4rybSFbupURex082sV/oR30dfQ51J9b4QZAHHzFKmZD
         1Jh7jW3KPaWllMnlVTXvot3ZJ6bCy96B1jxZiO9QoG0x/SP6F7BqFLO2pVnqwhcgPVPa
         jR+PKLpqfLUP5ao9NFhXoIiC6g+tYkzxrJPpaf4MJK4ln7uaK7yAQKYJ4fsrD5Wbk3aq
         ICubqpttjqMolmi5B+UNo8Ffvu37zW5t7n5DGoSFs52x0eJb7o2MnW8y2yc2+/3uxXHr
         uT4Be+TfRXUMbgeA1u2NGL8JXP5c4Pbsym4aCRgh0ywbStfiFYZReipX4XREA8hKaN8G
         3B2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=mOz4LJIx6oY4+IvkYn925JGORlAdzALmC6ZHeKJ/DLk=;
        b=jxukg9wh27oNFdgraOKiOILUZlihQ4THRM4CkN21si2sjnVrloQFk6VhNDn+lLtN5x
         8IarcNDymknHYq7L9hEfGlu3PYhrTwQ4zx6t4exrCB801aiFMvEdYHdPwSFGPDTzInHX
         BmJ/ckNYIyPe32xwpiN1ElPbPXJ+Hex82OL6+/Np4JzHvuE/WS6Wpp7pTaSMknJ+68tA
         XqJEwS704rfWT6TPgw3tdbogOwKiYBAkq/qjLFAD5zkyix7p/OMpbH1irjT2ymB5zYcN
         kIFByT6tWvJIRkGegzo1WrrAFVOwBBGXRASWFufFPTQZEGvC2e+rAfa1Muk2JGtD6TRR
         SabA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eQ8CaCgL;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18sor32862497pgm.1.2019.04.11.05.00.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 05:00:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eQ8CaCgL;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=mOz4LJIx6oY4+IvkYn925JGORlAdzALmC6ZHeKJ/DLk=;
        b=eQ8CaCgLblUsBaqcaciU8fINUxHKrT3aXWX21gzx2XQhWfNpR/Vq8veZ11M3ozduGq
         fvd02vf6WZB6mQ/W/DlR6IbRaQmCe9wgafEb0k9J6/VtKKY5iQLxOoi4iLWdmlzk2CLe
         S1z+PnQFFoTaVDH/yMXPWtsmm9GOvjoyBIH5PZiDpLsh3Rx3pgGtBJOl+C/thS8VA1yF
         bKVCkNIf3FU9AcAZmUOcPyz6FFnOwBSg0shZWRB8Jlo3SPWxNVnyAs1RkXlY4a0TqH45
         CSWSZKV4PfRzuXY/22WdiVUseEopI6ehHlDkdUEplfb97BQK56hZT2UXl+XysfuOLjwj
         zMnQ==
X-Google-Smtp-Source: APXvYqyhYUF8DoaSmRWlwExBWvZgKoVLZuaHcaZU9QW+jcBPKYZZljshBE8eC9Ux8uba3sIBcjB0SQ==
X-Received: by 2002:a65:5682:: with SMTP id v2mr47372105pgs.100.1554984013348;
        Thu, 11 Apr 2019 05:00:13 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id h19sm61863210pfd.130.2019.04.11.05.00.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 05:00:12 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: hannes@cmpxchg.org,
	chris@chrisdown.name,
	mhocko@kernel.org
Cc: akpm@linux-foundation.org,
	cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/memcg: add allocstall to memory.stat
Date: Thu, 11 Apr 2019 19:59:51 +0800
Message-Id: <1554983991-16769-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The current item 'pgscan' is for pages in the memcg,
which indicates how many pages owned by this memcg are scanned.
While these pages may not scanned by the taskes in this memcg, even for
PGSCAN_DIRECT.

Sometimes we need an item to indicate whehter the tasks in this memcg
under memory pressure or not.
So this new item allocstall is added into memory.stat.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 Documentation/admin-guide/cgroup-v2.rst |  3 +++
 include/linux/memcontrol.h              | 18 ++++++++++++++++++
 mm/memcontrol.c                         | 18 +-----------------
 mm/vmscan.c                             |  2 ++
 4 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 19c4e78..a06f17a 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1221,6 +1221,9 @@ PAGE_SIZE multiple when read back.
 		Part of "slab" that cannot be reclaimed on memory
 		pressure.
 
+          allocstall
+                The number of direct reclaim the tasks in this memcg entering
+
 	  pgfault
 		Total number of page faults incurred
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1565831..7fe9c57 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -45,6 +45,7 @@ enum memcg_stat_item {
 	MEMCG_SOCK,
 	/* XXX: why are these zone and not node counters? */
 	MEMCG_KERNEL_STACK_KB,
+	MEMCG_ALLOCSTALL,
 	MEMCG_NR_STAT,
 };
 
@@ -412,6 +413,23 @@ static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
 
 struct mem_cgroup *get_mem_cgroup_from_page(struct page *page);
 
+/**
+ * If current->active_memcg is non-NULL, do not fallback to current->mm->memcg.
+ */
+static __always_inline struct mem_cgroup *get_mem_cgroup_from_current(void)
+{
+	if (unlikely(current->active_memcg)) {
+		struct mem_cgroup *memcg = root_mem_cgroup;
+
+		rcu_read_lock();
+		if (css_tryget_online(&current->active_memcg->css))
+			memcg = current->active_memcg;
+		rcu_read_unlock();
+		return memcg;
+	}
+	return get_mem_cgroup_from_mm(current->mm);
+}
+
 static inline
 struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
 	return css ? container_of(css, struct mem_cgroup, css) : NULL;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 10af4dd..780659f9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -853,23 +853,6 @@ struct mem_cgroup *get_mem_cgroup_from_page(struct page *page)
 EXPORT_SYMBOL(get_mem_cgroup_from_page);
 
 /**
- * If current->active_memcg is non-NULL, do not fallback to current->mm->memcg.
- */
-static __always_inline struct mem_cgroup *get_mem_cgroup_from_current(void)
-{
-	if (unlikely(current->active_memcg)) {
-		struct mem_cgroup *memcg = root_mem_cgroup;
-
-		rcu_read_lock();
-		if (css_tryget_online(&current->active_memcg->css))
-			memcg = current->active_memcg;
-		rcu_read_unlock();
-		return memcg;
-	}
-	return get_mem_cgroup_from_mm(current->mm);
-}
-
-/**
  * mem_cgroup_iter - iterate over memory cgroup hierarchy
  * @root: hierarchy root
  * @prev: previously returned memcg, NULL on first invocation
@@ -5624,6 +5607,7 @@ static int memory_stat_show(struct seq_file *m, void *v)
 
 	/* Accumulated memory events */
 
+	seq_printf(m, "allocstall %lu\n", acc.vmevents[MEMCG_ALLOCSTALL]);
 	seq_printf(m, "pgfault %lu\n", acc.vmevents[PGFAULT]);
 	seq_printf(m, "pgmajfault %lu\n", acc.vmevents[PGMAJFAULT]);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 347c9b3..3ff8b1b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3024,6 +3024,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	if (global_reclaim(sc))
 		__count_zid_vm_events(ALLOCSTALL, sc->reclaim_idx, 1);
 
+	count_memcg_events(get_mem_cgroup_from_current(), MEMCG_ALLOCSTALL, 1);
+
 	do {
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
 				sc->priority);
-- 
1.8.3.1

