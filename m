Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77527C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:02:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2941920844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:02:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="FmvuaGhH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2941920844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB9498E000A; Tue, 29 Jan 2019 14:02:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B41208E0001; Tue, 29 Jan 2019 14:02:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0AE48E000A; Tue, 29 Jan 2019 14:02:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D3028E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:02:57 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id q82so11729888ywg.22
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:02:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3gdtZ03l2f09FV33buLEaZQuZ0ElvMotUvVTz5rqqWI=;
        b=Z3M4mWz2OjcU6+USh6w1Q5sDLL0z3gqqwc/GiSs6FcRLOcOhU2a9N+Gbd41el0ib7v
         pIDSLUuUEr1caZAN28lWA7bOu1ATTI6Fvm6tTE1pmMdBJuuQHQHAEPtdS5XPF7dHgUFt
         I+OWF+Lj2GDGx1b0oGuNzzcjKEMtTM3JncI+9PmEt0wzF4sr56GUrXZcs8Sim3fTU5pP
         BEkFO1cdE6Jwbs3W8s/yg8BuD1JBfY0hsWhYLAB3rAgmF5fU8wPjVNiQaSzu8a87kUy+
         C201HwYj0TnL71xUkuUkOG4s/osx5Gip0vk9fPM3QldqxT+RN9owBwSf3UglqMWks+eA
         1Iqw==
X-Gm-Message-State: AJcUukf7WQ4IxLY27fVLprmQkFBQZiUD0F2esJTV8IIQuyrLtveoqd3h
	sCRv2GVRjvfZ6DqkutKe6VYJPo5aGfg2ILQawFvTd0KdYFPTUXQuho++9yuzmViaOLX1BJeih6s
	dGniWp72ehYll6tl2yNADexn+K3Iq3MbOe6vSht9GBW6efUUQ/M/uzYJQpBRj+6cdn9BWq9HWS1
	I3T8S1NvyQDFCvRA7GCtGT1MJ9NedwR/or5NjimqR8XDPLWRIqvMANeN31oIDO9k9rZHjuvuwS/
	DYpz3jiIW7LxeLEKfjmdSZBoDDuHJeZG4kZgnkhRuBM3KgF9Yyk7yKCiUV0d9ExU1Hh4IiN9Z+q
	9UFOOKCsUNLY2G3p6N5FNExa5/kaM4pwPMUOKp1n7+ugeTk9YVuygKQKvJfLk4YIrGRWxcHYSko
	5
X-Received: by 2002:a5b:b86:: with SMTP id l6mr25057763ybq.233.1548788576976;
        Tue, 29 Jan 2019 11:02:56 -0800 (PST)
X-Received: by 2002:a5b:b86:: with SMTP id l6mr25057695ybq.233.1548788576133;
        Tue, 29 Jan 2019 11:02:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548788576; cv=none;
        d=google.com; s=arc-20160816;
        b=YdzK/XOGI/Rp1kz/tcmC4vqKwSo7WS0eVxOUkqwyskqrmSYI7EIIHaYw40TYR/g7Ib
         kbFxG3Rwf21y2nQMM/Xd+xOkpfqoBRLgsefZehO2vQd2e58KgzpQGwhubCY6rFAH6IYq
         TZHyhROnMPMYhsarbaQ+8HGAQhcudkQGUk+L5l6fWmBmCN6+WOVOWWEyputTIF7Luxkm
         e3PGnCGJHOePTCZCAdnOWEXsA+tVcd/XtFhu5meJOcEkrYR9RrPUhTUEQbTN0zEK2Kin
         hf5J8ZGqWo8seWGGxz4Na3J9cs5oLfQYI/TD28uHZaDOMK+HwdbA8ia9QKW95tsCCZFG
         vOHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3gdtZ03l2f09FV33buLEaZQuZ0ElvMotUvVTz5rqqWI=;
        b=Q7Q1uP2787mrSfat206LAPmx5jHAAQ3p9bklmPff/Oh84sAHOwZx8JU/maFbSbuzdU
         H8oeBuwsEoa5EVQJtJZk4tKtypu2Hi9fW0JnHLuZ+yaWWmJFYeEDVImRHlDbjfv5yifV
         Xoqde88hmEC51aMcDgaRojivtYBudBCn7IAxYEiVyp9BjYSDWzKHBT4/46IaY5gZTUAO
         tmH+oUcqcKDpv3mm47/PrRk5lctE3uDy/J8NVBE77QKHONXpkMFO+F6+NGsDOBrqphSC
         e/oeqw1lqr1wHKoIlvqz3bAhqB+90BUFChzR0+TylwFVZ7eyBR9cHXMpcMGMVCXefycG
         Zc5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=FmvuaGhH;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j12sor6450789ywg.21.2019.01.29.11.02.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 11:02:56 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=FmvuaGhH;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3gdtZ03l2f09FV33buLEaZQuZ0ElvMotUvVTz5rqqWI=;
        b=FmvuaGhHYkeGQR7XrL3kOAVN2hLkm1dLgt4yjRcmvNKKaAXNKs/3aZcp9acw6kCdKl
         52thlhVAXh+MXCF5Ppr+lrYsioFZPgPXpgBJhqA6kI1eaWJjuYwqOrLRtovYfyIY9Fza
         3KjpC0gBjSOfGkTUz6eH5W8m49KzxUzh6fj98=
X-Google-Smtp-Source: ALg8bN4AYRIpJa263wzK5jgww4Y8DEJmewRQGQ7X/LrIKkYouefQiRMEQd2WIPGVdJWxCuNpWOu3tA==
X-Received: by 2002:a81:5fd5:: with SMTP id t204mr25498495ywb.312.1548788575338;
        Tue, 29 Jan 2019 11:02:55 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::6:f1fc])
        by smtp.gmail.com with ESMTPSA id q24sm15181056ywa.95.2019.01.29.11.02.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 29 Jan 2019 11:02:54 -0800 (PST)
Date: Tue, 29 Jan 2019 14:02:53 -0500
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
	Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>,
	Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: [PATCH v2] mm: Make memory.emin the baseline for utilisation
 determination
Message-ID: <20190129190253.GA10430@chrisdown.name>
References: <20190129182516.GA1834@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190129182516.GA1834@chrisdown.name>
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

I'm an idiot and forgot to also update the !CONFIG_MEMCG definition for
mem_cgroup_protection. This is the fixed version.

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 290cfbfd60cd..ba99d25d2a98 100644
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
+	*min = NULL;
+	*low = NULL;
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

