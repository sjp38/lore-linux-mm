Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AFCCC282E3
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:12:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFD30218D3
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:12:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFD30218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71FDA6B000A; Wed, 24 Apr 2019 07:12:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A7456B000C; Wed, 24 Apr 2019 07:12:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 549086B000D; Wed, 24 Apr 2019 07:12:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0483D6B000A
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:12:46 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id r7so7886319wrc.14
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 04:12:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Nrdy8KLOBuiWA1DS+gjdUN5k8KpcliPOrG7O1lyxcrA=;
        b=sSVjntas4HIVnMmKgIVm3kG7B2zvt3hQD5ojpV3B7XYLdhzMxfY36wk5Bam8DPmNmE
         8UwWGawdX10RMYjxu2o1t3BpO4EwaWROPefhnsahNDrHxXRnlGwkw4O13TJ7IznWvt/X
         hv78+gxUHWm64QaVAObTGcs50FnxFjAwXZfd0q9UfFS5aSbWExk4ZgxKh2cBlWtHYVmi
         KJlVN03taPabObW2W6zm9U75Zgq9QSxc/7BRZtUl8E+e2egKRCNQEJRRa0siWhhy4hiI
         LOS/jmDZIGRUvBRupq//m0zbEUwYhBxWpd8vW0TO2VdxS5YI7nBI5Hy54E4HNOv9OLpE
         VR5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAXONogCGNp/cdclw/g62AxdaIp8ixfB1hA4VMqhoeDZ3OdG3sfD
	G1ECiaHbSfWlbpecTgbhLcAeDqTpvrhZ0MEwz/8onUzJr8wp4ysEGuVdH5sHxe12QREs+nGQORY
	dNOYN1kzb2Rb6m/IJ41pf1vPWOrv/TA/jmr9Rhcg56le+TdRT6HMG1hzASqdRssZ8TQ==
X-Received: by 2002:adf:ec09:: with SMTP id x9mr21931000wrn.187.1556104365546;
        Wed, 24 Apr 2019 04:12:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzo9d9GgidaV+51RMED+QpB0TS2eh8Ko2iewy06X/MohlM1/r7KJX2e/5a9/YSMd3udq/cM
X-Received: by 2002:adf:ec09:: with SMTP id x9mr21930945wrn.187.1556104364683;
        Wed, 24 Apr 2019 04:12:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556104364; cv=none;
        d=google.com; s=arc-20160816;
        b=HrPWftXCf0W4KdBKPz6plG45txC9mC5IG0LgpjGAdYt4w7Ozwtm2eEigskmj6NA+5/
         XHI9Op9hQKmwEzrK2C5bvO3g33H3yH5+Vh07O1tODEKauTZaT3+JNvE+wJU/SfJSI5OR
         r4lj5lNHjkvZ2du/2XDGoX0t40wqCTglzTI8CZRXyk1wxjniZpxg+Y/sUcYz6982TJXh
         r4f3VMZ9kuFub7Q78XaAVL1rtQ0a+idxkYPPCrgRU7IWwVovX2FpeC5zm+T0vodYFTJI
         qrWA2iAFniKgBXTJkkFVJpWs37M9NS3YAvyjYgpA5dOGLA/KTnPhIN3/BBNWs8fDsD+V
         Fn6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Nrdy8KLOBuiWA1DS+gjdUN5k8KpcliPOrG7O1lyxcrA=;
        b=NVPyGOzF8+uYRnqj7q1KKob1MOvjjkAgnMj9GS64oaTM+Z7qLL2HKEU2l0TrT3MrqN
         1ErgEMI6sjSfBYKC9Z0jEqoe7DT74ewZVuR5qOmCnlE/yGLK+wBUoGSfZukxGg5UXV/s
         Tpu4J4kz7ZdALm7nDyZKr84A3vLEsj/BAVn8Fb8C4fdPufDzM1fnCEUbVMxBTy/taZSY
         nC0vLSNcWoa/clyAazl7T4Zxe5A9pbL5e0SDatB7quYHtgR4AFkdSqm+fMU8ZeEMFLCG
         GuZMZDuMBP4P2YoDWdVSECQxWeA+nTmMCms4OkmjN0H/F07gfp/4XumWaUoTwWVVr6ko
         mYWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g130si13144045wmf.140.2019.04.24.04.12.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 24 Apr 2019 04:12:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from localhost ([127.0.0.1] helo=flow.W.breakpoint.cc)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hJFpS-0006KY-OT; Wed, 24 Apr 2019 13:12:42 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de,
	frederic@kernel.org,
	Christoph Lameter <cl@linux.com>,
	anna-maria@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 4/4] mm/swap: Enable "use_pvec_lock" nohz_full dependent
Date: Wed, 24 Apr 2019 13:12:08 +0200
Message-Id: <20190424111208.24459-5-bigeasy@linutronix.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190424111208.24459-1-bigeasy@linutronix.de>
References: <20190424111208.24459-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Anna-Maria Gleixner <anna-maria@linutronix.de>

When a system runs with CONFIG_NO_HZ_FULL enabled, the tick of CPUs listed
in 'nohz_full=' kernel command line parameter should be stopped whenever
possible. The tick stays longer stopped, when work for this CPU is handled
by another CPU.

With the already introduced static key 'use_pvec_lock' there is the
possibility to prevent firing a worker for mm/swap work on a remote CPU
with a stopped tick.

Therefore enabling the static key in case kernel command line parameter
'nohz_full=' setup was successful, which implies that CONFIG_NO_HZ_FULL is
set.

Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 kernel/sched/isolation.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/isolation.c b/kernel/sched/isolation.c
index b02d148e76727..b532f448cab42 100644
--- a/kernel/sched/isolation.c
+++ b/kernel/sched/isolation.c
@@ -7,6 +7,7 @@
  *
  */
 #include "sched.h"
+#include "../../mm/internal.h"
 
 DEFINE_STATIC_KEY_FALSE(housekeeping_overridden);
 EXPORT_SYMBOL_GPL(housekeeping_overridden);
@@ -116,10 +117,21 @@ static int __init housekeeping_setup(char *str, enum hk_flags flags)
 static int __init housekeeping_nohz_full_setup(char *str)
 {
 	unsigned int flags;
+	int ret;
 
 	flags = HK_FLAG_TICK | HK_FLAG_WQ | HK_FLAG_TIMER | HK_FLAG_RCU | HK_FLAG_MISC;
 
-	return housekeeping_setup(str, flags);
+	ret = housekeeping_setup(str, flags);
+
+	/*
+	 * Protect struct pagevec with a lock instead using preemption disable;
+	 * with lock protection, remote handling of events instead of queue
+	 * work on remote cpu is default behavior.
+	 */
+	if (ret)
+		static_branch_enable(&use_pvec_lock);
+
+	return ret;
 }
 __setup("nohz_full=", housekeeping_nohz_full_setup);
 
-- 
2.20.1

