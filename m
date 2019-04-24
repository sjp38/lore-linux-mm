Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE11FC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:12:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A91B1218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 11:12:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A91B1218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5988A6B0008; Wed, 24 Apr 2019 07:12:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 520326B000A; Wed, 24 Apr 2019 07:12:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E97D6B000C; Wed, 24 Apr 2019 07:12:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E5F6C6B0008
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:12:40 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id t9so17413130wrs.16
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 04:12:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DIn5FEbRXYQzdZBIvpyZtr7sGYOlqQ3CKLeCoHcIFJI=;
        b=EHPOroHkBXyRuQqEMfpS6rrnLhstH5BfGTNNF38WXWw+l8HqCNilX4S09GNuhslJWm
         hJV2XxgP2xtwKldJRCNHgzr8D/gptNCJ+Pbv/6V2y/sECELzPwTki8DpytpVycdCt/s9
         pdSUuqkNz6ZgKNjMvq1YeBI73b2pV7aIUSXgAUwn1pSQ8dQmBL44SmfSYX4FdyAlDF2Q
         85RWqlcgUqsRihV2MI/Pwp+ehbVw6NO2sjOAK3Thr8xx6JNZLYKkpR/WG/jRvGReZg1+
         cVP0IC7X9y4A0P9N1p2pIrfSF1NdcrP3xDIaezt158fPwRUCqErOhCsEBvdb5Of16LVQ
         1BlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAUOCLHpDkpOQR5E/wSb58LdKUIPdnQ3c7AKkEeR2KrrLAsvNQMr
	JOs642MVEwdb4QN8yPGuyC3dOtzDZNUn2wslOBcVIQyOpaEiQP4n4JM9k+e0aDfym+G9EOEgEnE
	T6VAzyx7o/e9xOk83OtQqrGquBe2359ob3ukDCaRBfpAMTavhhHy2SqYlZW+b+ffqrg==
X-Received: by 2002:a5d:6848:: with SMTP id o8mr6426032wrw.204.1556104360404;
        Wed, 24 Apr 2019 04:12:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzX97uhTFodJ1QsuwvLCXJnBdenyVyLJvrd+F1coAKQth47A2i9bBKxzqjpGrRJxhQUidYh
X-Received: by 2002:a5d:6848:: with SMTP id o8mr6425984wrw.204.1556104359561;
        Wed, 24 Apr 2019 04:12:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556104359; cv=none;
        d=google.com; s=arc-20160816;
        b=qUheegLreovQh0i91Y1Fi7SjBCTRc5DisxG9DGmFHyjE3q89xeMlqNs6JA7i/Iq2S3
         q9zDvYhY+Rgy9MatfYm6BnqhYDt4CBadm3wJF/e/y8I3qXgGncIMyynjmcqRaYDJpzZg
         SiR7hSX160FL20mHR2cKd8BypyiouqvO2tnb8t9TRnYtZlJ2JRdcX1qUPZluqe13Axml
         z4YfVKnY0R0FIpljMLjPpTKvn49R4PVMM+CnQj7GHOZMgVU33TGdqMk4vD4vRowVO1vC
         n/GT9LAuw26p9yDw4bezLMW+V6YhQ5r3mPIOWPEqco0CKJh9/KQWjn/n6iO8h5ypoD9W
         TRiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=DIn5FEbRXYQzdZBIvpyZtr7sGYOlqQ3CKLeCoHcIFJI=;
        b=bsEcpXXxf0NRwYI5B2UTHRd+NmpWRuCkZ8CIAjXWJ14mcplXpLxHESHrI0wx9691yu
         PPrj/eAx2aoyr02/bt63o5WDM9FyDPtKNxZb+bZbXiQzNV4bjM0a0fhT5eioPJQOmU94
         /C7QLbKr2cqMtGBigWBZfkZurCANdpP3fJedA1+aXAWmWgiXsqoDTRLd+pCva+4N/qDQ
         Vf0g6q/qwRMZJsTaWTRpPIdg0XO4xrHp/QdHXMpdkJJXBHBjur4h9+9/tEIU98jxdwdi
         MeicunYNWBlEU1FR8BZdygcIpqGTJa4hqlPd1UEohU2o8W9BDohN/d7vJKvHrm9tucAu
         1iRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z9si3588666wmi.28.2019.04.24.04.12.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 24 Apr 2019 04:12:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from localhost ([127.0.0.1] helo=flow.W.breakpoint.cc)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hJFpN-0006KY-Rs; Wed, 24 Apr 2019 13:12:38 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de,
	frederic@kernel.org,
	Christoph Lameter <cl@linux.com>,
	anna-maria@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 3/4] mm/swap: Access struct pagevec remotely
