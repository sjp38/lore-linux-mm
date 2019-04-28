Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9C5FC43219
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 07:44:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 285B6206BF
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 07:44:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bQFAEkIA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 285B6206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9803B6B0003; Sun, 28 Apr 2019 03:44:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92F0D6B0006; Sun, 28 Apr 2019 03:44:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D0CD6B0007; Sun, 28 Apr 2019 03:44:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA546B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 03:44:47 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id b37so5229300pgl.19
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 00:44:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id;
        bh=fmgS9UlbGCt7CJa9UBIEeXfiTJfawV94ps930rxsGJA=;
        b=kHVHwVle8femhMp3hzwhKN4bUaZXb2YlRLYqDvP25FInmZZWCi3aCTXXTBBFFALCNx
         tajlmMZFhgLLTHba8YsnZ65lQeXLYnhqmmZQIq8oR8RrAnmuCQIQaDIS5PBWoCpCY+1F
         /dVuq645wDTh/FrWyAdmNBeFCnU7dp9tq1fpQ3QlZpviYcy9aKepkgPzhNr6S5liSb3o
         rDh9FbTg8SJGbGG9TgeQvI8eOP+I+/IfMI1oIMqit39N/zwUd9LEHkZFqr7VUjBWQZPa
         yDNaQSEyhCOSfH0Q2nnF9ijRbztZ2iuFQANgsmCpdAw1j2VesPh2Ixz8SDBV3sq2gbai
         7bTg==
X-Gm-Message-State: APjAAAU8yAEVocsSi8e+YebZb5vLuYxxkgvn0u3SiyRZ7JMobmHUU0Q6
	Mea8HerV+TwG3ByyFRPHx1yOc8K31xDeJc4scnVgPHROM/7zJ8JtMcQGWrhid3HJPXAAQmsKCqk
	daZ+cqj51QQQ2ADR2iy1DjjMzy9khFWOeDsJR3vfbO3U2kUqLcpOPaG9ZOLnD3oyWEQ==
X-Received: by 2002:a63:5c24:: with SMTP id q36mr1126363pgb.314.1556437486638;
        Sun, 28 Apr 2019 00:44:46 -0700 (PDT)
X-Received: by 2002:a63:5c24:: with SMTP id q36mr1126292pgb.314.1556437484938;
        Sun, 28 Apr 2019 00:44:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556437484; cv=none;
        d=google.com; s=arc-20160816;
        b=oYDWc8yqNC3/TcJpKDfaEgd9sb4mSAy9S3g25mBxzB1IT7Vo7kRmH+Zsj9pGZy5J4U
         N35p+lEK28xlNnUkqTm8H4OjWT76NtSgJ1fB6EN39g5jyEkjKDeKxH76o8X42Lf/B2+o
         LChiylHn3wetWHxytCXMIw7NoAgtHJMwItSuVqsbFH0jfU/34pT7NpwL4MCQv/8k7Qnv
         IN7kl/a6+EbkVbGrNNDziFXmaRPmLoc0x412exm0EtQbmW5tCD23psXskTjjGsI9LAiM
         IGjeXb+fp+uUz3F281+FEbSa/mkrJXjHTETi2e8kuP/zU7Ch7Nn9ROUXEaZlLff5PT/R
         GgAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:to:from:dkim-signature;
        bh=fmgS9UlbGCt7CJa9UBIEeXfiTJfawV94ps930rxsGJA=;
        b=WIqyRSATAWBeBeIqXEzRDCxXNuvknTTiuUwugwEF+k+KapsMyMqZhld5SRFAON3Btl
         pYggIGwmbp/gRCNPcDFnfsYN096gROWv+jZY9Y6m+Y6URtY/HOwRiDGhWwDTR9L9pPt+
         8hRnSbuEWQuzgrQtKtKg2o9AauBgi5rsJtHIicB7EZ4L7xtttIUlRqg1QWGc6KZK/xlE
         wd+ZuDdu9USuOX8X2WYBJxcXlK+rCfKkOThDYy+5dAu4Mg0DSFOZfh4PYUi+PCsBnb1j
         L656oBb5PIE74vCtwOzPO78+VpEMM8L/n72pe8TKbMUg2228DkJL6G05iAUrA6T6P9Qh
         VMXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bQFAEkIA;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9sor5432524pgd.81.2019.04.28.00.44.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Apr 2019 00:44:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bQFAEkIA;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id;
        bh=fmgS9UlbGCt7CJa9UBIEeXfiTJfawV94ps930rxsGJA=;
        b=bQFAEkIAn7RfcwYpP7GXaWoO/I4KWf9s6Ja9uV1M4EnR9cazL+mC+G+JLNTwNkCn7l
         c4Zsv2QskDH/5nn9C0dMwhxhLQThWIfkTdhsP4ChH4DJhoECQjsxsNny42YqONzjsFV8
         bFrLFR7KGUvgmMkeCBEIB2aaIXFaAlwi8Z7hUL4p1UxL9KETnUkvFzI9HsIngCYmHt+j
         5hNmJKIj83O9YPS9PCe8H0c3ZQGkYOZlKHyuhhAiBoyVYYgaQjqDWyEuYIZ4Li5cS59C
         XQ7u1L1MEqvkL0ij7RXpMg5SQtfz6JYSPz8hPbK8MG7Utye1HUnuqJ1BkfGOuLjvdrFa
         RRDQ==
