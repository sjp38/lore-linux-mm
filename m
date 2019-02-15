Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB6F2C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7988D2192C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="b1VUPdwi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7988D2192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2466B8E0009; Fri, 15 Feb 2019 13:14:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CB738E0004; Fri, 15 Feb 2019 13:14:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B8D18E0009; Fri, 15 Feb 2019 13:14:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id D539C8E0004
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:14:40 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id t17so6403333ywc.23
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:14:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5xWYBy7FokRZPZ5ORH4t2tIovmpTYMvN2BW/u6oRAco=;
        b=ItsnI9nRI02Q9izBM2W05xcROq8MOnOdJRBSWFpLy5Z9uT3MHUXannCp7k+GxiJlz6
         fVL2C2tw9SdmQWh8zUcz/YbtG/fPFHf5F/+UFjNsLLAktsfxMKd8wMx5gu1yPv/0wkUz
         WNrTF3uYcZMPLS8mYwC0J6NKfN5jxX0ycnxeTEWdV9iMuaUOAiF3nsS8TbcV9F1R4Qsf
         hCl5yNtGWdlXVp+WLot/QMtoqOsGVS4USwcfjnqiZdeCLIruCivxZbSsuMkY/+Zc4INm
         F6wRtOIPnNzE61J+ca67gYd8TN9U32vS3myjjVEZPrBLmFA4iQzwuY8itT1bf6nGtvTT
         Bv4Q==
X-Gm-Message-State: AHQUAub6zNzVb3w5CzJ4T11M+n+OmGLdprjnaHojZDFQv8yb1O6EDV0M
	r6kydApKrhuGzs/oMlMlpC4oOwnNfbc9ihbK+Y9KOyNgJYHuXp+ElgRhC5T4AyP1U/dDG88xr1s
	cOXCApATjyFdlZOZoobxDrljqy4cDzBTFMFtsRvzVvD4fR+Jm0mypZW2g/5BsR33jvvwWXNtGzx
	Jdy23G0hrQr571NtqvNlNTQ3af5pgKUZjOLkLb34w/Rih1yQWHE7nzWCkM5kez/roSOIXPBUHxk
	CQ9XOJtOfk+ky+BuQJMm6uIuZlGf62HAIV1UDf5M8Cz1B5XAOMpVC2IDU0eJlAotBFvO2sVR4xn
	o4XRLqiDdxSyDLEcXfNbDQEcgf1I2WnHix+Np8JwV71/uGdsuprCD19al4S5Mt2sL11NBj+zkM8
	m
X-Received: by 2002:a81:1491:: with SMTP id 139mr9212091ywu.476.1550254480605;
        Fri, 15 Feb 2019 10:14:40 -0800 (PST)
X-Received: by 2002:a81:1491:: with SMTP id 139mr9212036ywu.476.1550254479873;
        Fri, 15 Feb 2019 10:14:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550254479; cv=none;
        d=google.com; s=arc-20160816;
        b=TmKtZDm/TViJKFWyLIXtl058WQ4a4K5HvZikz6ardPdWDPzHWdXfA5XYI+kkmuFPU5
         MceIO1YZJFT+G7JgsTktvDdzI0UqJ3Kid+ASj5cjol5sg2lw71+FMKJFsas39d8ugnHT
         wWr3RPMqiuovVBgV5vUm4czDQOO6QJ9ITeVqN/GYlZsjHUVqIjzJSpObKYnqd0atVgWD
         QHwARIUDJieeb8GxCWdPdeKzLBkRcyBLAl5hJB6Vj3cNX1tbOJBIMNyv5IWQ+gEYTT+j
         Zbc+43aChepES+qxeNBVo2Ssbl6Ep+dV2LUXnV86Q+H6eTBwTmHy5zHVPMdCEvxhc05v
         vlCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5xWYBy7FokRZPZ5ORH4t2tIovmpTYMvN2BW/u6oRAco=;
        b=L8OoxyxAZu0ZS5qwomufcbth1siAPp0VN2DcS71Ps78YXgdntvmSmXMCQsDcvtMz50
         BzSeoAKa3BdiqNoLiCW073ngfzmFGjpBNNHWnuNtJSqMVt85tWkkwn+8OjqAHff/LQWA
         P5Y+tKkwL/Okw+tI7tcJfESHCw37Rb9JveOFD32ZH7V1OSX0BjNa8hXWLXzux2Kr7/Ro
         HOVohX0YmEVVxCVUkIoP/GQ2AGUZsK3ddR3M4wuQhR9SOrtsoBu3WgiOLNhdUYf2XY2S
         fS8LPP8iV7+E/amXI+GLvSgu6uZ9X0sl3GWKKNXVjnC0GYYgPyXgWdW6qUsBajyCVL17
         0o6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=b1VUPdwi;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z83sor976918ywb.24.2019.02.15.10.14.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 10:14:39 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=b1VUPdwi;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=5xWYBy7FokRZPZ5ORH4t2tIovmpTYMvN2BW/u6oRAco=;
        b=b1VUPdwiUPbev9Zpm14NFF7dG9RjRJ3CzCdRRh5szC6PsrCzTDT8Xq0B2F1nEGlhxg
         qLhGQzYmivMBrSqb1WHcfnJaVtqKBqsYcBHRV4yQm+PMcovxgqEyKvjTF3SBy9eqKQbd
         Lm96Dn86Q1ft5hiblalQn3NM7tmzMYt1R3rWpT0M8h+pBwAqTSYMf91gdqc8HhOAu2QG
         +9shVyCnT2FUiU6uA36Dr3ebjESZRYa3f92YsgtnnKh4zE35w+MtNwG65NANGZLesYqd
         O0A1bV3uYF8ost+QXKnAa+CYQvmbBuk36tzQdSADml/ekVJPwD4FM3LK4Npp7pBx/UEc
         UsmA==
