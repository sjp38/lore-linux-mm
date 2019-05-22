Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EBBBC18E7D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:08:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42BE020863
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:08:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42BE020863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEC856B000D; Wed, 22 May 2019 06:08:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9D986B000E; Wed, 22 May 2019 06:08:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8BE26B0010; Wed, 22 May 2019 06:08:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 996DF6B000D
	for <linux-mm@kvack.org>; Wed, 22 May 2019 06:08:26 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id 15so1781790ita.0
        for <linux-mm@kvack.org>; Wed, 22 May 2019 03:08:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JTkPKcZoqc0umMTYWVjyrIIccX3EbqijR3USJmAGcrM=;
        b=rX8RO23xWi3jIbcLffq5glGUmg+FZ1uV8ACtbXJZftyN91OniCTCuQEkmdMPqJCLFv
         sM0Fgsoj1AV9Tf9opSM8rosKG4+Se+SeKKnysRDXbM7H490AmqmorQQzOk0WC9z64xAI
         vaC9bopKMLV5oKNNpy083g01wv/66E9fpy6vnMDVK/cAQocN58jBHtUpsxmEcU0sFIZn
         fPN9Jo6EScmCfcFJjBCtAk7gCksO9srnWkK3uUnr9DFBtJtwEqluW+cZ/yQ/fC9Y2lld
         fmS5YlhHJJApJYjRrBsCjN4np4/4AM4REUSIKnDYfh47OjEoz9w6qwawa8ok/nuUM57G
         Lqmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAX0aGXPEMyW/rP5LlCwbWphuP94hYMCOnv68cIcmzQBt7CVK944
	+MVKeaPJ7eyxacUvcKhRyJt1bjZudCH7cso/NYqrVoSfqhyCuNAP8b7LG5b2gcqBU/298n8IgeA
	Lr5HateAWsTyXhFasoedrACjY0ISR0CZrLFoYBArevY+CA+uux9NDhceyKzfdXqQ2wA==
X-Received: by 2002:a24:47cc:: with SMTP id t195mr7408809itb.117.1558519706377;
        Wed, 22 May 2019 03:08:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFHpG3YFwoecpgPfp+HtjHM5iD3UIcUMGaVC+QqiVVISCi7DG3XMAl0915sX7fEt8Or6Ox
X-Received: by 2002:a24:47cc:: with SMTP id t195mr7408764itb.117.1558519705627;
        Wed, 22 May 2019 03:08:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558519705; cv=none;
        d=google.com; s=arc-20160816;
        b=FQDSdebj80ObHMAj3BqagCI9xdIS76iwuEv9/kIhQls8A52zhfAAmNXuTeHxH/R3vJ
         u6HiqDV79HAuSLE5hMF7w6Z6uBO9u1Q9kP67XmhMu8a+d7AjX9a8d4FN0Lv1xzVB22vS
         oqM+VDnN75iWYw/tNYll0WW/6qUDLzhYYGQ75xCWZPVG//oeQkutZgXRetqUPwPgZs9r
         uFFhZeUjO65TUkGc0rssm3yfx55DpQVqZaztNLHUgdcWvm5D1lwNlzsmfgPxZPSHM/l2
         irzY1pqN+NYjJ4PWWQPza3tZRFAgol+cAh2xqGNtL6hdH1F3zplOsHiH4W7j5hv7efVI
         ed1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JTkPKcZoqc0umMTYWVjyrIIccX3EbqijR3USJmAGcrM=;
        b=HJbxZnT8/B3ac05GWtWxldhbzAfwL5+efodiLENjANn9MYCacO3SISgwnhxcOcPjuC
         rBhXx9XnkS312Wg7dKLa+nWAqmUZ8o1gr+8+mAjN9MYA7Z1UPiEeaR1eCgjjLzZURlXY
         4QOWHFnAOAVHGxnlvLZfBKg1nYCmI32jZ6w9jpz0jBsbIqTb1SnMiP1C6zZqM7+6HD8h
         ydukQuQzTKLiliSKXu4KxSDfKwaEfzuJ7p5b0ff0VceN4QOWzhzzubnwb/kTbnMBBL0c
         ghjNElWqUTV9SWEJxf3tI8bpcHOZflx8sHI7byjtrnFN5p1xpMYKh9sVY0m4zMD4HpMD
         lBWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 129si3623361ity.38.2019.05.22.03.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 03:08:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav404.sakura.ne.jp (fsav404.sakura.ne.jp [133.242.250.103])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x4MA8JZe039260;
	Wed, 22 May 2019 19:08:19 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav404.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav404.sakura.ne.jp);
 Wed, 22 May 2019 19:08:19 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav404.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x4MA8Fdp039015
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 22 May 2019 19:08:19 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 4/4] mm, oom: Respect oom_task_origin() even if oom_kill_allocating_task case.
Date: Wed, 22 May 2019 19:08:06 +0900
Message-Id: <1558519686-16057-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1558519686-16057-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1558519686-16057-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently oom_kill_allocating_task path ignores oom_task_origin() tasks.
But since oom_task_origin() is used for "notify me first using SIGKILL
(because I'm likely the culprit for this situation)", respect it.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 64e582e..bdd90b5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -380,7 +380,8 @@ static const char *select_bad_process(struct oom_control *oc)
 		if (oom_evaluate_task(p, oc))
 			break;
 	rcu_read_unlock();
-	if (sysctl_oom_kill_allocating_task && oc->chosen != (void *)-1UL) {
+	if (sysctl_oom_kill_allocating_task && oc->chosen != (void *)-1UL &&
+	    oc->chosen_points != ULONG_MAX) {
 		list_for_each_entry(p, &oom_candidate_list,
 				    oom_candidate_list) {
 			if (!same_thread_group(p, current))
-- 
1.8.3.1

