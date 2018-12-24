Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20223C43387
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 09:11:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2F172171F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 09:11:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2F172171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A9D68E0002; Mon, 24 Dec 2018 04:11:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 258888E0001; Mon, 24 Dec 2018 04:11:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11FA68E0002; Mon, 24 Dec 2018 04:11:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id AEC428E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 04:11:20 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id x3so3661640wru.22
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 01:11:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IUfZ4bjB7/T4b0b3RLIppYng0yOMmN/NLKJYbfhY1CM=;
        b=CcINK2omjPEAc1TM6KD9UfEigIxzG16obkWDrcZ+MaaVqJiwftxhH9QLcyKkfee1qp
         SRRANFN74ETO2qL3IuCZDsE3mEpHeO5veSMUJHt1X7BRWcJOfAzY4cUPR5PkMHoUO/8I
         CdZ9IbpTZJYhsHynWfJo5NZU5zmbFkWg0MLP3bsY6txwi1WPOz+NrF/y3MWWVWY3/sCV
         T7w9BpGXfJobPhkRsSTaX7z4Uy3dfwjDGFu5IIRyIP8BA4PuDBUj0/gV4T3c1RbXNtQL
         8ui9BKRkZcAA1EchqeL8k0ccjW8Xr6O2g8EGKBEZ3muszyZDCT+u0Bh4WSLSLCUhLJxt
         ahOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AA+aEWZc0t08iYj0PBFKJc5nf0xqSmLRSNcnVnQdaFyHLNEukVcWhw/N
	vUzN4ASMojQS2/sgCAIypwvWSvGpb7q2STcdrxTMq6o2Jz0jTxJxXJE0OkHuR5jaGMRH/FeDL+e
	QjPqu8yKTtYEkNJFfFA/ngFiYHQX9oDEKAu5zS9yHlCXnHPRc2rwSgSwZrCrjdXAY051XiCvUAF
	OgZzKfSV+7ngf9r47XflefZyEWG7xrLdBOnXM7XqC/X5zBuD+dbxpEnw7nS76jcwDTiPJrtCPdv
	1vIT/FN+37zKIid+Hwf8qHCobQzka4XbeqxyvQJzh9WCnTxaUp/XvS1COXg7TbfB1VEWbTdRX8t
	sa+0mWCRVXuuoIFPIEPjNu938sYV2+DUPZ/8Fp/j9Or41IiJYz1iIe4TXxyPpzAVE6HQusS+og=
	=
X-Received: by 2002:a1c:a755:: with SMTP id q82mr12050694wme.6.1545642680055;
        Mon, 24 Dec 2018 01:11:20 -0800 (PST)
X-Received: by 2002:a1c:a755:: with SMTP id q82mr12050644wme.6.1545642679011;
        Mon, 24 Dec 2018 01:11:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545642679; cv=none;
        d=google.com; s=arc-20160816;
        b=hnKnzFLEuY2vFzgf+loYUQmjHkLbK+LH67RbreS76oL/FHS6RSF76mtjujIXcGjSbH
         bP9hOMSLxDQyux6Sp4+JBhaHnsqEtJ+UP15pBAkxfW4qcjCHWqtZZExOsRvlbrdc9abR
         fHWdgG32YAZUCScrBeacag7hzEy/lgFqDjTe8xu5OIVoQyWoFNG+itaxu+3MixpjnI98
         N2Hq0wOABquE1D/eNPjPaKWpN66CVYs+XoxLXSKAoWoTO+dZ2qr49Y7mywXeROB65SqE
         G3XuehDQ8SFNFcVZgLwGmwBjEgMOpYLF5x4jN5nJyU3QNGYrSxZeu0WcF0TplnutSBag
         Z76Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=IUfZ4bjB7/T4b0b3RLIppYng0yOMmN/NLKJYbfhY1CM=;
        b=km8D58Zs+R5oWhxBI0JjRr6frx02oqs/xjM63QpoWlFwtoTmvjyGCKYM1694qmLOdv
         8wp0kreotbEhvOPkzgEmjH3eOgcq95VoIQvI4/z3rMf6QQMNkWFBNfG5sq9kEr/NUz4I
         MQ5EcCD0oUPzr6HtBHPHn3a9S7QhNRzdg6ihk+kP/9K54q1eqgaJ93gHnis2JWDpfbm+
         n/6FnIYMNkxr8VkF5GPh/0Q4ixYZkchRYtPi1vZujg1+eiOlveUfqV0cIq1wngsOuDdL
         xiY/xpj02Q2+79OpYKiPZC6oB2P4ZCHqwrxD6i11q/ZSm8V3Xy6vyGrcGZ7eRS9C7w3O
         hrXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h126sor12667283wmf.21.2018.12.24.01.11.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 01:11:18 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AFSGD/UrnbShdOEX9tgTI9VOtu/OA5auG2lOOXfzMPyYnxxle+3SVZPRU+cvADHmGRyI364ntG+nKQ==
