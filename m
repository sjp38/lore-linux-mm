Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06A8AC4151A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 15:05:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4C0F218A4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 15:05:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="WeX1RBp/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4C0F218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 424228E00C1; Wed,  6 Feb 2019 10:05:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AD358E00B1; Wed,  6 Feb 2019 10:05:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24ED58E00C1; Wed,  6 Feb 2019 10:05:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id BD5448E00B1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 10:05:31 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id t21so1053571wmt.3
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 07:05:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=9IBLfaavppi758OCjdB947t6koYFqHTGyhMEeJMJjcA=;
        b=ZkyRsNztLDF2vz0m6gk85+8sRTjexo/iVMXeWQ8UFjlvquZ1IMVrq8I+dB2iTWiQNV
         Y51WEfSiMEdUj4KxAnGCqp5IF3PstYJDW5NioaGhOFwhh3mo6ArG37vG+fQMRDvwtMvB
         4jxWsMuO20Ores50mTjJ6+GZcP62EESJfQR+h7YcgzIDWOUPkHdibI6qi1Ux3i4OF3pH
         BDT2vyLII/RvxiIeklQkLb9sF/khj8oAxJ16NxoEfkQebdHcvXlubI3ZXlKlMKKbr0t+
         gQD6gSLuZcW+MnlhFCXePVbag3M3DZHdVjJM35f6V/O0K7fP8TjD0SZ6YtRglM5oqteS
         nXww==
X-Gm-Message-State: AHQUAua6sR9ya/zuzrkZVzpVYl8xzFLyz8zHsG6UbvNLvbBbfGIa/Yfy
	pV4uYm0J+nGU5S/kG1gpj0DFLzCgmyj+dBbuyPT5V3kvnU4o8DbpdJF5h82brmbwBzMXrf6UWLp
	YVhN0DDI5muSXFzheLygiNw4Ex7DFsJDSv7OQFsE1mXV/8Sbezh/RBorNXf5vl/2fw8H2xUlc7A
	x8Q6LXko7w38mn0ByNQ1c1qPiQL/XEm5PbadqIJqGfo6au49AwNPCL/7c/RUHgN2jf5jCsRadkK
	lnw7p2VugDeOOK3hujL/KHkjHVPKDrPQEIjvrBAogKtjiLGyofcWQdKVUFlP49y9LDTZo75+uRU
	v7O+j8p/qrt41pt5KGfwug+ccKZvyVBPMRol+mxIamtUu9SNvoJb5Wq7sLgtnYO18Q1fZD0lAVJ
	3
X-Received: by 2002:a5d:620d:: with SMTP id y13mr2398282wru.119.1549465531166;
        Wed, 06 Feb 2019 07:05:31 -0800 (PST)
