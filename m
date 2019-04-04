Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DB53C10F0B
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 03:30:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 377CE2133D
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 03:30:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Bs+UaaYK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 377CE2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AEDB6B000C; Wed,  3 Apr 2019 23:30:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95EA96B000D; Wed,  3 Apr 2019 23:30:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 876546B0266; Wed,  3 Apr 2019 23:30:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 468946B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 23:30:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d33so888149pla.19
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 20:30:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id;
        bh=lv8NVbJO6cxJt5xlEdH0XCLVCT+ImQmsAWGyClGMj7s=;
        b=aQVpM4kYZuqVpQZCHM26q1aFXBPiNJp5SySjPu/2Kt7K43LxJVHYajZ+xaPUeBWY4H
         CWiKrdLu3wQKvqSC53QfWUoHOEa3KEwV4t66eedTVz/Cl3ZQxpmL+Cp465BdkCo05rJO
         nC/4DuWiZzs7DticWq5UUYhRlVJrXrgm0Ph5eE3i8DBRaC8auL996Q7Pd8TQY2/7jW+7
         erE04SPCoeXYgWqOWvwQ8cTa2TM59Kk+iHPq8H1yQ2nzo2mjT/TsJyQWF4wweaWGqnDM
         Anvu1zDRnJPCx3Rocn+C5vKVB0lC0F16eDPVR+L3eE82aiijgbcddtPjtNQuOlaXQS4Q
         M6ng==
X-Gm-Message-State: APjAAAVz+rtCvPRpzQLg5P/89lwEduSChcCpt2xpjc87kKpaVQx96IDa
	iP7Ae/PYvYoSrZGsgqE72fFJH4UbcvCSGTX0RbAIvX9feG/9FSVA7oykAYP5b1Pi+zT8S+ZgmFw
	x4BWfDlcIPcsGlhfhH2ILAC+2c1Xvc9jbctOQpK8RyzkEea6aXckOahUHEjskXBGqrQ==
X-Received: by 2002:a63:5a20:: with SMTP id o32mr3306658pgb.225.1554348644815;
        Wed, 03 Apr 2019 20:30:44 -0700 (PDT)
X-Received: by 2002:a63:5a20:: with SMTP id o32mr3306569pgb.225.1554348643740;
        Wed, 03 Apr 2019 20:30:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554348643; cv=none;
        d=google.com; s=arc-20160816;
        b=aTgZsjhxUZI02mI4ZVH291SgZJ8JPmtYessclIwqQDi87a6lllHFkvA33nvfW/RX1v
         BmMkFHsfvwv7vnjFyUHP1oBBY9hITMWUmkyXqRaVTFy13OxvWneVPE2+WHuLT2jV3+pm
         NS8B7UdFCw2kNBZOzxVdAzhDCgV+GnEiqV44o1rlu5cMS1pDuWs/4gI+XLsUS1NdlMIl
         EJdq5W0FdIT/AHveCAOcC3agm42t6XEpMdUtKH4/DZ+0uhhsvTSVQPNiLkbY6Qgft9D4
         ftxzhSCuJrpfAQhfFkyKoqyxl/4ytgTY7z0BYu0hfCNEqzLEdtAIsLhcLaQZ8wehhwvd
         5zyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:to:from:dkim-signature;
        bh=lv8NVbJO6cxJt5xlEdH0XCLVCT+ImQmsAWGyClGMj7s=;
        b=aK/+vxot6cdS1fWe2VFAey6vClerZRFMI7hPhzsbo51QUr56FzY6ozNuJNBqQmk3dX
         m0Tz2kA8xt8IrMXyij8UttflQByN3LUZtD67knXIceFKqYJTkWHiJCPsMOLpde1d9i3B
         E7cwS2/0384YxvCuDNoBKWxImDH+DqSgxpdIaxiTnGepR2ZRZLafLEItiWGC/CRsbdht
         53oLH6WIMcQ3aub6jZ4WxjmiTNZz8JAU+AFLr8EHoK0NB9u+JGkwX6OJ5Cs8KRkpXkkF
         JY78dcm3WrLgH7J57ZLxbzriRP8Fx9tALmpnFC03beKGeeIjAbwG+3n/ikSLPN2PSreZ
         IavA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Bs+UaaYK;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x80sor19594301pgx.79.2019.04.03.20.30.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Apr 2019 20:30:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Bs+UaaYK;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id;
        bh=lv8NVbJO6cxJt5xlEdH0XCLVCT+ImQmsAWGyClGMj7s=;
        b=Bs+UaaYK7meC5Cxn0BfLUhKq2cxLzN/IxzdWFfI5ouoUAsAeWY/0ic8yvAyF4Z3FP5
         i43xuSQd3ClJH05R4RJxnYS0ER2iOFW6gWgjtzGILMCcuO3Jl0mEYYBMMZbd9crz0Fkk
         j38WPKQwMtWfl1wqCKRJjmrvUdCRueIi6qFRze4qBGMFlO/Bom4h49eUFkFp0fr0qPqb
         jkiZEFj9FfdqmzlC/1Mqaie5zpbQSC9zoKpOZVuffBuR3bElTFJTcbViqaiGqH/ph6Vw
         Zm5F6E0AFOF/fSie8TBulqSyiCP1ObxhGBEjD1cZ1DtdNAvnsrKPFQpL5gW4FV3Ir+wW
         v4dw==
