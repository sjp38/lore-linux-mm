Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94643C43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 14:05:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58244222E6
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 14:05:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58244222E6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E78F88E0003; Sat, 16 Feb 2019 09:05:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E28518E0001; Sat, 16 Feb 2019 09:05:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D16B78E0003; Sat, 16 Feb 2019 09:05:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC348E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 09:05:48 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 74so9765073pfk.12
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 06:05:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=3yiOk3fW8B9YI7fDynhQbOuHXacNLrNR0dG5TjY2/WI=;
        b=FO9DDEPNkfK+ctRLVy85vQFeHOM2RwSSNQeLFyrcwoZIhyBRmpnBXCjK4SR4DxY50R
         y+hH/H4eokjzQz9Xpat06gvLXUf6KXLMj0jhzGWps8YBnaclvVI4+lvU5HJR0tZy5cOV
         phceblaYNlgODXSP/xlwOJp+HavLYadwyme/bYt4IaHjs4vd/CFcv20Ccw4CoNzhuuuD
         I4ALiWVxEd/QYzaOwbUiyNVkMHE4pZ4NG6qpeeYavG4W0ma9BRe4zrtId1MR2LOe+UML
         okqb7hupdIDUfS1aC3csqW7p1ysq3FcyB5Wb/mv5f2+7yJJtr+GmibwtH6G5BLinu7Nm
         q6OQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuZhK/NRM+2IUB/KIdNg42fJaOkctKUgRfhCmOX8u7DPV/8RCGn3
	QAYTg/VRpPyWOoMEsO7LBhdPNmxlLyj+kkkAQglx0w1HDfSt6Rym7smDCjGzQDOopcIoOs3/Cw1
	GOXx4/wnphOSZizbWtcQETuaJk8qwRR3A6SwO/6EjqKGnSa7V46ruzsY/N74/M6xjDg==
X-Received: by 2002:a65:500c:: with SMTP id f12mr10106293pgo.226.1550325948186;
        Sat, 16 Feb 2019 06:05:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaPW8Qk6psU85JFknf3ehqyffa1aLmaYAPwxZ8feNguZOfNS45hLCih9iSSs9Vaey2qaCSK
X-Received: by 2002:a65:500c:: with SMTP id f12mr10106212pgo.226.1550325946964;
        Sat, 16 Feb 2019 06:05:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550325946; cv=none;
        d=google.com; s=arc-20160816;
        b=rUye0PQI/IYR6+2wG6xNxaBN6/DO1fx6ub7qgALUtkiHLFUdsPLaN/T4J3eNFOhUSu
         UfqLdmcIdqN5C0qoqNFp8y2PdloxIuja9pLn+cDk/Z/YIMMXzQcUz60xUA8SbvHJw8XO
         DFUFLG4DoSZ3VUYFbAuvNCLKg26ap2Jivjtva5aHAu+5QeFyQgJl7UcY2nX9d+h+fOa2
         7jzKg+MfyMY3FoK5TQRWcXIxjNKgdh1WfPApbkOW0EbbrOEHkyMQj2oE1YsRPB7E52fb
         0v5P0t71uZLcCFYd+VoajdxKE/7DGDYUO3n4BwapQtLwrAqyCSt1F9GeBq57xntdKn1p
         h3iA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=3yiOk3fW8B9YI7fDynhQbOuHXacNLrNR0dG5TjY2/WI=;
        b=1LAZ8mYp2dkcauOfkB6RIkubrHofapmEroot+r05xZmZaZzKk06LV8XIsveGK2iC9T
         mIXHAAvEW0ivKsLMmXbiqvMmDXH52QM7sGnChaMSqfFUvrBRWiOaNHw6z+Xl3Zz1d8PO
         idMqlAgIE20NI+uA/sD0DjMECiuxcjAq6tXXYOi0n4d+R78R0fjJOWlkWQek2WdOrSkb
         yVSnLF0eCWm8l8sEPcMuqJbuvMbCSaG1aPOFL9OuS5YyoD6bNzXinqVgS/lf4reD1K4O
         ApScJtNVjDgLXy056RRhHH8Q9LWwUZ6NaKXpmtifpu1RPd6uyWFsFkxXxMFfSb4lkLIc
         F8mA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o11si8144323pls.374.2019.02.16.06.05.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Feb 2019 06:05:46 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav106.sakura.ne.jp (fsav106.sakura.ne.jp [27.133.134.233])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1GE5ARh080455;
	Sat, 16 Feb 2019 23:05:10 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav106.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav106.sakura.ne.jp);
 Sat, 16 Feb 2019 23:05:10 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav106.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x1GE4v8u080234
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Sat, 16 Feb 2019 23:05:09 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>,
        Roman Gushchin <guro@fb.com>, Yang Shi <yang.s@alibaba-inc.com>,
        yuzhoujian <yuzhoujian@didichuxing.com>
Subject: [PATCH 1/2] mm, oom: Don't ratelimit OOM summary line.
Date: Sat, 16 Feb 2019 23:04:54 +0900
Message-Id: <1550325895-9291-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since the owner of oom_lock cannot send SIGKILL before dump_header()
completes, we need to ratelimit dump_header() in order not to stall
concurrently allocating threads. As a preparation for more aggressive
ratelimiting, bring the one liner summary out of dump_header().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: yuzhoujian <yuzhoujian@didichuxing.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Yang Shi <yang.s@alibaba-inc.com>
---
 mm/oom_kill.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3a24848..254c7fb 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -440,7 +440,7 @@ static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
 		from_kuid(&init_user_ns, task_uid(victim)));
 }
 
-static void dump_header(struct oom_control *oc, struct task_struct *p)
+static void dump_header(struct oom_control *oc)
 {
 	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), order=%d, oom_score_adj=%hd\n",
 		current->comm, oc->gfp_mask, &oc->gfp_mask, oc->order,
@@ -458,8 +458,6 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 	}
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(oc->memcg, oc->nodemask);
-	if (p)
-		dump_oom_summary(oc, p);
 }
 
 /*
@@ -960,7 +958,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	task_unlock(victim);
 
 	if (__ratelimit(&oom_rs))
-		dump_header(oc, victim);
+		dump_header(oc);
+	dump_oom_summary(oc, victim);
 
 	/*
 	 * Do we need to kill the entire memory cgroup?
@@ -1002,7 +1001,7 @@ static void check_panic_on_oom(struct oom_control *oc,
 	/* Do not panic for oom kills triggered by sysrq */
 	if (is_sysrq_oom(oc))
 		return;
-	dump_header(oc, NULL);
+	dump_header(oc);
 	panic("Out of memory: %s panic_on_oom is enabled\n",
 		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
 }
@@ -1086,7 +1085,7 @@ bool out_of_memory(struct oom_control *oc)
 	select_bad_process(oc);
 	/* Found nothing?!?! */
 	if (!oc->chosen) {
-		dump_header(oc, NULL);
+		dump_header(oc);
 		pr_warn("Out of memory and no killable processes...\n");
 		/*
 		 * If we got here due to an actual allocation at the
-- 
1.8.3.1

