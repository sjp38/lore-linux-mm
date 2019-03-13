Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40177C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:14:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA1572075C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:14:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="UstsVZM3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA1572075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EA948E0007; Wed, 13 Mar 2019 15:14:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89C558E0001; Wed, 13 Mar 2019 15:14:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78A918E0007; Wed, 13 Mar 2019 15:14:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 382E68E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:14:07 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id v2so3203229pfn.14
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:14:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GwdSAxFSNzFoZOZJltEAicPXQlohOdwNTSvSF7G15bU=;
        b=Rlm//9XLb/VNTDPrKQWn9QzeihPznLuYr6ozys1VpkMJYjpgzRVnv/7OP7stbTDO6i
         oeu5smjkBx/uBxASf7QfIZkxA1d2269qtMMyElLuW6yWyGGyKiedeTrnMAssVoBJsnGB
         ZDv4CrOHuW8VEebpCsk6jtfyd+R1K//cNgcWG4FLatJwWKAs1B54epCX01oGUDWj53n0
         pzEI/WqbzVYxHIVIAgU5bg7QCzGIlhCMThlpMJiJQfM6VQMeep2sZWNT/I4wYDJ+OYdE
         FXOp41jcQP9uZf6jw8KGsIA5zYqWkH61v5kXsw8a6PupZxNe2wB0uY/WY912NMNlvf3k
         pnIg==
X-Gm-Message-State: APjAAAVUk1gFn1/fAwVBfXgACibkO/t+9qwJnjD55CzYn5XaFBbZ8WV8
	hW+n3PcLmMIqTe3mcHjMXWBpm2cEB87ueOtwDwbl7xSKQ2ao1OGoIopSancHtyVjjcv+h7VUhla
	nsxV0Db0h2yHwOHnj5CBlxCuIHXHjitChu0CXoZ2M+IkhZkOY+BR5rtUvq4Rb6+UtZQ==
X-Received: by 2002:a17:902:5a5:: with SMTP id f34mr16614704plf.35.1552504446889;
        Wed, 13 Mar 2019 12:14:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUW7o7ZNozeNH8nQcX/mMAwaUCcfNICURHqPazh4QoHQxELvGmFXj1pMNJbTfof4hCvtNC
X-Received: by 2002:a17:902:5a5:: with SMTP id f34mr16614652plf.35.1552504446149;
        Wed, 13 Mar 2019 12:14:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504446; cv=none;
        d=google.com; s=arc-20160816;
        b=cNmg7rLrN12eGPo/mIZ+zdQufLEA5dJ0d4CgkZdtZZT6nZv30Ms3+EFegPwmafRFiF
         J/xLs/sM+q/P9o4Zo61UwJ6I5OVAqNk91N6T6pSWNqaXz/oXC+FFryF52Eap5AajSOTj
         FdILdk2OZrRda5nx7Sg1WyZ+96XxbdcV3gPz9dpkwVcfDjiHJ1CHQy394b086/hPHEvL
         KiBYPqj9VOEpdc3nnV5K5bM1S6vUmLm7bb8eupheDdQGz+AxDgUYjYYgcM1KTE/WSIm9
         npj3seer7gmYcyMvjswc2qobaS6oCG+wdyLKQh23h9ruo+AfTQeaJT3XPIwNMTonM4cf
         nJPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GwdSAxFSNzFoZOZJltEAicPXQlohOdwNTSvSF7G15bU=;
        b=pR/aB/kx6C9AY32x55Kiti0eydYLtCtO6R8FpCS7Y63qM+gEZBLwdGGWXKfOuqlWEl
         6s7XC1u0mmF7Jeke3ke3dh2pEFoHjuXBmNqwY3+Uj0n3MXdFi+3eYFvQ51PJjJZxCsHB
         TQ4kBZF4W5E8ztukYVG+APufHvOTt+IW+Tnr5YYIU+qSulxcPRXV2tGhS2tMdwb2tMG/
         9dAzj0XVnOTFnliYZ9i3WEgxdSiJ/jgqhOG0va5lhXV5hHhzCgVJshH4PIw6vj/gAzbo
         agfTiVDeHK0UZLZj19QjaNe8Q5vgg5b3U3jZSeHPyQ8ejkIQv8ojwvFwYl6XHSZ1kUhh
         xYiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UstsVZM3;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f2si10780220pgc.21.2019.03.13.12.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:14:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UstsVZM3;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7CA752075C;
	Wed, 13 Mar 2019 19:14:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504445;
	bh=Tc3kDq2lAPDXt+ynXqMQPMgjQUWNiuK48hTE3Gn3ubs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=UstsVZM3seDfvlM07SuJ+0FHRP2KJWBfTaUcLxYqmpdZadueZDF22n+87wXEMLz2L
	 9ozR6B71Hu1Z7Bpm3oVO/eFPRuBSBDdQ9YkepfWanhIDVo7FLOC/z/Wam0Zu4t/8O8
	 GdaVjLxJMBE38kYsvv0X3/WzFhswrUYIsv4LrY4c=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 28/48] mm: handle lru_add_drain_all for UP properly
Date: Wed, 13 Mar 2019 15:12:30 -0400
Message-Id: <20190313191250.158955-28-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191250.158955-1-sashal@kernel.org>
References: <20190313191250.158955-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

[ Upstream commit 6ea183d60c469560e7b08a83c9804299e84ec9eb ]

Since for_each_cpu(cpu, mask) added by commit 2d3854a37e8b767a
("cpumask: introduce new API, without changing anything") did not
evaluate the mask argument if NR_CPUS == 1 due to CONFIG_SMP=n,
lru_add_drain_all() is hitting WARN_ON() at __flush_work() added by
commit 4d43d395fed12463 ("workqueue: Try to catch flush_work() without
INIT_WORK().") by unconditionally calling flush_work() [1].

Workaround this issue by using CONFIG_SMP=n specific lru_add_drain_all
implementation.  There is no real need to defer the implementation to
the workqueue as the draining is going to happen on the local cpu.  So
alias lru_add_drain_all to lru_add_drain which does all the necessary
work.

[akpm@linux-foundation.org: fix various build warnings]
[1] https://lkml.kernel.org/r/18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.net
Link: http://lkml.kernel.org/r/20190213124334.GH4525@dhcp22.suse.cz
Signed-off-by: Michal Hocko <mhocko@suse.com>
Reported-by: Guenter Roeck <linux@roeck-us.net>
Debugged-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/swap.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 26fc9b5f1b6c..a3fc028e338e 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -321,11 +321,6 @@ static inline void activate_page_drain(int cpu)
 {
 }
 
-static bool need_activate_page_drain(int cpu)
-{
-	return false;
-}
-
 void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
@@ -654,13 +649,15 @@ void lru_add_drain(void)
 	put_cpu();
 }
 
+#ifdef CONFIG_SMP
+
+static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
+
 static void lru_add_drain_per_cpu(struct work_struct *dummy)
 {
 	lru_add_drain();
 }
 
-static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
-
 /*
  * Doesn't need any cpu hotplug locking because we do rely on per-cpu
  * kworkers being shut down before our page_alloc_cpu_dead callback is
@@ -703,6 +700,12 @@ void lru_add_drain_all(void)
 
 	mutex_unlock(&lock);
 }
+#else
+void lru_add_drain_all(void)
+{
+	lru_add_drain();
+}
+#endif
 
 /**
  * release_pages - batched put_page()
-- 
2.19.1