X-Google-Smtp-Source: APXvYqwUv0dDc5yX7JjWTWOotQnOt3ARoTj1FoGAfJdEyBh+T0nU/S8/a+Kf7sdDsKqbttMjLkaaEQ==
X-Received: by 2002:a63:6a42:: with SMTP id f63mr3345989pgc.207.1554348643029;
        Wed, 03 Apr 2019 20:30:43 -0700 (PDT)
Received: from bj03382pcu.spreadtrum.com ([117.18.48.82])
        by smtp.gmail.com with ESMTPSA id j4sm27324017pfn.132.2019.04.03.20.30.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Apr 2019 20:30:42 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Roman Gushchin <guro@fb.com>,
	Jeff Layton <jlayton@redhat.com>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm:workingset use real time to judge activity of the file page
Date: Thu,  4 Apr 2019 11:30:17 +0800
Message-Id: <1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com>
X-Mailer: git-send-email 1.7.9.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>

In previous implementation, the number of refault pages is used
for judging the refault period of each page, which is not precised as
eviction of other files will be affect a lot on current cache.
We introduce the timestamp into the workingset's entry and refault ratio
to measure the file page's activity. It helps to decrease the affection
of other files(average refault ratio can reflect the view of whole system
's memory).
The patch is tested on an Android system, which can be described as
comparing the launch time of an application between a huge memory
consumption. The result is launch time decrease 50% and the page fault
during the test decrease 80%.

Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
---
 include/linux/mmzone.h |  2 ++
 mm/workingset.c        | 24 +++++++++++++++++-------
 2 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 32699b2..c38ba0a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -240,6 +240,8 @@ struct lruvec {
 	atomic_long_t			inactive_age;
 	/* Refaults at the time of last reclaim cycle */
 	unsigned long			refaults;
+	atomic_long_t			refaults_ratio;
+	atomic_long_t			prev_fault;
 #ifdef CONFIG_MEMCG
 	struct pglist_data *pgdat;
 #endif
diff --git a/mm/workingset.c b/mm/workingset.c
index 40ee02c..6361853 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -159,7 +159,7 @@
 			 NODES_SHIFT +	\
 			 MEM_CGROUP_ID_SHIFT)
 #define EVICTION_MASK	(~0UL >> EVICTION_SHIFT)
-
+#define EVICTION_JIFFIES (BITS_PER_LONG >> 3)
 /*
  * Eviction timestamps need to be able to cover the full range of
  * actionable refaults. However, bits are tight in the radix tree
@@ -175,18 +175,22 @@ static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
 	eviction >>= bucket_order;
 	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
 	eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
+	eviction = (eviction << EVICTION_JIFFIES) | (jiffies >> EVICTION_JIFFIES);
 	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
 
 	return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
 }
 
 static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
-			  unsigned long *evictionp)
+			  unsigned long *evictionp, unsigned long *prev_jiffp)
 {
 	unsigned long entry = (unsigned long)shadow;
 	int memcgid, nid;
+	unsigned long prev_jiff;
 
 	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
+	entry >>= EVICTION_JIFFIES;
+	prev_jiff = (entry & ((1UL << EVICTION_JIFFIES) - 1)) << EVICTION_JIFFIES;
 	nid = entry & ((1UL << NODES_SHIFT) - 1);
 	entry >>= NODES_SHIFT;
 	memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
@@ -195,6 +199,7 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
 	*memcgidp = memcgid;
 	*pgdat = NODE_DATA(nid);
 	*evictionp = entry << bucket_order;
+	*prev_jiffp = prev_jiff;
 }
 
 /**
@@ -242,8 +247,12 @@ bool workingset_refault(void *shadow)
 	unsigned long refault;
 	struct pglist_data *pgdat;
 	int memcgid;
+	unsigned long refault_ratio;
+	unsigned long prev_jiff;
+	unsigned long avg_refault_time;
+	unsigned long refault_time;
 
-	unpack_shadow(shadow, &memcgid, &pgdat, &eviction);
+	unpack_shadow(shadow, &memcgid, &pgdat, &eviction, &prev_jiff);
 
 	rcu_read_lock();
 	/*
@@ -288,10 +297,11 @@ bool workingset_refault(void *shadow)
 	 * list is not a problem.
 	 */
 	refault_distance = (refault - eviction) & EVICTION_MASK;
-
 	inc_lruvec_state(lruvec, WORKINGSET_REFAULT);
-
-	if (refault_distance <= active_file) {
+	lruvec->refaults_ratio = atomic_long_read(&lruvec->inactive_age) / jiffies;
+	refault_time = jiffies - prev_jiff;
+	avg_refault_time = refault_distance / lruvec->refaults_ratio;
+	if (refault_time <= avg_refault_time) {
 		inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
 		rcu_read_unlock();
 		return true;
@@ -521,7 +531,7 @@ static int __init workingset_init(void)
 	 * some more pages at runtime, so keep working with up to
 	 * double the initial memory by using totalram_pages as-is.
 	 */
-	timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT;
+	timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT - EVICTION_JIFFIES;
 	max_order = fls_long(totalram_pages - 1);
 	if (max_order > timestamp_bits)
 		bucket_order = max_order - timestamp_bits;
-- 
1.9.1