X-Google-Smtp-Source: APXvYqyVtufEHqFxbpe36g/d2fILEga/g2ilO1Ubg27A4UogCBgerj5qN/6U5VPIF5fFV2rkJWAN+A==
X-Received: by 2002:a65:524a:: with SMTP id q10mr51067765pgp.224.1556437484396;
        Sun, 28 Apr 2019 00:44:44 -0700 (PDT)
Received: from bj03382pcu.spreadtrum.com ([117.18.48.82])
        by smtp.gmail.com with ESMTPSA id z27sm1520081pfi.42.2019.04.28.00.44.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 28 Apr 2019 00:44:43 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Roman Gushchin <guro@fb.com>,
	Jeff Layton <jlayton@redhat.com>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [[repost]RFC PATCH] mm/workingset : judge file page activity via timestamp
Date: Sun, 28 Apr 2019 15:44:34 +0800
Message-Id: <1556437474-25319-1-git-send-email-huangzhaoyang@gmail.com>
X-Mailer: git-send-email 1.7.9.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>

this patch introduce timestamp into workingset's entry and judge if the page is
active or inactive via active_file/refault_ratio instead of refault distance.

The original thought is coming from the logs we got from trace_printk in this
patch, we can find about 1/5 of the file pages' refault are under the
scenario[1],which will be counted as inactive as they have a long refault distance
in between access. However, we can also know from the time information that the
page refault quickly as comparing to the average refault time which is calculated
by the number of active file and refault ratio. We want to save these kinds of
pages from evicted earlier as it used to be via setting it to ACTIVE instead.
The refault ratio is the value which can reflect lru's average file access
frequency in the past and provide the judge criteria for page's activation.

The patch is tested on an android system and reduce 30% of page faults, while
60% of the pages remain the original status as (refault_distance < active_file)
indicates. Pages status got from ftrace during the test can refer to [2].

[1]
system_server workingset_refault: WKST_ACT[0]:rft_dis 265976, act_file 34268 rft_ratio 3047 rft_time 0 avg_rft_time 11 refault 295592 eviction 29616 secs 97 pre_secs 97
HwBinder:922  workingset_refault: WKST_ACT[0]:rft_dis 264478, act_file 35037 rft_ratio 3070 rft_time 2 avg_rft_time 11 refault 310078 eviction 45600 secs 101 pre_secs 99

