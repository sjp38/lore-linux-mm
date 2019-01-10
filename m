Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0950AC43444
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 17:44:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B203720685
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 17:44:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rSTdy8Eq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B203720685
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60ABC8E0005; Thu, 10 Jan 2019 12:44:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B9168E0001; Thu, 10 Jan 2019 12:44:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D1388E0005; Thu, 10 Jan 2019 12:44:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0AECB8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 12:44:45 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d3so6707828pgv.23
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 09:44:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=Gt8KB5JyoxxYaL1/z6NLcbWHN8NvTltGpPlll2SY3FY=;
        b=eoHLUn6/xwEbXg2UzdIXW6UINGqcOoIbmYJ0+0LsBYv3yO8boBYAYH+yfjUQGiK26t
         QEhkjNVQOOxTvnRUb5ABbD8ScPa7TZtb+S1wiUJn/JDsJ/90hH+4yXyzHshKPjgzaknh
         lHQxRfVDaJJHGVizbsLPL6n0QYhhWZJMb5BEYIRNrnIDmAhZSrTYKQvf2MmIDzUJG2H0
         RoEDXwWokD001rFQE6OqCDwYWTz4kx/iOm60Gi/08WDC1ruZIKxaKnZc0XFZxw6wwyYp
         TK9Pddx+bwdmyB1aGGVNXbaz83qZXOwozPJZ9Puuoo4uMrBzeRH+qtIOl5XbgET8kKc9
         a8rA==
X-Gm-Message-State: AJcUukeSLfb88uUalIbwpSXrE3+ZV7ARtcwe0KUujeZmQ0/53cTl2MyT
	y9xWUasIIZlV12sDXcEQgrPRqAyr4yNL1OcYNolHxpVUIbb9BxyYQ1I1LY08mzBQcfgC+mUdRvF
	nEOrwPSJBv8wqGOnrqGS/q8vUcDSd5VqFDf5wG1sGJ3cjlJ9DtM1eFTtCmSgBjyfRwdEVxU4+wk
	EPUt1DUVBgBYom/WF3IB56VBl38mryHG5NX8drmtngc7YihHqL10tExv7uSUkY4LCLIpD2VunDu
	dvlyiv0RNwXoP8oaaQinPsOc796oSn99UkLhuMT+dd/n55uavVmynNsUX6D7O1ICQkvYzMFiLyb
	pBG0YmXpvgIUWW++u/1ah6zhkXIsZQxKzDwz/TMDYc/xaDdvn7GgvzyQMj+EmNiUMGxlRRTgofM
	c
X-Received: by 2002:a62:a209:: with SMTP id m9mr11284225pff.218.1547142284511;
        Thu, 10 Jan 2019 09:44:44 -0800 (PST)
