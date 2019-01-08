Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0D8DC43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 20:05:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 937F520660
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 20:05:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rlkAF1Mj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 937F520660
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FDE98E009B; Tue,  8 Jan 2019 15:05:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AD058E0038; Tue,  8 Jan 2019 15:05:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C6538E009B; Tue,  8 Jan 2019 15:05:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 054A58E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 15:05:54 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id s3so4227303iob.15
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 12:05:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=txNiwTr9zOR1HjVOP3bo2qaITo/vW1+4t71PfijPP4c=;
        b=SZvRkQJ5qWgfQghjjpVNVxQ0hH7Sq1yDZyB+0DxTPxYjO0p9tVVqSd9ID0Zb7qlyUR
         nBkJT++r4Sv0s5d4QcmxezIMWPpVr3b7QBNATRf4OsJO4ZCvBzqVUEutN4f0SOfpyT0Y
         jo3SU3/UUfmYIFenBBkVEmhFXpGgy4yIjTeZH8u+YF6T4zVOm9nCE2s8UqmEBAorJjxo
         TtpcwuGQSYtAkNKTSsAZRt3cmZF91e5B+nnpclKKiuAIlKoFju6SSdmc4kSp68P3Ha2j
         uO5cnHLxC3QDe21JezzgHABwaUQ6RAKVgEmcYzy7J2DMVJoQQmVCfBBYpE2gVivoJF/Z
         ALfg==
X-Gm-Message-State: AJcUukfWmwTTUNMEBZIV2116OpF+hY2DUpO3hAQuWP01F96w/XudsJUS
	C3sMjkDmQIcXBd2+2+KDmmNYkPiGOD9Tg67V4OfNUlBT2qG2BnwjA59IGVE/eeiZKvrpYraTTCj
	FhTHKRcKgKkwwH6mrCRyRBWnO7ZEDBIejbyS9NvUf4qVKW5p9Tw5Pf6XyHmhL4W/YZ0SqdGv8w6
	+Rx0eesb7hcG4pD9vCgsQLV/Zep2vBhCbQSyFWLvZar6Rw2Ug0pRxnnKgZ6nXQr8g9z+1gJzH23
	RGNpPOv5kfrJUCFoR4HxKamu2OFy/sPTj2F10oLcmQFFDPipETKV7GkwE5rd/owOp4XlDafa/PO
	cci/SkrKitWVIlaigZi8TSDif36ewmlEZ/YQWP1QPmlBELtLwB/HLbg7c3WeT75ayIZGiQnpJzj
	C
X-Received: by 2002:a24:100d:: with SMTP id 13mr2262168ity.58.1546977953740;
        Tue, 08 Jan 2019 12:05:53 -0800 (PST)
