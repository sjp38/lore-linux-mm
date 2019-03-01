Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FF7DC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 06:24:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EEF6218B0
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 06:24:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="asrjgDHD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EEF6218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 675B38E0003; Fri,  1 Mar 2019 01:24:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 624DB8E0001; Fri,  1 Mar 2019 01:24:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53B768E0003; Fri,  1 Mar 2019 01:24:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1338B8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 01:24:52 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id o7so18089351pfi.23
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 22:24:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=8tvRd6fIqSB+oUvP7zx+obfq/b3yUnFPtsGhX5I/8tw=;
        b=J/JvWCDRySBlYZp6nJeklP9TCUuEm4QLEdmZqPW3aUYYiiNBnSOeA21Xlu4329EX+8
         lo1bXqfVUihadoxkgbtNmZV+2cnuGpTVjqH1mdKCmo8Gr0MdyTTuUFaq0UAj4Wqk4iwp
         KBU0HW7nDUZIQOZOz+D32h6tvB2P8PXU4jD59x/lWGCpB+MVTQ2yawff7UTZjAbntZTY
         W2fXbuDXSXFMDV/x6juq0mBYb44lan6auPVayZQuyrtAsOXRo2UNHkUx4Sr4OdQ90T+Q
         uxuONdp4Zq/riNBIMbhtg3Md6TSmKKGg7ZlgaFYb6sML2CUkUQlLOG6D736V3knzW7C2
         b5uA==
X-Gm-Message-State: APjAAAUPb9RlTLi9XzeIQ1LXvaRDoRKscexkWMKA7BwOJdr2K4rpDFck
	fAY2e/DfYRBdA7xKFLD9j0fcQTaK9MpKXXWkgkygxbaWvAq1bJ292GeZF4LHAe7X64Gy+SgUQ5B
	T9rXb3aiI2ixmQzLyrIRq/wfWZqkZxlYOfwtyYhmCJh0H3GUNGRzYYah809KdYf0lCFeFnHyJl8
	/hD91AnOrpUBBkk22fkwn7A/P9t2CJ1/bRC/qXIqVCEfNNPf0q0J95NXa1NrGvk2jH+AqAHrjLD
	8er3UqfCCj5MlB4DPPWdGf0yWEjXrahryAflcrZMB+6CTCpH7EspGk9G97G7YQO7tRcjA4pgsRg
	RBHygH3IL1QTzqaA2en4eqFL9kSYuB+AFJjiPxY8Jp1c0BMjaUothoWlcGmT+utqoPPASbYwDjO
	u
X-Received: by 2002:a63:1a5d:: with SMTP id a29mr3045666pgm.369.1551421491670;
        Thu, 28 Feb 2019 22:24:51 -0800 (PST)
X-Received: by 2002:a63:1a5d:: with SMTP id a29mr3045577pgm.369.1551421489862;
        Thu, 28 Feb 2019 22:24:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551421489; cv=none;
        d=google.com; s=arc-20160816;
        b=AK9mhMxdNt5EsjyhZ7VxjCYwZNJxV8XJv56dZgYmK6g8AjCEmUY91fnM0edpFBxWGQ
         h524N1Via7++SNczn+pU3I2A/zYXl7rEz0aWoKxqAhOxrXALJ7DgYWvQSMpswesxD8Rr
         8YWep5ZdeqqjMs2hfSFY4bdkbZZ32kBhmeoXcQJK8onxuYhidSSQ/9MzWbfzPm/AW0bV
         pTLSPs0M/42hhKDVksyZJLnbhsuVZnS+KhAA3EvxoTrOU6URQAW6rQmI4yWt+RPd/wA7
         grdq+pFeuFrKXPSveBHiZrFvfMOJjXD+ltZhMjfUZYq//Ry/mEoQhJtZa72B9DlxFeKT
         sKCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=8tvRd6fIqSB+oUvP7zx+obfq/b3yUnFPtsGhX5I/8tw=;
        b=ZEfzB4ehu5yZf+MmDAeC9+pRVy1+7ATg5siRyPgwNb0A3cJ2foO7fErff+tMA7OEMa
         MhQs3tNZYzNgCael3ucWTOoHLRuhBKTpuL4tMloHQTzFuXm16TzBpG4FF8S12GVG+Kl4
         1+/YX6hYg0iORYqyxCMKwY3QE1BnE3B+s9gECCeO9AreXV05akeTBhlqZzUzMAuKmKhz
         PXpqQjdS5IwkPq1E9z99T2rjg1wjaqAatRgDq+UnYjmk1ieWLzVMZnnPM2wdzRHsssul
         0A+guSEald5PP5OSbFOWD+dhwQ4/2zInj35mJ1XjajrAgiHWx45aJ6jVjJCXzAPm7j1g
         yo0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=asrjgDHD;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u44sor32079291pgn.17.2019.02.28.22.24.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 22:24:49 -0800 (PST)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=asrjgDHD;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=8tvRd6fIqSB+oUvP7zx+obfq/b3yUnFPtsGhX5I/8tw=;
        b=asrjgDHDlJesfSEO0PZMELjUGD4bdP7kiKSmL1/IlWEuQYl7vKWFdaHPqyMLBr7JTX
         sCxcXmN78/Mpiqfi2DjyKNRhWeZQwUjyQVD65NZXt7dA4tpywWw2Bhb+yGL9eHrIWXbO
         q6SjGtyjsAfMtyt9PqoW1kvKNmT7HKL426jxB8ZTNeGTf+5x6rDPGENTk8gaBMe4zEj9
         b/PxHVXOZNAyDeAErykyLnG86/iZAnD0t8xHLOhk9OaDgYLnMIBm1ai7AnaaLGx6CDwB
         E361LRqpeyeoZm4f29Z/xLgfKRu2qHrS862UyP5FgrPWH5I/kb4Kml+W95TA6OVDrmy9
         TwuA==