X-Received: by 2002:a62:a209:: with SMTP id m9mr11284178pff.218.1547142283451;
        Thu, 10 Jan 2019 09:44:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547142283; cv=none;
        d=google.com; s=arc-20160816;
        b=GSTOBE619pb+0K/1JhPj8Fa0wbGaJKPrnudizgecVot0HebOtB+ZYj7nXkhZzJK82/
         MvirM3qeoY6ia7hF26kjS6hBUcN0VL48a/mcs8AhCBcnEnYd6yhsDhCdraDH9BluHXVy
         joAtiEbMdTswAK1oaB49FJ+/6/DTtUxRxfugs6KQPmC9d+/TJ2qLFmsoEg2dp93zYR2L
         bBJWzdTOKCH3jDri9I8owJqr6/8efty8uHn/yh+YtL44Aq2qoKnD/UD3Nj7I9sN+9tNj
         9cUCtGSesn6XXWrE9s419H37dZMuoCBwKxf7DpWYJFjM2V/o7TtAGMo9uomi7ZUz3GHK
         9VnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=Gt8KB5JyoxxYaL1/z6NLcbWHN8NvTltGpPlll2SY3FY=;
        b=E4S7ktCvOm4imgRAjyfa27Msauh7GAQVqPDq867xq5T+AV5p/xVI1UDzEvCP20/E0s
         EHsEYthOxkEXhGypt6E1TgdNCdYvMqq3iOvFj4NzwhFM7QJO0LRpIjD7p+fkZ7V/O2Rx
         pHSgAWtTq1mrPMcbGdqY+YR3JhnGzSDYwF6voW3ls/Gj3I4/edSlT/fUet2+zvI9NH9i
         S2tazwOeTmAFGqqUA8UkhZLwmYNJPF5L965IPatGB+z278WDgLi8xSlJ6y0M54kza6VI
         wSP32tP73E6O12URJ24vh1zBNR5NhjQQkELI4//Doa5twcc9JP7vrC/myT+Bs40xJouS
         ikuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rSTdy8Eq;
       spf=pass (google.com: domain of 3ioq3xagkcfkj81b55c27ff7c5.3fdc9elo-ddbm13b.fi7@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ioQ3XAgKCFkJ81B55C27FF7C5.3FDC9ELO-DDBM13B.FI7@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l30sor51200176plg.17.2019.01.10.09.44.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 09:44:43 -0800 (PST)
Received-SPF: pass (google.com: domain of 3ioq3xagkcfkj81b55c27ff7c5.3fdc9elo-ddbm13b.fi7@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rSTdy8Eq;
       spf=pass (google.com: domain of 3ioq3xagkcfkj81b55c27ff7c5.3fdc9elo-ddbm13b.fi7@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ioQ3XAgKCFkJ81B55C27FF7C5.3FDC9ELO-DDBM13B.FI7@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=Gt8KB5JyoxxYaL1/z6NLcbWHN8NvTltGpPlll2SY3FY=;
        b=rSTdy8EqKNDloKVk7yuhlbAdCYfMtPuUgqSsT99xkRUxQP4YdeQX2BlE7gVeyBCUB4
         DpDB0pJiexAVR5wSa5LDB3gsKPGKD+LzAUgOfgBvfmCpIiJlxceVQCSfa9D6WKocBTzg
         CYIeuSwBbcGCiapIrOH0wtIfM2+pZuVqkR2qPKjwZIZ9Q/OaKZ9U6wPPpODCqYJ9tJZc
         6gH3LHZUs7tR7Lr6og9K7DHz8PgDkBLmDPoUWPUCZ0/l1+UuFjyKz4+4VS/zaqdz+l7d
         LPp6BPRean8RE7C8UrsGUuZHKMYV1OYT4HSiOyZMuAh25AbdI6di/fQ+TJzKXPLcvOps
         CAlQ==
X-Google-Smtp-Source: ALg8bN5rgGXJqKPWnPhKUMehyVAYgGxY3tG9TxfIL+HvTrJgvv6Zm3veQ8ppaviiXFDU6l5o7UqGORmhr5huNQ==
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr2405108plb.82.1547142282934;
 Thu, 10 Jan 2019 09:44:42 -0800 (PST)
Date: Thu, 10 Jan 2019 09:44:32 -0800
Message-Id: <20190110174432.82064-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.97.g81188d93c3-goog
Subject: [PATCH v3] memcg: schedule high reclaim for remote memcgs on high_work
From: Shakeel Butt <shakeelb@google.com>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110174432.7dLNbiBKyq7Oy42L6Py3ruZomWKeGbkMPK1kmkhnn4k@z>

If a memcg is over high limit, memory reclaim is scheduled to run on
return-to-userland.  However it is assumed that the memcg is the current
process's memcg.  With remote memcg charging for kmem or swapping in a
page charged to remote memcg, current process can trigger reclaim on
remote memcg.  So, schduling reclaim on return-to-userland for remote
memcgs will ignore the high reclaim altogether.  So, record the memcg
needing high reclaim and trigger high reclaim for that memcg on
return-to-userland.  However if the memcg is already recorded for high
reclaim and the recorded memcg is not the descendant of the the memcg
needing high reclaim, punt the high reclaim to the work queue.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v2:
- TIF_NOTIFY_RESUME can be set from places other than try_charge() in
  which case current->memcg_high_reclaim will be null. Correctly handle
  such scenarios.

Changelog since v1:
- Punt high reclaim of a memcg to work queue only if the recorded memcg
  is not its descendant.

 include/linux/sched.h |  3 +++
 kernel/fork.c         |  1 +
 mm/memcontrol.c       | 22 ++++++++++++++++------
 3 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7d08562eeec7..5e6690042497 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1172,6 +1172,9 @@ struct task_struct {
 
 	/* Used by memcontrol for targeted memcg charge: */
 	struct mem_cgroup		*active_memcg;
+
+	/* Used by memcontrol for high relcaim: */
+	struct mem_cgroup		*memcg_high_reclaim;
 #endif
 
 #ifdef CONFIG_BLK_CGROUP
diff --git a/kernel/fork.c b/kernel/fork.c
index 1b0fde63d831..85da44137847 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -918,6 +918,7 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 
 #ifdef CONFIG_MEMCG
 	tsk->active_memcg = NULL;
+	tsk->memcg_high_reclaim = NULL;
 #endif
 	return tsk;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 953d4ba8a595..18f4aefbe0bf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2168,14 +2168,17 @@ static void high_work_func(struct work_struct *work)
 void mem_cgroup_handle_over_high(void)
 {
 	unsigned int nr_pages = current->memcg_nr_pages_over_high;
-	struct mem_cgroup *memcg;
+	struct mem_cgroup *memcg = current->memcg_high_reclaim;
 
 	if (likely(!nr_pages))
 		return;
 
-	memcg = get_mem_cgroup_from_mm(current->mm);
+	if (!memcg)
+		memcg = get_mem_cgroup_from_mm(current->mm);
+
 	reclaim_high(memcg, nr_pages, GFP_KERNEL);
 	css_put(&memcg->css);
+	current->memcg_high_reclaim = NULL;
 	current->memcg_nr_pages_over_high = 0;
 }
 
@@ -2329,10 +2332,10 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
@@ -2340,6 +2343,13 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
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