[2]
WKST_ACT[0]:   original--INACTIVE  commit--ACTIVE
WKST_ACT[1]:   original--ACTIVE    commit--ACTIVE
WKST_INACT[0]: original--INACTIVE  commit--INACTIVE
WKST_INACT[1]: original--ACTIVE    commit--INACTIVE

Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
---
 include/linux/mmzone.h |   1 +
 mm/workingset.c        | 129 ++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 113 insertions(+), 17 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fba7741..ca4ced6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -242,6 +242,7 @@ struct lruvec {
 	atomic_long_t			inactive_age;
 	/* Refaults at the time of last reclaim cycle */
 	unsigned long			refaults;
+	atomic_long_t			refaults_ratio;
 #ifdef CONFIG_MEMCG
 	struct pglist_data *pgdat;
 #endif
diff --git a/mm/workingset.c b/mm/workingset.c
index 0bedf67..fd2e5af 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -167,10 +167,19 @@
  * refault distance will immediately activate the refaulting page.
  */
 
+#ifdef CONFIG_64BIT
+#define EVICTION_SECS_POS_SHIFT 18
+#define EVICTION_SECS_SHRINK_SHIFT 4
+#define EVICTION_SECS_POS_MASK  ((1UL << EVICTION_SECS_POS_SHIFT) - 1)
+#else
+#define EVICTION_SECS_POS_SHIFT 0
+#define EVICTION_SECS_SHRINK_SHIFT 0
+#define NO_SECS_IN_WORKINGSET
+#endif
 #define EVICTION_SHIFT	((BITS_PER_LONG - BITS_PER_XA_VALUE) +	\
-			 1 + NODES_SHIFT + MEM_CGROUP_ID_SHIFT)
+			 1 + NODES_SHIFT + MEM_CGROUP_ID_SHIFT + \
+			 EVICTION_SECS_POS_SHIFT + EVICTION_SECS_SHRINK_SHIFT)
 #define EVICTION_MASK	(~0UL >> EVICTION_SHIFT)
-
 /*
  * Eviction timestamps need to be able to cover the full range of
  * actionable refaults. However, bits are tight in the xarray
@@ -180,12 +189,48 @@
  * evictions into coarser buckets by shaving off lower timestamp bits.
  */
 static unsigned int bucket_order __read_mostly;
-
+#ifdef NO_SECS_IN_WORKINGSET
+static void pack_secs(unsigned long *peviction) { }
+static unsigned int unpack_secs(unsigned long entry) {return 0; }
+#else
+static void pack_secs(unsigned long *peviction)
+{
+	unsigned int secs;
+	unsigned long eviction;
+	int order;
+	int secs_shrink_size;
+	struct timespec64 ts;
+
+	ktime_get_boottime_ts64(&ts);
+	secs = (unsigned int)ts.tv_sec ? (unsigned int)ts.tv_sec : 1;
+	order = get_count_order(secs);
+	secs_shrink_size = (order <= EVICTION_SECS_POS_SHIFT)
+		? 0 : (order - EVICTION_SECS_POS_SHIFT);
+
+	eviction = *peviction;
+	eviction = (eviction << EVICTION_SECS_POS_SHIFT)
+		| ((secs >> secs_shrink_size) & EVICTION_SECS_POS_MASK);
+	eviction = (eviction << EVICTION_SECS_SHRINK_SHIFT) | (secs_shrink_size & 0xf);
+	*peviction = eviction;
+}
+static unsigned int unpack_secs(unsigned long entry)
+{
+	unsigned int secs;
+	int secs_shrink_size;
+
+	secs_shrink_size = entry & ((1 << EVICTION_SECS_SHRINK_SHIFT) - 1);
+	entry >>= EVICTION_SECS_SHRINK_SHIFT;
+	secs = entry & EVICTION_SECS_POS_MASK;
+	secs = secs << secs_shrink_size;
+	return secs;
+}
+#endif
 static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction,
 			 bool workingset)
 {
 	eviction >>= bucket_order;
 	eviction &= EVICTION_MASK;
+	pack_secs(&eviction);
 	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
 	eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
 	eviction = (eviction << 1) | workingset;
@@ -194,11 +239,12 @@ static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction,
 }
 
 static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
