Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE978C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:12:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C75B20857
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:12:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="R5oPG4fi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C75B20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19BC96B0007; Tue,  9 Apr 2019 06:12:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14CAC6B000C; Tue,  9 Apr 2019 06:12:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03BF76B000D; Tue,  9 Apr 2019 06:12:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1CB06B0007
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 06:12:06 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q18so12040971pll.16
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 03:12:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=kR/WYu04whmVY+fiZg5v0EICJidMNyAzVyli+JbH0e4=;
        b=Byw5kb0j3om7kRzMPIrd5CeSj4caqcJVk7w08nL54p1bxOp3Q1mhk0D98h2EmawsmW
         xEX15fTwVMG5IzsH96ct8K9WKKWOoAdLVXfmWfTvLNaNJoFQ0jFKGhNXGiQgRHC5VuWa
         7aSSJMC/P0HhD3Twvmhx56ukLCPHsnM2ZJTEGIF1pYaBAcOnxW8o6ajsxbYLxN+qCQx1
         KB14hdfxGtPzMbXczNq+iti5AReo+qts4PJWCVggGgvB7qclRLQiacJ1sCzvKTzpaEO7
         oAAvCxj212jhz33ZwSVZOx0tmvsz0+HLdxipHuHkk1XptLwPNpFrLSQ+M1Co32u/9qPM
         gi4Q==
X-Gm-Message-State: APjAAAXkWXpNtKJ5ehKYcBXUdwgpS4uSDh4HbjZjjXHDL1eyWArLZ/xn
	5nW1Hm2JmcNucWV5xiEQDzi7UlW6rdmYAavdhXts9FaHBkr/g3NA77P171072SA//+c4qexbFpI
	IYBhtZZMnGO3Gd1xWH10WMiTnE8KaJqSCPFl3K+O7N3HjQ5Xfh45HXKrF5QBzqRbDMA==
X-Received: by 2002:a17:902:1101:: with SMTP id d1mr18970718pla.16.1554804726241;
        Tue, 09 Apr 2019 03:12:06 -0700 (PDT)
X-Received: by 2002:a17:902:1101:: with SMTP id d1mr18970577pla.16.1554804724789;
        Tue, 09 Apr 2019 03:12:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554804724; cv=none;
        d=google.com; s=arc-20160816;
        b=l8U+5+tOLEmCG2HH+FUz3rP1SoKak6yk3wHJ/gp3rt9KMIr3LpNSL3QQcMPIAU/ltT
         EXPXx59mmoA5VmXuZ1No5dxQgfRY8N2wU2s4g9WlWXEpY/n/DBe3cLlhDgvQCWOFO+8w
         F1Pn0kCoGoNU6hIEV3eHt7kRi6bOm3l+Gp3vl5zUuvFs/gV/kbaUrPPp6uPjLtUly1l8
         cxvOX3OllT0njC3/QMqXKm1TvNPa1EpDVKVLybQ0gV3Smz2HddhNxzbe5ufhz3fT5faI
         z15L/RTqokFCq9vHkfwGDJ0kxMKMpcw5g5d7Nv4xKbJdUECX7hJE9ZCeFvW3+gTCq79q
         7yEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=kR/WYu04whmVY+fiZg5v0EICJidMNyAzVyli+JbH0e4=;
        b=vi1y/+HGgMnyXoO1zI7j3xEHEsIE/cjW2fMUfCNWCwaYcgOdzUQ/eVAI7EmXBy4E3b
         w+2VOMGbq54eze77ESbaWiuo/I1kaCKVkXHwy1x3y03O0ZdYET8dQXr1HrYzen0fVtT4
         0q5F5vMZwxq+NEQgox5egpO4gR9rNoj9V1JbZDL4yst0YkWBl8MkrsV+C7fFuOqzn2oK
         b0hMKfkY5UyNdP1Vs5ihxUNu4nMQYWa8t0wZwWdu0az3CCnYAYvEkTvo5/ceWM+lkiT4
         ZcwpUgjQtl3pUjhgBolSNKmY63AMSs/Lq+5XIMiUThNmOQreacVvvt+IYwlOJnG0MdTg
         IRmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=R5oPG4fi;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k11sor36471603plt.36.2019.04.09.03.12.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 03:12:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=R5oPG4fi;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=kR/WYu04whmVY+fiZg5v0EICJidMNyAzVyli+JbH0e4=;
        b=R5oPG4fi53Y2+InXX6Q7DtCDxJnraev67W9SjAqjYuUKIPAyrLtzdFCBo57h98zvi7
         yZQDMu6d3JgTOfubySaq3jl3s3PRXacHvv/Hrnfk0d5NtZTQLbTAHJtUmEQ7ht6+qsLj
         4dBAFPKkaBRF5YTpKR1gf0WFN7m+lvOsFJmp2wI/dKDLbleh42swIGzTbathtfQs2aqN
         pLBlTYx9LlznDm1iz89qw1nv2yn5Tdl95eppCJt+LHtth/W1aXvUIgZ2lXXFSpoKzt6h
         IMcIB4TKbuC/NSWIga6U5UWAUg+bIvze+BJRpxtNLSYzYLS+5zaK1B+324LGvdhR2YOe
         5u5g==
X-Google-Smtp-Source: APXvYqyNkzhYVithZXgfgiXg33aGYlWcxz2VW+xG0BFVZ3ori5Z15dSB0kZCj9bBcJ3lNPVn5bbOog==
X-Received: by 2002:a17:902:be04:: with SMTP id r4mr36715533pls.218.1554804724438;
        Tue, 09 Apr 2019 03:12:04 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id a3sm53107589pfn.182.2019.04.09.03.12.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 03:12:03 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/vmscan: expose cgroup_ino for memcg reclaim tracepoints