X-Received: by 2002:a24:100d:: with SMTP id 13mr2262135ity.58.1546977952902;
        Tue, 08 Jan 2019 12:05:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546977952; cv=none;
        d=google.com; s=arc-20160816;
        b=WYZogbh/PWXmUKRCbydq2zaCPLzNKP8UNl6DhZd9EKrLckg3jZkQFEcSfXntpl6ODf
         Q6RDskyrBtfgs2XfDffdMZyCxgHgFtvVimFRMPvy0qLOjDhSJqvktUfBSOPj6+5vZazu
         2hGoCmlQiLkfDzG2FAp9eshdkdx5WbZrraiPDNbb2JpciVjBv8rx5ksYQQUvv4iv6GFf
         GkUOqqBkp+2VaxPZAtSz01lPUJ6T5DYWmrNOQH1fW91q2zlAkbChCdp+BhgvQ90kVyId
         G5/Bh7gN1GqyZkzE3k3LPKgQokORupWzNRKVGBu79sUEmV3TNIL8DfGscoufeU+qP3nT
         ZBhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=txNiwTr9zOR1HjVOP3bo2qaITo/vW1+4t71PfijPP4c=;
        b=dvrHJXvGjTuG9Jms3Aji7pdU+TqQOYd3fp0cw2sxe11qLWx5BmD+3IfuCXATCo0HBN
         00yH/RYAiWy8NYTyCaFtFSpxtXFUOgF6MA2Edko2+IkN5c7DW5SBiU5tRi8A9Io2YjBZ
         wL80E7dYD5tDuEjSXs8OkXwUq82IqcMWRqDKwrZomsSIB9k4wNb/0Bzj1ir68ZcyKy7W
         o31UgOqAn3/tgPyXWLMePy9s59EwQLF6UMFFy0enaSZdz/OcHSFBOrlHBGEVUnQQbfye
         Z+6vHVhY+tBaWiNipFRWm4nsINxq8uicIl0xra6gHcHHcJVX7iGCv+nlA7i39TWGkAkR
         hgew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rlkAF1Mj;
       spf=pass (google.com: domain of 3oai1xagkcgerg9jddkafnnfkd.bnlkhmtw-llju9bj.nqf@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3oAI1XAgKCGERG9JDDKAFNNFKD.BNLKHMTW-LLJU9BJ.NQF@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n143sor19887434itn.34.2019.01.08.12.05.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 12:05:52 -0800 (PST)
Received-SPF: pass (google.com: domain of 3oai1xagkcgerg9jddkafnnfkd.bnlkhmtw-llju9bj.nqf@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rlkAF1Mj;
       spf=pass (google.com: domain of 3oai1xagkcgerg9jddkafnnfkd.bnlkhmtw-llju9bj.nqf@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3oAI1XAgKCGERG9JDDKAFNNFKD.BNLKHMTW-LLJU9BJ.NQF@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=txNiwTr9zOR1HjVOP3bo2qaITo/vW1+4t71PfijPP4c=;
        b=rlkAF1MjC29sfFIQEKpxF+0AV8L6qXF+nhZkPIbME243C8Jwuvj/1e3xhDjqtHVE59
         0mGycnvWR4daAKkMgxLrA0v6A/yIqABPwr4rXJFrczjy+fy8/dUJhDlLOdXWguHugkBV
         18G0CBHsGd6SSb7Ou2aE7ZATlNwGbwmiJvAYv8wxgcL2Cu5TdZUFF7NWcKlK+EpGeBy4
         Le24umrAwRk7E58WuRH0ZdLHihGcAFfp3mjLPj2x5YaLCD3FbvYPqjIcIXQou3GVpMth
         J5C1QwAXBOp7qtlHNFGRbKfZUDmkIJAqtIV3aPZsqXblElgsQmIsJefKLeks2sxKZV/X
         K3CA==
X-Google-Smtp-Source: ALg8bN4CvWVUPVnD74x3rMa3McPsCj5IBNGdgmPr7bgHkGszws1zhUP4HnQrEnbheeYFeQcp9NcbBfz1bvsWww==
X-Received: by 2002:a24:1c87:: with SMTP id c129mr2340547itc.11.1546977952601;
 Tue, 08 Jan 2019 12:05:52 -0800 (PST)
Date: Tue,  8 Jan 2019 12:05:38 -0800
Message-Id: <20190108200538.80371-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.97.g81188d93c3-goog
Subject: [PATCH v2] memcg: schedule high reclaim for remote memcgs on high_work
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108200538.urWPuz5HKECd3WnUaUz4N4v-JUNVYwhiOD9D4gjgXRM@z>

If a memcg is over high limit, memory reclaim is scheduled to run on
return-to-userland. However it is assumed that the memcg is the current
process's memcg. With remote memcg charging for kmem or swapping in a
page charged to remote memcg, current process can trigger reclaim on
remote memcg. So, schduling reclaim on return-to-userland for remote
memcgs will ignore the high reclaim altogether. So, record the memcg
needing high reclaim and trigger high reclaim for that memcg on
return-to-userland. However if the memcg is already recorded for high
reclaim and the recorded memcg is not the descendant of the the memcg
needing high reclaim, punt the high reclaim to the work queue.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v1:
- Punt high reclaim of a memcg to work queue only if the recorded memcg
  is not its descendant.

 include/linux/sched.h |  3 +++
 kernel/fork.c         |  1 +
 mm/memcontrol.c       | 18 +++++++++++++-----
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index a95d1a9574e7..9a46243e6585 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1168,6 +1168,9 @@ struct task_struct {
 
 	/* Used by memcontrol for targeted memcg charge: */
 	struct mem_cgroup		*active_memcg;
+
+	/* Used by memcontrol for high relcaim: */
+	struct mem_cgroup		*memcg_high_reclaim;
 #endif
 
 #ifdef CONFIG_BLK_CGROUP
diff --git a/kernel/fork.c b/kernel/fork.c
index 68e0a0c0b2d3..98c9963ac8d5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -916,6 +916,7 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 
 #ifdef CONFIG_MEMCG
 	tsk->active_memcg = NULL;
+	tsk->memcg_high_reclaim = NULL;
 #endif
 	return tsk;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e9db1160ccbc..81fada6b4a32 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2145,7 +2145,8 @@ void mem_cgroup_handle_over_high(void)
 	if (likely(!nr_pages))
 		return;
 
-	memcg = get_mem_cgroup_from_mm(current->mm);
+	memcg = current->memcg_high_reclaim;
+	current->memcg_high_reclaim = NULL;
 	reclaim_high(memcg, nr_pages, GFP_KERNEL);
 	css_put(&memcg->css);
 	current->memcg_nr_pages_over_high = 0;
@@ -2301,10 +2302,10 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * If the hierarchy is above the normal consumption range, schedule
 	 * reclaim on returning to userland.  We can perform reclaim here
 	 * if __GFP_RECLAIM but let's always punt for simplicity and so that
-	 * GFP_KERNEL can consistently be used during reclaim.  @memcg is
-	 * not recorded as it most likely matches current's and won't
-	 * change in the meantime.  As high limit is checked again before
-	 * reclaim, the cost of mismatch is negligible.
+	 * GFP_KERNEL can consistently be used during reclaim. Record the memcg
+	 * for the return-to-userland high reclaim. If the memcg is already
+	 * recorded and the recorded memcg is not the descendant of the memcg
+	 * needing high reclaim, punt the high reclaim to the work queue.
 	 */
 	do {
 		if (page_counter_read(&memcg->memory) > memcg->high) {
@@ -2312,6 +2313,13 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			if (in_interrupt()) {
 				schedule_work(&memcg->high_work);
 				break;
+			} else if (!current->memcg_high_reclaim) {
+				css_get(&memcg->css);
+				current->memcg_high_reclaim = memcg;
+			} else if (!mem_cgroup_is_descendant(
+					current->memcg_high_reclaim, memcg)) {
+				schedule_work(&memcg->high_work);
+				break;
 			}
 			current->memcg_nr_pages_over_high += batch;
 			set_notify_resume(current);
-- 
2.20.1.97.g81188d93c3-goog