X-Received: by 2002:a5d:620d:: with SMTP id y13mr2398216wru.119.1549465530218;
        Wed, 06 Feb 2019 07:05:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549465530; cv=none;
        d=google.com; s=arc-20160816;
        b=x2a7B2TNNFK8/PdqEgw9nWWnc7VCDhAOTjwkRgoos8wjYaFf8D5Nt68oOe6C1ZXnP2
         PKct+uRwevM0smBqINsNFiNLTHsDBz9I+wIY/nKF4/2OcL5taKXgDtIbN9F574e3VKhy
         md/Cgs8niRD2QzFv0smC7MFOedby8nNZjk4qZtysy8k5GNeT1d8a5FqafmPBKbapA5lk
         RWaPWM0Niq4CODSakWy6V/NueezsgdWWhGihniL71EB+zcBovWAwsD5iut7zP5spwHuq
         Q6gSEBWn2zarteHwCc5PYuRxshkKKMJtSzrfbEZdTK4+cv1Oc/Q9yk4zQYUkrqV6tMUr
         tDyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=9IBLfaavppi758OCjdB947t6koYFqHTGyhMEeJMJjcA=;
        b=qRHJrXys2FNpo4TJFszViPXJfN2VAxrNQixGsX94DfhdoK1LqVeifh6W9FnQEhgybQ
         2tTD60tHJdmTemvBY4kY3lZNB3dzO2ZpMQTUkU1vE7Y2s0ofUEkjYt1N2ZYnAHDYz1nH
         DnVi/2Gco/b3FAaitxqq7qPbXfkjN9iKMTgWfOFCcfG6Btdyk8veEUKeqIThQNN3BHWa
         3dbWwHv5bREIS0O7APmwhCa/TjVLG7Vun7LTlQ/y14fBdES61dnE6bPirS3gyI+VQLO6
         uAF2XWxXRmZC65YRcodBFRIQolLk5JSkrPIou3N1/Vfqhu4eHgORpUyEROx4sLsPAA/g
         dorQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="WeX1RBp/";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y64sor7400754wmc.26.2019.02.06.07.05.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 07:05:30 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="WeX1RBp/";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=9IBLfaavppi758OCjdB947t6koYFqHTGyhMEeJMJjcA=;
        b=WeX1RBp/CcBQkfXjggkfmEjTC8/LsW/ZK4tTOwMymJy0sFUXTlU5DhRI0QK3AQj7FA
         dL48Gs73dLPoVlEb5+tPZkqdYCShxowjg4MMz7qz+tGDKZ6VR5GcKMYuSuodqDPXM52B
         mIKcjGjjxjbyq4BmGlQQogkGUPeOvpiJWf8oW/CGP56Be8GFxhSXuvmCyfY+Ivyuc+Ih
         RjGvktUGafPHuD/GO2SBHflO3psKkTPDKH1oIOxSP+BTUAorx8US4ShzIo8sEChOuBXF
         kL51yLqy3ayPh+WOM2mFmxthMmVDr1rBbaZwBe2r2q1pDJYVhBq/wrOlfFUgCuJMuqvf
         GcBQ==
X-Google-Smtp-Source: AHgI3IZv8Dc/NO0zwMnknC1uQ9e87UXxRgqhftEL5QcOBvvK2AZ4r+f++qTEdbDPzlQTI1nlLhX7hw==
X-Received: by 2002:a1c:7406:: with SMTP id p6mr3571209wmc.141.1549465529711;
        Wed, 06 Feb 2019 07:05:29 -0800 (PST)
Received: from localhost (p200300C44723CCF50E7AC8E3657171F5.dip0.t-ipconnect.de. [2003:c4:4723:ccf5:e7a:c8e3:6571:71f5])
        by smtp.gmail.com with ESMTPSA id v132sm18924789wme.20.2019.02.06.07.05.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 07:05:29 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH] kernel: workqueue: clarify wq_worker_last_func() caller requirements
Date: Wed,  6 Feb 2019 16:05:28 +0100
Message-Id: <20190206150528.31198-1-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This function can only be called safely from very specific scheduler
contexts. Document those.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 kernel/workqueue.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

Andrew suggested including the explanations that came up during the
code review in the function doc. As the function has since been
merged, sending as follow-up for 5.1. Thanks!

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index fc5d23d752a5..23a67b9430da 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -918,6 +918,16 @@ struct task_struct *wq_worker_sleeping(struct task_struct *task)
  * CONTEXT:
  * spin_lock_irq(rq->lock)
  *
+ * This function is called during schedule() when a kworker is going
+ * to sleep. It's used by psi to identify aggregation workers during
+ * dequeuing, to allow periodic aggregation to shut-off when that
+ * worker is the last task in the system or cgroup to go to sleep.
+ *
+ * As this function doesn't involve any workqueue-related locking, it
+ * only returns stable values when called from inside the scheduler's
+ * queuing and dequeuing paths, when @task, which must be a kworker,
+ * is guaranteed to not be processing any works.
+ *
  * Return:
  * The last work function %current executed as a worker, NULL if it
  * hasn't executed any work yet.
-- 
2.20.1