X-Received: by 2002:a1c:a8d2:: with SMTP id r201mr11171339wme.81.1545642678455;
        Mon, 24 Dec 2018 01:11:18 -0800 (PST)
Received: from tiehlicka.suse.cz (ip-37-188-137-231.eurotel.cz. [37.188.137.231])
        by smtp.gmail.com with ESMTPSA id c129sm14462948wma.48.2018.12.24.01.11.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Dec 2018 01:11:17 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Burt Holzman <burt@fnal.gov>,
	cgroups mailinglist <cgroups@vger.kernel.org>,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Stable tree <stable@vger.kernel.org>
Subject: [PATCH] memcg, oom: notify on oom killer invocation from the charge path
Date: Mon, 24 Dec 2018 10:11:07 +0100
Message-Id: <20181224091107.18354-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <5ba5ba06-554c-d1ec-0967-b1d3486d0699@fnal.gov>
References: <5ba5ba06-554c-d1ec-0967-b1d3486d0699@fnal.gov>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20181224091107.YmwSmLcgZcnxNVzKEpLqBeU6o202vDkWBnV8j4b3pwg@z>

From: Michal Hocko <mhocko@suse.com>

Burt Holzman has noticed that memcg v1 doesn't notify about OOM events
via eventfd anymore. The reason is that 29ef680ae7c2 ("memcg, oom: move
out_of_memory back to the charge path") has moved the oom handling back
to the charge path. While doing so the notification was left behind in
mem_cgroup_oom_synchronize.

Fix the issue by replicating the oom hierarchy locking and the
notification.

Reported-by: Burt Holzman <burt@fnal.gov>
Fixes: 29ef680ae7c2 ("memcg, oom: move out_of_memory back to the charge path")
Cc: stable # 4.19+
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi Andrew,
I forgot to CC you on the patch sent as a reply to the original bug
report [1] so I am reposting with Ack from Johannes. Burt has confirmed
this is resolving the regression for him [2]. 4.20 is out but I have
marked the patch for stable so it should hit both 4.19 and 4.20.

[1] http://lkml.kernel.org/r/20181221153302.GB6410@dhcp22.suse.cz
[2] http://lkml.kernel.org/r/96D4815C-420F-41B7-B1E9-A741E7523596@services.fnal.gov

 mm/memcontrol.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6e1469b80cb7..7e6bf74ddb1e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1666,6 +1666,9 @@ enum oom_status {
 
 static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 {
+	enum oom_status ret;
+	bool locked;
+
 	if (order > PAGE_ALLOC_COSTLY_ORDER)
 		return OOM_SKIPPED;
 
@@ -1700,10 +1703,23 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
 		return OOM_ASYNC;
 	}
 
+	mem_cgroup_mark_under_oom(memcg);
+
+	locked = mem_cgroup_oom_trylock(memcg);
+
+	if (locked)
+		mem_cgroup_oom_notify(memcg);
+
+	mem_cgroup_unmark_under_oom(memcg);
 	if (mem_cgroup_out_of_memory(memcg, mask, order))
-		return OOM_SUCCESS;
+		ret = OOM_SUCCESS;
+	else
+		ret = OOM_FAILED;
 
-	return OOM_FAILED;
+	if (locked)
+		mem_cgroup_oom_unlock(memcg);
+
+	return ret;
 }
 
 /**
-- 
2.19.2

