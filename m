Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97B1EC43444
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 18:02:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40964218D3
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 18:02:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qwipEX4w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40964218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A47D18E0036; Wed,  2 Jan 2019 13:02:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F70E8E0002; Wed,  2 Jan 2019 13:02:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C0558E0036; Wed,  2 Jan 2019 13:02:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47F038E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 13:02:20 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id a10so24305178plp.14
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 10:02:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=5dUXWnMYVxK4GhlE9mU3i7S+YQhp/yuwfcvNZh6pQ54=;
        b=PUdKL1jNHIgND34wb9eGbxJ/SGku0rSg7dNXE4lyl//Zx4OmscQC1xElK6tt9+c5vo
         BxKdtP4GzApUZ0CRnt6hOIRQlOfdy8zRzbF5rKJYuWCAI/BJvoG7WJY60CwXmh2ha/Vw
         AM6SXbGl3naC7JE77bfqn/DuZo6yKXIpAo9lLFfNudfBuZl7/6kUPN0fTL7QMwpX2RzT
         v3kkoFpauAovhZiFXsdSJZ5FtZCYLrJ2L4ugl9c+d2yb1pbocuKajmfva6INbLZE0iNE
         9ijQv07RFiI8xGqfNawvR5/+cJJY39qc+oMqGu8O30MrMuILZzeus4/H9X9t/6xevY3t
         UxLQ==
X-Gm-Message-State: AA+aEWaq/9ZQLqkCw+nLzwy5lnoE4M1lZ0t+VCBzCSHpiXy9pLIbqi5w
	cWiyPbhNbXX92dvr57eNKEqz/c9riOzBH55ZRHnkyL3TBrL44zOuWMsghdao4Pw0HtwCxaUNLeR
	3S8x8JAsddDhQzxH8BRBNRGlkMLsWJk0FJgbPqrCZLuXSNYGnKNbIaGpkuxGuyCPBemqayRT1oO
	ASkGN3RKbgd85KHCqikFlPMISEjP4WxRYppphy3VaKUOlSfuS8IJxZKJepuvOuArSndnhZ6fsgu
	bCX4FCKOWuRt0tSPYRUM6KGYarbwQaM19CI4AcVe4fo9ho44xVrjiUO3MOTmcwMnx2JAMAYO64W
	f34i5Fo9GXAa+FPWY5N+sFTavvAVwLAmYgvonfY7c1kpwu2T42pa8xGfLYkH17KbgJA38/cSDUL
	V
X-Received: by 2002:a62:34c6:: with SMTP id b189mr46434854pfa.229.1546452139842;
        Wed, 02 Jan 2019 10:02:19 -0800 (PST)