Date: Tue,  9 Apr 2019 18:11:40 +0800
Message-Id: <1554804700-7813-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We can use the exposed cgroup_ino to trace specified cgroup.

For example,
step 1, get the inode of the specified cgroup
	$ ls -di /tmp/cgroupv2/foo
step 2, set this inode into tracepoint filter to trace this cgroup only
	(assume the inode is 11)
	$ cd /sys/kernel/debug/tracing/events/vmscan/
	$ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_begin/filter
	$ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_end/filter

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/trace/events/vmscan.h | 71 +++++++++++++++++++++++++++++++++++--------
 mm/vmscan.c                   | 18 ++++++++---
 2 files changed, 72 insertions(+), 17 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index c27a563..3be0023 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -133,18 +133,43 @@
 );
 
 #ifdef CONFIG_MEMCG
-DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
+DECLARE_EVENT_CLASS(mm_vmscan_memcg_reclaim_begin_template,
 
-	TP_PROTO(int order, gfp_t gfp_flags),
+	TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
 
-	TP_ARGS(order, gfp_flags)
+	TP_ARGS(cgroup_ino, order, gfp_flags),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, cgroup_ino)
+		__field(int, order)
+		__field(gfp_t, gfp_flags)
+	),
+
+	TP_fast_assign(
+		__entry->cgroup_ino	= cgroup_ino;
+		__entry->order		= order;
+		__entry->gfp_flags	= gfp_flags;
+	),
+
+	TP_printk("cgroup_ino=%u order=%d gfp_flags=%s",
+		__entry->cgroup_ino, __entry->order,
+		show_gfp_flags(__entry->gfp_flags))
 );
 
-DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
+DEFINE_EVENT(mm_vmscan_memcg_reclaim_begin_template,
+	mm_vmscan_memcg_reclaim_begin,
 
-	TP_PROTO(int order, gfp_t gfp_flags),
+	TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
 
-	TP_ARGS(order, gfp_flags)
+	TP_ARGS(cgroup_ino, order, gfp_flags)
+);
+
+DEFINE_EVENT(mm_vmscan_memcg_reclaim_begin_template,
+	mm_vmscan_memcg_softlimit_reclaim_begin,
+
+	TP_PROTO(unsigned int cgroup_ino, int order, gfp_t gfp_flags),
+
+	TP_ARGS(cgroup_ino, order, gfp_flags)
 );
 #endif /* CONFIG_MEMCG */
 
@@ -173,18 +198,40 @@
 );
 
 #ifdef CONFIG_MEMCG
-DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_reclaim_end,
+DECLARE_EVENT_CLASS(mm_vmscan_memcg_reclaim_end_template,
 
-	TP_PROTO(unsigned long nr_reclaimed),
+	TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
 
-	TP_ARGS(nr_reclaimed)
+	TP_ARGS(cgroup_ino, nr_reclaimed),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, cgroup_ino)
+		__field(unsigned long, nr_reclaimed)
+	),
+
+	TP_fast_assign(
+		__entry->cgroup_ino	= cgroup_ino;
+		__entry->nr_reclaimed	= nr_reclaimed;
+	),
+
+	TP_printk("cgroup_ino=%u nr_reclaimed=%lu",
+		__entry->cgroup_ino, __entry->nr_reclaimed)
 );
 
-DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_reclaim_end,
+DEFINE_EVENT(mm_vmscan_memcg_reclaim_end_template,
+	mm_vmscan_memcg_reclaim_end,
 
-	TP_PROTO(unsigned long nr_reclaimed),
+	TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
 
-	TP_ARGS(nr_reclaimed)
+	TP_ARGS(cgroup_ino, nr_reclaimed)
+);
+
+DEFINE_EVENT(mm_vmscan_memcg_reclaim_end_template,
+	mm_vmscan_memcg_softlimit_reclaim_end,
+
+	TP_PROTO(unsigned int cgroup_ino, unsigned long nr_reclaimed),
+
+	TP_ARGS(cgroup_ino, nr_reclaimed)
 );
 #endif /* CONFIG_MEMCG */
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 347c9b3..15a9eb9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3268,8 +3268,10 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
-	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
-						      sc.gfp_mask);
+	trace_mm_vmscan_memcg_softlimit_reclaim_begin(
+				cgroup_ino(memcg->css.cgroup),
+				sc.order,
+				sc.gfp_mask);
 
 	/*
 	 * NOTE: Although we can get the priority field, using it
@@ -3280,7 +3282,9 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 	 */
 	shrink_node_memcg(pgdat, memcg, &sc);
 
-	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
+	trace_mm_vmscan_memcg_softlimit_reclaim_end(
+				cgroup_ino(memcg->css.cgroup),
+				sc.nr_reclaimed);
 
 	*nr_scanned = sc.nr_scanned;
 	return sc.nr_reclaimed;
@@ -3318,7 +3322,9 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	zonelist = &NODE_DATA(nid)->node_zonelists[ZONELIST_FALLBACK];
 
-	trace_mm_vmscan_memcg_reclaim_begin(0, sc.gfp_mask);
+	trace_mm_vmscan_memcg_reclaim_begin(
+				cgroup_ino(memcg->css.cgroup),
+				0, sc.gfp_mask);
 
 	psi_memstall_enter(&pflags);
 	noreclaim_flag = memalloc_noreclaim_save();
@@ -3328,7 +3334,9 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	memalloc_noreclaim_restore(noreclaim_flag);
 	psi_memstall_leave(&pflags);
 
-	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
+	trace_mm_vmscan_memcg_reclaim_end(
+				cgroup_ino(memcg->css.cgroup),
+				nr_reclaimed);
 
 	return nr_reclaimed;
 }
-- 
1.8.3.1