X-Google-Smtp-Source: APXvYqwfRMjnThftvGhj6v3EH0/e+xZfINP3JV7v+UgAMwVJCin7+8dVBCj9cpygYWDcbJ1bU35+8w==
X-Received: by 2002:a63:dc54:: with SMTP id f20mr3331481pgj.410.1551421489294;
        Thu, 28 Feb 2019 22:24:49 -0800 (PST)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id x8sm42023713pfe.1.2019.02.28.22.24.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 22:24:48 -0800 (PST)
From: Yafang Shao <laoar.shao@gmail.com>
To: vbabka@suse.cz,
	mhocko@suse.com,
	jrdr.linux@gmail.com
Cc: akpm@linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v2] mm: vmscan: add tracepoints for node reclaim
Date: Fri,  1 Mar 2019 14:24:11 +0800
Message-Id: <1551421452-5385-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the page alloc fast path, it may do node reclaim, which may cause
latency spike.
We should add tracepoint for this event, and also measure the latency
it causes.

So bellow two tracepoints are introduced,
	mm_vmscan_node_reclaim_begin
	mm_vmscan_node_reclaim_end

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/trace/events/vmscan.h | 32 ++++++++++++++++++++++++++++++++
 mm/vmscan.c                   |  6 ++++++
 2 files changed, 38 insertions(+)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a1cb913..c1ddf28 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -465,6 +465,38 @@
 		__entry->ratio,
 		show_reclaim_flags(__entry->reclaim_flags))
 );
+
+TRACE_EVENT(mm_vmscan_node_reclaim_begin,
+
+	TP_PROTO(int nid, int order, gfp_t gfp_flags),
+
+	TP_ARGS(nid, order, gfp_flags),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(int, order)
+		__field(gfp_t, gfp_flags)
+	),
+
+	TP_fast_assign(
+		__entry->nid = nid;
+		__entry->order = order;
+		__entry->gfp_flags = gfp_flags;
+	),
+
+	TP_printk("nid=%d order=%d gfp_flags=%s",
+		__entry->nid,
+		__entry->order,
+		show_gfp_flags(__entry->gfp_flags))
+);
+
+DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_node_reclaim_end,
+
+	TP_PROTO(unsigned long nr_reclaimed),
+
+	TP_ARGS(nr_reclaimed)
+);
+
 #endif /* _TRACE_VMSCAN_H */
 
 /* This part must be outside protection */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ac4806f..2bee5d1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -4241,6 +4241,9 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.reclaim_idx = gfp_zone(gfp_mask),
 	};
 
+	trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
+					   sc.gfp_mask);
+
 	cond_resched();
 	fs_reclaim_acquire(sc.gfp_mask);
 	/*
@@ -4267,6 +4270,9 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	current->flags &= ~PF_SWAPWRITE;
 	memalloc_noreclaim_restore(noreclaim_flag);
 	fs_reclaim_release(sc.gfp_mask);
+
+	trace_mm_vmscan_node_reclaim_end(sc.nr_reclaimed);
+
 	return sc.nr_reclaimed >= nr_pages;
 }
 
-- 
1.8.3.1

