Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4265C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:15:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 547A521848
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:15:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="NWO1tpka"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 547A521848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBBE58E001C; Tue, 29 Jan 2019 14:15:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E92B98E0001; Tue, 29 Jan 2019 14:15:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D82BF8E001C; Tue, 29 Jan 2019 14:15:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id A54248E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:15:28 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id f10so11910607ywc.21
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:15:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7Uuf0LVs+pzHcF3nyh4GxvEPQsOE1NPnxZxuLZkBYcE=;
        b=f+1Sy1N8Y7BbzLyGYcmF6Tm8CthLxh6vPf5GGlLvgToRQR9qYAIvq26ZQJvQQimKNe
         ++TLn4oeu2t5NocWv5FLpQl2iwqT84i4O5w+FQTd+a66NcpFxpJ+l2p/6Wr3uv/YTICK
         HDH7r/1EoLtKh6OCtfzcUU9eqK9QiR34BzN98DNlvgAFurWmQiP89PCPMCCxroBVPzf+
         jfXzHnXk8+ANCiaI2ZMfN983qpGtSorzkMt8mITBE3kUGxCMWAQjcgBfQBqCBfHE5O6V
         wwa2x+rh5dYuc4cojLxCAYzrJ8kyE9WkeA42mf1J8wQ71J9ytqvRSmdHboVZFpskJJZz
         hlNQ==
X-Gm-Message-State: AJcUukd8BTe9PWbaDMVRGHRu3Suts8NiQWpU0dLKbTjXWa99DETYRqzl
	2YpB1CArl/ISUQHBY4Q8z1Kce7KQcUPd+1nFrHaYTBRbtHG83YGH61p0YE3lpbvCFK71i+NJD9C
	ZZW2TYmx2ZwMl/xzu29eZ9Oa0C7o5JErtnDexwNpCj/BAkhAPtGzoILMdQh1RnyB2i739LZgPJ9
	X0bpMO6aaD0HVscJiUWp1vtJY2pTReqaZ2ZG/cKrvG/d6QiFxbYIwpkwfpUM14COaRhSZ+fZG/m
	IuTc5XtiVglU8N6Oq+rkeg3lzM5Erro4l5E7k18ggef8BWeBapYsmodNkFdn7cFtBQGCM11x0ph
	EJXeZUuqIQ4Ns/yMHUhqzS0YRqwFY8ARnvgJmJW/o/lDTF66oypXZhLEn8NmgTivAHQza7GRH2Z
	4
X-Received: by 2002:a5b:4e:: with SMTP id e14mr15747232ybp.421.1548789328321;
        Tue, 29 Jan 2019 11:15:28 -0800 (PST)