X-Google-Smtp-Source: AHgI3IalZFEfXkNtqFL/VZxIILPlv28xJ58YSrr+lhW3IaKqKL+TVYkZ/rvDyirah3zdTh0tQ48cFg==
X-Received: by 2002:a81:7a50:: with SMTP id v77mr8974055ywc.223.1550254479646;
        Fri, 15 Feb 2019 10:14:39 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:33c1])
        by smtp.gmail.com with ESMTPSA id j22sm1915745ywj.37.2019.02.15.10.14.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 10:14:39 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 6/6] mm: memcontrol: quarantine the mem_cgroup_[node_]nr_lru_pages() API
Date: Fri, 15 Feb 2019 13:14:25 -0500
Message-Id: <20190215181425.32624-7-hannes@cmpxchg.org>
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

Only memcg_numa_stat_show() uses those wrappers and the lru bitmasks,
group them together.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |  5 ----
 mm/memcontrol.c        | 67 +++++++++++++++++++++++-------------------
 2 files changed, 36 insertions(+), 36 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 842f9189537b..a93921ba7bd6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -247,11 +247,6 @@ struct lruvec {
 #endif
 };
 
-/* Mask used at gathering information at once (see memcontrol.c) */
-#define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
-#define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
-#define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)
-
 /* Isolate unmapped file */
 #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x2)
 /* Isolate for asynchronous migration */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6d0c3374669f..20fb3de8bde4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -718,37 +718,6 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 	__this_cpu_add(memcg->stat_cpu->nr_page_events, nr_pages);
 }
 
-static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
-					   int nid, unsigned int lru_mask)
-{
-	struct lruvec *lruvec = mem_cgroup_lruvec(NODE_DATA(nid), memcg);
-	unsigned long nr = 0;
-	enum lru_list lru;
-
-	VM_BUG_ON((unsigned)nid >= nr_node_ids);
-
-	for_each_lru(lru) {
-		if (!(BIT(lru) & lru_mask))
-			continue;
-		nr += lruvec_page_state(lruvec, NR_LRU_BASE + lru);
-	}
-	return nr;
-}
-
-static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
-			unsigned int lru_mask)
-{
-	unsigned long nr = 0;
-	enum lru_list lru;
-
-	for_each_lru(lru) {
-		if (!(BIT(lru) & lru_mask))
-			continue;
-		nr += memcg_page_state(memcg, NR_LRU_BASE + lru);
-	}
-	return nr;
-}
-
 static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 				       enum mem_cgroup_events_target target)
 {
@@ -3328,6 +3297,42 @@ static int mem_cgroup_move_charge_write(struct cgroup_subsys_state *css,
 #endif
 
 #ifdef CONFIG_NUMA
+
+#define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
+#define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
+#define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)
+
+static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
+					   int nid, unsigned int lru_mask)
+{
+	struct lruvec *lruvec = mem_cgroup_lruvec(NODE_DATA(nid), memcg);
+	unsigned long nr = 0;
+	enum lru_list lru;
+
+	VM_BUG_ON((unsigned)nid >= nr_node_ids);
+
+	for_each_lru(lru) {
+		if (!(BIT(lru) & lru_mask))
+			continue;
+		nr += lruvec_page_state(lruvec, NR_LRU_BASE + lru);
+	}
+	return nr;
+}
+
+static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
+					     unsigned int lru_mask)
+{
+	unsigned long nr = 0;
+	enum lru_list lru;
+
+	for_each_lru(lru) {
+		if (!(BIT(lru) & lru_mask))
+			continue;
+		nr += memcg_page_state(memcg, NR_LRU_BASE + lru);
+	}
+	return nr;
+}
+
 static int memcg_numa_stat_show(struct seq_file *m, void *v)
 {
 	struct numa_stat {
-- 
2.20.1