Date: Wed, 24 Apr 2019 13:12:07 +0200
Message-Id: <20190424111208.24459-4-bigeasy@linutronix.de>
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

From: Thomas Gleixner <tglx@linutronix.de>

When the newly introduced static key would be enabled, struct pagevec is
locked during access. So it is possible to access it from a remote CPU. The
advantage is that the work can be done from the "requesting" CPU without
firing a worker on a remote CPU and waiting for it to complete the work.

No functional change because static key is not enabled.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/swap.c | 75 +++++++++++++++++++++++++++++++++----------------------
 1 file changed, 45 insertions(+), 30 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 136c80480dbde..ea623255cd305 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -774,7 +774,8 @@ static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
 
 static void lru_add_drain_per_cpu(struct work_struct *dummy)
 {
-	lru_add_drain();
+	if (static_branch_unlikely(&use_pvec_lock))
+		lru_add_drain();
 }
 
 /*
@@ -786,38 +787,52 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
  */
 void lru_add_drain_all(void)
 {
-	static DEFINE_MUTEX(lock);
-	static struct cpumask has_work;
-	int cpu;
+	if (static_branch_likely(&use_pvec_lock)) {
+		int cpu;
 
-	/*
-	 * Make sure nobody triggers this path before mm_percpu_wq is fully
-	 * initialized.
-	 */
-	if (WARN_ON(!mm_percpu_wq))
-		return;
-
-	mutex_lock(&lock);
-	cpumask_clear(&has_work);
-
-	for_each_online_cpu(cpu) {
-		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);
-
-		if (pagevec_count(&per_cpu(lru_add_pvec.pvec, cpu)) ||
-		    pagevec_count(&per_cpu(lru_rotate_pvecs.pvec, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs.pvec, cpu)) ||
-		    pagevec_count(&per_cpu(lru_lazyfree_pvecs.pvec, cpu)) ||
-		    need_activate_page_drain(cpu)) {
-			INIT_WORK(work, lru_add_drain_per_cpu);
-			queue_work_on(cpu, mm_percpu_wq, work);
-			cpumask_set_cpu(cpu, &has_work);
+		for_each_online_cpu(cpu) {
+			if (pagevec_count(&per_cpu(lru_add_pvec.pvec, cpu)) ||
+			    pagevec_count(&per_cpu(lru_rotate_pvecs.pvec, cpu)) ||
+			    pagevec_count(&per_cpu(lru_deactivate_file_pvecs.pvec, cpu)) ||
+			    pagevec_count(&per_cpu(lru_lazyfree_pvecs.pvec, cpu)) ||
+			    need_activate_page_drain(cpu)) {
+				lru_add_drain_cpu(cpu);
+			}
 		}
+	} else {
+		static DEFINE_MUTEX(lock);
+		static struct cpumask has_work;
+		int cpu;
+
+		/*
+		 * Make sure nobody triggers this path before mm_percpu_wq
+		 * is fully initialized.
+		 */
+		if (WARN_ON(!mm_percpu_wq))
+			return;
+
+		mutex_lock(&lock);
+		cpumask_clear(&has_work);
+
+		for_each_online_cpu(cpu) {
+			struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);
+
+			if (pagevec_count(&per_cpu(lru_add_pvec.pvec, cpu)) ||
+			    pagevec_count(&per_cpu(lru_rotate_pvecs.pvec, cpu)) ||
+			    pagevec_count(&per_cpu(lru_deactivate_file_pvecs.pvec, cpu)) ||
+			    pagevec_count(&per_cpu(lru_lazyfree_pvecs.pvec, cpu)) ||
+			    need_activate_page_drain(cpu)) {
+				INIT_WORK(work, lru_add_drain_per_cpu);
+				queue_work_on(cpu, mm_percpu_wq, work);
+				cpumask_set_cpu(cpu, &has_work);
+			}
+		}
+
+		for_each_cpu(cpu, &has_work)
+			flush_work(&per_cpu(lru_add_drain_work, cpu));
+
+		mutex_unlock(&lock);
 	}
-
-	for_each_cpu(cpu, &has_work)
-		flush_work(&per_cpu(lru_add_drain_work, cpu));
-
-	mutex_unlock(&lock);
 }
 #else
 void lru_add_drain_all(void)
-- 
2.20.1