X-Received: by 2002:a5b:4e:: with SMTP id e14mr15747187ybp.421.1548789327582;
        Tue, 29 Jan 2019 11:15:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548789327; cv=none;
        d=google.com; s=arc-20160816;
        b=uV4qFJxVW5V7U/k+ie95qHJlB11bydCpSvdcz57TrqW6t76dGMiJ63Hqk31ysQlX6Y
         zvFHOqoU/1Nqv2r2ejWKFqNBc/QhdNj8XJe8C4Pc7x9/bYrQM13RBjdeuwvtEWZ30mWx
         gPulp2UonT+YUj1vLylrIt7Fkv12TPHFfgIioIek9ESNQMGqPyq2XcXcuNqUDMaLrJ1M
         5NoieDjzrCROwNJZjHBDO9LmIm7miG1z1v9lUJXNUWB8koS3vj+7Hqthufw1cahgHncL
         ELfcsSMbzKPAbT9+nRqAKnSV5bqhplrP0eLB0QzVsLHiSEgew/bNNTwdX3JusCrl8653
         0a2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7Uuf0LVs+pzHcF3nyh4GxvEPQsOE1NPnxZxuLZkBYcE=;
        b=Ln+7ROX89/biO3Vaa1YDqgXaBHg5PBWGW+gSQtUzyx6zvTTmAK3BCzNdMx6u3gHP7S
         vXjbFIjFjfjDTnoOZY0F5oHXqFWkoAqX0Wzcs60l3aW6mYjCFV+riSgDkJEcaTRL0Ys0
         Ewo3sH5umsVP5lUnRjdHv52Nmqwuy744vvIj0t4a8M4uUZMNaml953s9C0JqYysoYntt
         ufZBkIGZHnk0BCTcKhIqrYMQ8wnVynoUtbphKumTrHO7pCbWLn+Oolo8jVvAnGQ7J18l
         qCxqdOT1xXI9lwcBw47HCKz9CZaH0cSASvRwgMj0hgpac2/feC3En8t6wwtixP1DDCzW
         BI/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=NWO1tpka;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x3sor6473544ywf.188.2019.01.29.11.15.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 11:15:27 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=NWO1tpka;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7Uuf0LVs+pzHcF3nyh4GxvEPQsOE1NPnxZxuLZkBYcE=;
        b=NWO1tpkadXDzKPLeqcckeYOXK0qRah25lv9XpFX4W/D0ZeK8WDrTZav72UjZSwm8Y5
         8E9j5aDJinxsGCjkPiV9bCrYzES7wIWNC6XZjNvE3ekV4DtiuqGhAvnXih2dEIUtbjBe
         5QquP/EkhMDDHWEeQGacIpCHyATrH6UAr06Rc=
X-Google-Smtp-Source: ALg8bN7IHjZGwZzucz28HO/PlymbzsSNvGYxzDg61I0IW58mCAOiemGroUrZ9qMUoFn7zt2LxKfK1A==
X-Received: by 2002:a81:5b07:: with SMTP id p7mr27054908ywb.468.1548789326972;
        Tue, 29 Jan 2019 11:15:26 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::6:f1fc])
        by smtp.gmail.com with ESMTPSA id k187sm12398985ywf.71.2019.01.29.11.15.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 11:15:26 -0800 (PST)
Date: Tue, 29 Jan 2019 14:15:25 -0500
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
	Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>,
	Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH v3] mm: Make memory.emin the baseline for utilisation
 determination
Message-ID: <20190129191525.GB10430@chrisdown.name>
References: <20190129182516.GA1834@chrisdown.name>
 <20190129190253.GA10430@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190129190253.GA10430@chrisdown.name>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Roman points out that when when we do the low reclaim pass, we scale the
reclaim pressure relative to position between 0 and the maximum
protection threshold.

However, if the maximum protection is based on memory.elow, and
memory.emin is above zero, this means we still may get binary behaviour
on second-pass low reclaim. This is because we scale starting at 0, not
starting at memory.emin, and since we don't scan at all below emin, we
end up with cliff behaviour.

This should be a fairly uncommon case since usually we don't go into the
second pass, but it makes sense to scale our low reclaim pressure
starting at emin.

You can test this by catting two large sparse files, one in a cgroup
with emin set to some moderate size compared to physical RAM, and
another cgroup without any emin. In both cgroups, set an elow larger
than 50% of physical RAM. The one with emin will have less page
scanning, as reclaim pressure is lower.

Signed-off-by: Chris Down <chris@chrisdown.name>
Suggested-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>
Cc: Dennis Zhou <dennis@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 include/linux/memcontrol.h | 12 ++++++---
 mm/vmscan.c                | 55 +++++++++++++++++++++++---------------
 2 files changed, 41 insertions(+), 26 deletions(-)

...well, I sent it with NULL for !CONFIG_MEMCG when I wanted 0. This is the 
fixed fix(tm) patch.

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 290cfbfd60cd..6f7e0e1b581d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -333,9 +333,11 @@ static inline bool mem_cgroup_disabled(void)
 	return !cgroup_subsys_enabled(memory_cgrp_subsys);
 }
 
