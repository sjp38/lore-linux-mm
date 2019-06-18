Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5C02C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 10:24:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 917692085A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 10:24:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 917692085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2946A6B0005; Tue, 18 Jun 2019 06:24:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 244F08E0002; Tue, 18 Jun 2019 06:24:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1346F8E0001; Tue, 18 Jun 2019 06:24:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id E93946B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 06:24:07 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id t198so4702912oih.20
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 03:24:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=AvrxHp0gzy1y4LIfR1p0YscwaVAorkw2TRpxZ1Kb7eI=;
        b=rIpzDa/SW3Xr/O35igmf4sQEQzS8kNqi+vvDaKS8t9Ku81IIrOuDsGyYtCSVbovb+y
         pEGEZgNVjiGVc98kTBa6y4dDC+T+Fd/MDYpMLGOzzG4HSZg0cj9NYQNwEqXrw9Z7lqTS
         ExZDDgQuzkiYPcAlrsxC+faQWBKl7kzwHOzdMvbHl6BhsOIMoWfyY+gfOrQU8nMQDrQV
         twAJGmIA9bkdDgofHYQbnrPzqWcGT5DEE9gfHGNOhPUP7PzyXdof2Gar1BDya7E1GS4R
         uLX1ixLp0ujX7w3HMddHw2sEU21tScaBiMoHc/mbbD98zawChL1gjyqBiqMiHJmTbGZ2
         M+4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAWeUr0vBVoYlH62CvAOG7CmtByLCG6JLsiJZ+tWBqfR98e4M1GQ
	lz64aFm01tcj3Imm5naPUwBQ3EVVWgrwZH/s24FYoAsvswjzYdxK6VvQCt58z/5Otj3cVRPuo2q
	JxP/qiGpll4M3gOsujMNtv6KRGDxI0Ri75jxDF2H+kcKCpFW7EXHPcgMgGFJqL3RejQ==
X-Received: by 2002:a9d:6289:: with SMTP id x9mr16354794otk.82.1560853447636;
        Tue, 18 Jun 2019 03:24:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydUCGaupx30QgqhnGmt2t7C12ZkhUYJ3rtSnfA9d+WC10UV3FYjVPNeb75Yly6YA4sKjgZ
X-Received: by 2002:a9d:6289:: with SMTP id x9mr16354735otk.82.1560853446825;
        Tue, 18 Jun 2019 03:24:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560853446; cv=none;
        d=google.com; s=arc-20160816;
        b=czBYzTPLI/4+pYf3JCsjOgktpZEj1QfZHDrmKRPkPNDhxf0aZ0GY3Nf/N+pVwvJQOf
         Ya92kO+bLYNN6YOqrN67V89j6scYC9uSDXSkJo0ve9vd3pKTKOSyk2c/jV0CevjDoBiR
         beuu+sbCdYkIKboYFzlGuk8+QZ6Gv2bCCd2Repte/KuqPD1lfa5Ws/DG7cixnyoJgICo
         QU607WbuLfEwRJe9NZSQC3yESCQS+PTNfaP2tDIk87JcXduxtfkTUul6Huk+cu/GaYVz
         BgWWewwpgir49/FPEzfZhVmHboyM79aw463dlL6oCKhC6yPoFVYDtLqkMXnpM0wJ79KA
         cH3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=AvrxHp0gzy1y4LIfR1p0YscwaVAorkw2TRpxZ1Kb7eI=;
        b=IMnSJzHLOQ9z0eM7Vy7dhrcJx6mpg9Bc03FXbdNpDGpGs/G4WRqO+9JO8pwj73bvGZ
         KWgYzbtLCuJcAva2QxecRkcgXKuB67a6STbkVs8JWxEYzki4X/aVqMebqFmoo1FCC/pO
         XdfyNgr10fXN5+ilmkghiBHbFZ/CxgpRrAgEilaxO0hYCWsgg8tEgV7ooK7J1iKnrh5e
         ZZLE7pqqhyRzqIugUPRhEpcNXfxopF/44U27Sxk6biPF2ymTlD+k7x5OhdyzEh2Hhqi/
         P9TF9tKD3+t/2czR2E1tHfAVZL+vAfqznGdQAwOiiP7kBaSZwrw3MGaR7ETjsI3XoDSP
         YB/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 5si8855727oto.141.2019.06.18.03.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 03:24:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav305.sakura.ne.jp (fsav305.sakura.ne.jp [153.120.85.136])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5IAO0qE069006;
	Tue, 18 Jun 2019 19:24:01 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav305.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav305.sakura.ne.jp);
 Tue, 18 Jun 2019 19:24:00 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav305.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5IANu2B068841
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 18 Jun 2019 19:24:00 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm, oom: Remove redundant OOM score normalization at select_bad_process().
Date: Tue, 18 Jun 2019 19:23:55 +0900
Message-Id: <1560853435-15575-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit bbbe48029720d2c6 ("mm, oom: remove 'prefer children over
parent' heuristic") removed

  "%s: Kill process %d (%s) score %u or sacrifice child\n"

line, oc->chosen_points is no longer used after select_bad_process().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 09a5116..789a1bc 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -380,8 +380,6 @@ static void select_bad_process(struct oom_control *oc)
 				break;
 		rcu_read_unlock();
 	}
-
-	oc->chosen_points = oc->chosen_points * 1000 / oc->totalpages;
 }
 
 static int dump_task(struct task_struct *p, void *arg)
-- 
1.8.3.1