X-Received: by 2002:a62:34c6:: with SMTP id b189mr46434788pfa.229.1546452138997;
        Wed, 02 Jan 2019 10:02:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546452138; cv=none;
        d=google.com; s=arc-20160816;
        b=VTILBRqdzk6aPMsLQ6KfdgkPXvA4p2U7WZBxgDlb0dGwCg+RxVeeKvP0rSzQ8auAF1
         bGFtv7IdDGFjl6mIu8qkaMp2hbfOBbV/qhOzI1SLHZW/etcKHK6XRLt4YITsWX6iztM1
         l4ukXv0owivgsUMCWk6QCDRMI+S6EwdhD9rdCEetYIJZ7qOIIQkNDv3Fg0s7uhLklu6K
         uNz7fYE9gXwwJ5CdCY2IIpMtbJ+djpC1A/Vmkodek7LFZTIGF0fMszWMGsOFmMvSFXtc
         q6Hrq3fzpoYjF0i8A5C9JW6vOO7xunznbZoyH/IuGnSJ3fAxHcfyTh+ReGGGT8BqInJl
         KvAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=5dUXWnMYVxK4GhlE9mU3i7S+YQhp/yuwfcvNZh6pQ54=;
        b=w7drvNgOAhoIkm5Cm3t+OKD72DrRbW76e2fv+/dIy5dUSNlkWRtOsHWVRX6982WFYK
         eHVfsnIMi2rCwpvOTKTxA/4yd4g4yCbeTxCwbZeTTgXQGYltUUEAYb6KxJlbkRYhz85d
         FenWymTO2IBHYWaycuxyO9BA6e16Fy67Kttxk5SLeos89AgSNv1XpWcMc4KxEfdTVmk3
         Xbb4UM3y2dRxxzqhF67fE/2W4hIIYhpkDM5oYTsoEFpVEi0rj/3TquMqltwnLw6XeXg8
         JjyAUXzN33xCQO4O4i7CXmZ3nGYFKJCRMSNuGIqge2CDL7Ro4qhk7CGYwfUeiNaoF5zO
         suWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qwipEX4w;
       spf=pass (google.com: domain of 3qvwsxagkcd8tiblffmchpphmf.dpnmjovy-nnlwbdl.psh@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3qvwsXAgKCD8tiblffmchpphmf.dpnmjovy-nnlwbdl.psh@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id t18sor21692527pfi.23.2019.01.02.10.02.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 10:02:18 -0800 (PST)
Received-SPF: pass (google.com: domain of 3qvwsxagkcd8tiblffmchpphmf.dpnmjovy-nnlwbdl.psh@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qwipEX4w;
       spf=pass (google.com: domain of 3qvwsxagkcd8tiblffmchpphmf.dpnmjovy-nnlwbdl.psh@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3qvwsXAgKCD8tiblffmchpphmf.dpnmjovy-nnlwbdl.psh@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=5dUXWnMYVxK4GhlE9mU3i7S+YQhp/yuwfcvNZh6pQ54=;
        b=qwipEX4wIkJkoVONyw3px8ydt+BiUWSb5U5RBPSsg7mhqCD+4qDp9Uj7JYhb/A9Wor
         HGqBh8MUbe7wxfjpQpqc+O8AenWmE4OjT/7XjR4dKHO72AkllbS6mYl+xwh2rAwMGRVy
         BeEtch55uq4z+z+HihCDU/thB4jlyVfn7Ax0WKYyWHtP4mvf1pkAT/gw9M1obguZFDwz
         VXYecv1XxqTFYnefuQotftd9giuHUU/3eX7wCghZm0IGTbQDkI4F3ArxMZGS8pKURKGH
         GWEb7bvAiTowOkeKfzxgaSbx7UHm1gD5UZrvAN4lhg6X5eSgig7+6g51ewHZVobYp4u5
         SpAg==
X-Google-Smtp-Source: AFSGD/WvKYzExjx3kanWeTXSxjcrXDOcA3b9GU3ybkrL1kzUW/cmA5LtiGb7NwqgZ+pIcpg3kHSdFAwvMzIcAw==
X-Received: by 2002:aa7:8714:: with SMTP id b20mr20428221pfo.85.1546452138509;
 Wed, 02 Jan 2019 10:02:18 -0800 (PST)
Date: Wed,  2 Jan 2019 10:01:45 -0800
Message-Id: <20190102180145.57406-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.415.g653613c723-goog
Subject: [PATCH] fork, memcg: fix cached_stacks case
From: Shakeel Butt <shakeelb@google.com>
To: Rik van Riel <riel@surriel.com>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102180145.VNeKHZEebGkxt8djU6rItN-ugxeovPosmkp3sztT2QU@z>

Commit 5eed6f1dff87 ("fork,memcg: fix crash in free_thread_stack on
memcg charge fail") fixes a crash caused due to failed memcg charge of
the kernel stack. However the fix misses the cached_stacks case which
this patch fixes. So, the same crash can happen if the memcg charge of
a cached stack is failed.

Fixes: 5eed6f1dff87 ("fork,memcg: fix crash in free_thread_stack on memcg charge fail")
Signed-off-by: Shakeel Butt <shakeelb@google.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: <stable@vger.kernel.org>
---
 kernel/fork.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/fork.c b/kernel/fork.c
index e4a51124661a..593cd1577dff 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -216,6 +216,7 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 		memset(s->addr, 0, THREAD_SIZE);
 
 		tsk->stack_vm_area = s;
+		tsk->stack = s->addr;
 		return s->addr;
 	}
 
-- 
2.20.1.415.g653613c723-goog