-static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg)
+static inline void mem_cgroup_protection(struct mem_cgroup *memcg,
+					 unsigned long *min, unsigned long *low)
 {
-	return max(READ_ONCE(memcg->memory.emin), READ_ONCE(memcg->memory.elow));
+	*min = READ_ONCE(memcg->memory.emin);
+	*low = READ_ONCE(memcg->memory.elow);
 }
 
 enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
@@ -826,9 +828,11 @@ static inline void memcg_memory_event_mm(struct mm_struct *mm,
 {
 }
 
-static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg)
+static inline void mem_cgroup_protection(struct mem_cgroup *memcg,
+					 unsigned long *min, unsigned long *low)
 {
-	return 0;
+	*min = 0;
+	*low = 0;
 }
 
 static inline enum mem_cgroup_protection mem_cgroup_protected(
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 549251818605..f7c4ab39d5d0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2447,12 +2447,12 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 		int file = is_file_lru(lru);
 		unsigned long lruvec_size;
 		unsigned long scan;
-		unsigned long protection;
+		unsigned long min, low;
 
 		lruvec_size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
-		protection = mem_cgroup_protection(memcg);
+		mem_cgroup_protection(memcg, &min, &low);
 
-		if (protection > 0) {
+		if (min || low) {
 			/*
 			 * Scale a cgroup's reclaim pressure by proportioning
 			 * its current usage to its memory.low or memory.min
@@ -2467,28 +2467,38 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			 * set it too low, which is not ideal.
 			 */
 			unsigned long cgroup_size = mem_cgroup_size(memcg);
-			unsigned long baseline = 0;
 
 			/*
-			 * During the reclaim first pass, we only consider
-			 * cgroups in excess of their protection setting, but if
-			 * that doesn't produce free pages, we come back for a
-			 * second pass where we reclaim from all groups.
+			 * If there is any protection in place, we adjust scan
+			 * pressure in proportion to how much a group's current
+			 * usage exceeds that, in percent.
 			 *
-			 * To maintain fairness in both cases, the first pass
-			 * targets groups in proportion to their overage, and
-			 * the second pass targets groups in proportion to their
-			 * protection utilization.
-			 *
-			 * So on the first pass, a group whose size is 130% of
-			 * its protection will be targeted at 30% of its size.
-			 * On the second pass, a group whose size is at 40% of
-			 * its protection will be
-			 * targeted at 40% of its size.
+			 * There is one special case: in the first reclaim pass,
+			 * we skip over all groups that are within their low
+			 * protection. If that fails to reclaim enough pages to
+			 * satisfy the reclaim goal, we come back and override
+			 * the best-effort low protection. However, we still
+			 * ideally want to honor how well-behaved groups are in
+			 * that case instead of simply punishing them all
+			 * equally. As such, we reclaim them based on how much
+			 * of their best-effort protection they are using. Usage
+			 * below memory.min is excluded from consideration when
+			 * calculating utilisation, as it isn't ever
+			 * reclaimable, so it might as well not exist for our
+			 * purposes.
 			 */
-			if (!sc->memcg_low_reclaim)
-				baseline = lruvec_size;
-			scan = lruvec_size * cgroup_size / protection - baseline;
+			if (sc->memcg_low_reclaim && low > min) {
+				/*
+				 * Reclaim according to utilisation between min
+				 * and low
+				 */
+				scan = lruvec_size * (cgroup_size - min) /
+					(low - min);
+			} else {
+				/* Reclaim according to protection overage */
+				scan = lruvec_size * cgroup_size /
+					max(min, low) - lruvec_size;
+			}
 
 			/*
 			 * Don't allow the scan target to exceed the lruvec
@@ -2504,7 +2514,8 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			 * some cases in the case of large overages.
 			 *
 			 * Also, minimally target SWAP_CLUSTER_MAX pages to keep
-			 * reclaim moving forwards.
+			 * reclaim moving forwards, avoiding decremeting
+			 * sc->priority further than desirable.
 			 */
 			scan = clamp(scan, SWAP_CLUSTER_MAX, lruvec_size);
 		} else {
-- 
2.20.1

