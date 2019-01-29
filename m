Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 828B4C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 22:11:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46D7E21473
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 22:11:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46D7E21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D73AF8E0002; Tue, 29 Jan 2019 17:11:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D24AC8E0001; Tue, 29 Jan 2019 17:11:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3A1A8E0002; Tue, 29 Jan 2019 17:11:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8607A8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:11:28 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p9so18023159pfj.3
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:11:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=KPSrZsu84s7dG54VRtyqZJD1qBgDbiyWgneJSC8QgBs=;
        b=MZwGhECM4afE+6/CrpyfZgh1V/dBRHWdciTFKmRZc2Dm4fxks3HFAxXJc0FBQcGu5B
         EKbF61Ajv7dwxSQ7RoNpUblR5Y8lJtPQrA/H3JP2Gc9XZPxHuaMawBPQsVeMzQ5EpcYu
         3NvWMuxnwPIFtsbN3xU4xSpOsfsNU3Ck+HdKrahiYz743vo/4HCyKcSoH428ZBJWrCTw
         JfmRQRlJkXRmQkZF6swOb/5+X+lSU6n0WeAJmJxyQ7S3TBWdT3eXosrxf2BA/RlLtMf6
         oVrQdKu79jqPlhqY56u6fo0tds9QCSiylOjTNxP4HxrQe98QTU2hFq3lcX6UB6mZFgGy
         xcuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AJcUukcD5yPUq0R3naRB+nULuNtGOc5VaraYwKAaC/A72a8uoqm4n4gL
	7lA62YJQLfALyIZxDJCwbB3hTXWm1Tqzxyvt+qPERmjcYOEYOKFp96lW8vy+RZF8dGZQxZXGmF+
	27slMLN7dHvd4XxVpwm9D/y8bQrJ/ZDKFPfK7PqZIhWLZCWqH9KP3mYENNsUpFYR8UA==
X-Received: by 2002:a62:5182:: with SMTP id f124mr28198030pfb.238.1548799888193;
        Tue, 29 Jan 2019 14:11:28 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4HC+VVNykwET4PSMX2uX9DlLqw/ZO9O419EH7A7jJwaOxsUYWbboXpX8/VwQ5f6zGjOB9A
X-Received: by 2002:a62:5182:: with SMTP id f124mr28197965pfb.238.1548799886925;
        Tue, 29 Jan 2019 14:11:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548799886; cv=none;
        d=google.com; s=arc-20160816;
        b=aeQzp/8DfxMgH6pizrJCG4IxGKXzLFTLBpoLudk5fcA8aClEzonRCrcazEwbXDbJSd
         gncQa3JOglK/J/t/Qi1KYsNpplRSSve+kkHq7wAUYoESxvoLTNUi8ELBeBw2Z9b8U2kT
         qbhZxbpPKwYFAwSRek+9lP7FYC7U169C5UeOxajePScuLxlo/n8FAK+YPLfeb9U6kdHI
         YnXbGwWWudXZ7NXoa0aA6yVRyOIzgzjLgArODMkKQdLv33RQZLOZNvXG0AS+pzyFqHfh
         z/9NXnhUYNMOe1S0Y60r2MRVgPI2WeBoWrQgrn1NtjKyqLCn2H6QiV81OfIJ1ezLPeo/
         vDMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=KPSrZsu84s7dG54VRtyqZJD1qBgDbiyWgneJSC8QgBs=;
        b=CFeWiG6nBy7DJtk6r7DMuQm8AdDCr3GF18cONu4giukiXvqONhP+xIHyVR/SjKxH2h
         zhKbsvLKiRd1rYrKj5vmTI6Qm6BsR8V4XZkjb3MPCOndNziXYu3w69c+/eMTKuQoj2Mh
         lfPJIxiYkQiTWOu6CGO4Xu63JK+WvBeCGhqGexVzwv06xrkqVRsuGILZUJsvMMsAZqrC
         OJPkrjQQ60Zsgzvq5PKfqMcK0TzIeLTBPCVn+Wxvz9prJQrt0SQqIynByGo9KYv1Za4A
         /zAX94w0z+wppAMlCc/qhdwG3AsN4NDWiSo9gDdnw1Jwp4tE60jpFluXruJQYHgafdev
         FfQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id d11si37913241pla.335.2019.01.29.14.11.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 14:11:26 -0800 (PST)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R241e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TJEMIga_1548799877;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TJEMIga_1548799877)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 30 Jan 2019 06:11:24 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC v2 PATCH] mm: vmscan: do not iterate all mem cgroups for global direct reclaim
Date: Wed, 30 Jan 2019 06:11:17 +0800
Message-Id: <1548799877-10949-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In current implementation, both kswapd and direct reclaim has to iterate
all mem cgroups.  It is not a problem before offline mem cgroups could
be iterated.  But, currently with iterating offline mem cgroups, it
could be very time consuming.  In our workloads, we saw over 400K mem
cgroups accumulated in some cases, only a few hundred are online memcgs.
Although kswapd could help out to reduce the number of memcgs, direct
reclaim still get hit with iterating a number of offline memcgs in some
cases.  We experienced the responsiveness problems due to this
occassionally.

A simple test with pref shows it may take around 220ms to iterate 8K memcgs
in direct reclaim:
             dd 13873 [011]   578.542919: vmscan:mm_vmscan_direct_reclaim_begin
             dd 13873 [011]   578.758689: vmscan:mm_vmscan_direct_reclaim_end
So for 400K, it may take around 11 seconds to iterate all memcgs.

Here just break the iteration once it reclaims enough pages as what
memcg direct reclaim does.  This may hurt the fairness among memcgs.  But
the cached iterator cookie could help to achieve the fairness more or
less.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
v2: Added some test data in the commit log
    Updated commit log about iterator cookie could maintain fairness
    Dropped !global_reclaim() since !current_is_kswapd() is good enough

 mm/vmscan.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a714c4f..5e35796 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2764,16 +2764,15 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 				   sc->nr_reclaimed - reclaimed);
 
 			/*
-			 * Direct reclaim and kswapd have to scan all memory
-			 * cgroups to fulfill the overall scan target for the
-			 * node.
+			 * Kswapd have to scan all memory cgroups to fulfill
+			 * the overall scan target for the node.
 			 *
 			 * Limit reclaim, on the other hand, only cares about
 			 * nr_to_reclaim pages to be reclaimed and it will
 			 * retry with decreasing priority if one round over the
 			 * whole hierarchy is not sufficient.
 			 */
-			if (!global_reclaim(sc) &&
+			if (!current_is_kswapd() &&
 					sc->nr_reclaimed >= sc->nr_to_reclaim) {
 				mem_cgroup_iter_break(root, memcg);
 				break;
-- 
1.8.3.1