-			  unsigned long *evictionp, bool *workingsetp)
+		unsigned long *evictionp, bool *workingsetp, unsigned int *prev_secs)
 {
 	unsigned long entry = xa_to_value(shadow);
 	int memcgid, nid;
 	bool workingset;
+	unsigned int secs;
 
 	workingset = entry & 1;
 	entry >>= 1;
@@ -206,11 +252,14 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
 	entry >>= NODES_SHIFT;
 	memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
 	entry >>= MEM_CGROUP_ID_SHIFT;
+	secs = unpack_secs(entry);
+	entry >>= (EVICTION_SECS_POS_SHIFT + EVICTION_SECS_SHRINK_SHIFT);
 
 	*memcgidp = memcgid;
 	*pgdat = NODE_DATA(nid);
 	*evictionp = entry << bucket_order;
 	*workingsetp = workingset;
+	*prev_secs = secs;
 }
 
 /**
@@ -257,8 +306,19 @@ void workingset_refault(struct page *page, void *shadow)
 	unsigned long refault;
 	bool workingset;
 	int memcgid;
+#ifndef NO_SECS_IN_WORKINGSET
+	unsigned long avg_refault_time;
+	unsigned long refaults_ratio;
+	unsigned long refault_time;
+	int tradition;
+	unsigned int prev_secs;
+	unsigned int secs;
+#endif
+	struct timespec64 ts;
+	ktime_get_boottime_ts64(&ts);
+	secs = (unsigned int)ts.tv_sec ? (unsigned int)ts.tv_sec : 1;
 
-	unpack_shadow(shadow, &memcgid, &pgdat, &eviction, &workingset);
+	unpack_shadow(shadow, &memcgid, &pgdat, &eviction, &workingset, &prev_secs);
 
 	rcu_read_lock();
 	/*
@@ -303,23 +363,57 @@ void workingset_refault(struct page *page, void *shadow)
 	refault_distance = (refault - eviction) & EVICTION_MASK;
 
 	inc_lruvec_state(lruvec, WORKINGSET_REFAULT);
-
+#ifndef NO_SECS_IN_WORKINGSET
+	refaults_ratio = (atomic_long_read(&lruvec->inactive_age) + 1) / secs;
+	atomic_long_set(&lruvec->refaults_ratio, refaults_ratio);
+	refault_time = secs - prev_secs;
+	avg_refault_time = active_file / refaults_ratio;
+	tradition = !!(refault_distance < active_file);
 	/*
-	 * Compare the distance to the existing workingset size. We
-	 * don't act on pages that couldn't stay resident even if all
-	 * the memory was available to the page cache.
+	 * What we are trying to solve here is
+	 * 1. extremely fast refault as refault_time == 0.
+	 * 2. quick file drop scenario, which has a big refault_distance but
+	 *    small refault_time comparing with the past refault ratio, which
+	 *    will be deemed as inactive in previous implementation.
 	 */
-	if (refault_distance > active_file)
+	if (refault_time && (((refault_time < avg_refault_time)
+		&& (avg_refault_time < 2 * refault_time))
+		|| (refault_time >= avg_refault_time))) {
+		trace_printk("WKST_INACT[%d]:rft_dis %ld, act %ld\
+				rft_ratio %ld rft_time %ld avg_rft_time %ld\
+				refault %ld eviction %ld secs %d pre_secs %d page %p\n",
+				tradition, refault_distance, active_file,
+				refaults_ratio, refault_time, avg_refault_time,
+				refault, eviction, secs, prev_secs, page);
 		goto out;
+	} else {
+#else
+	if (refault_distance < active_file) {
+#endif
 
-	SetPageActive(page);
-	atomic_long_inc(&lruvec->inactive_age);
-	inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
+		/*
+		 * Compare the distance to the existing workingset size. We
+		 * don't act on pages that couldn't stay resident even if all
+		 * the memory was available to the page cache.
+		 */
 
-	/* Page was active prior to eviction */
-	if (workingset) {
-		SetPageWorkingset(page);
-		inc_lruvec_state(lruvec, WORKINGSET_RESTORE);
+		SetPageActive(page);
+		atomic_long_inc(&lruvec->inactive_age);
+		inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
+
+		/* Page was active prior to eviction */
+		if (workingset) {
+			SetPageWorkingset(page);
+			inc_lruvec_state(lruvec, WORKINGSET_RESTORE);
+		}
+#ifndef NO_SECS_IN_WORKINGSET
+		trace_printk("WKST_ACT[%d]:rft_dis %ld, act %ld\
+				rft_ratio %ld rft_time %ld avg_rft_time %ld\
+				refault %ld eviction %ld secs %d pre_secs %d page %p\n",
+				tradition, refault_distance, active_file,
+				refaults_ratio, refault_time, avg_refault_time,
+				refault, eviction, secs, prev_secs, page);
+#endif
 	}
 out:
 	rcu_read_unlock();
@@ -548,6 +642,7 @@ static int __init workingset_init(void)
 	 * double the initial memory by using totalram_pages as-is.
 	 */
 	timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT;
+
 	max_order = fls_long(totalram_pages() - 1);
 	if (max_order > timestamp_bits)
 		bucket_order = max_order - timestamp_bits;
-- 
1.9.1

