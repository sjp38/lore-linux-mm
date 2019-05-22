Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07F13C18E7D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:08:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAEB220863
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:08:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAEB220863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32A6B6B000E; Wed, 22 May 2019 06:08:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DE796B0010; Wed, 22 May 2019 06:08:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A63D6B0266; Wed, 22 May 2019 06:08:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF62B6B000E
	for <linux-mm@kvack.org>; Wed, 22 May 2019 06:08:26 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id 68so949616otu.18
        for <linux-mm@kvack.org>; Wed, 22 May 2019 03:08:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=R2PWREw74tSe9/R17jGNrTFGBbP2fe2DvENyY7ygjHk=;
        b=M8CfkCAXg7CdxUpMVDmUFloFsae+w0r+vj2KsfG4RcVzmusuCBmEkxI/WiVxtmRXE1
         WPeixOSUOG+vGDWCOKbeZw7+XwPor7FbHNI67ZmS8FWR5HiCeqAf9rQ1IVCibURqcgQ/
         yAly1CJzetIX9BsbXIqD6ix0Izvm41k5aW2xemLGqmGM1yKgbM4ppHST5Y0syi06d++H
         zh3SHD3DrxdVNlN3/nPYvfi1oozIUCoz62bEQha2EtcHPVusCg2Ap6e6E/K/Rpq/xHB8
         Mba84WeGfqLlATZArePCIrZM6b41AsQn0dRHCS4IxVAUgb9URHDxHAL1/aizkwynYx2B
         Lapw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAV3+ccJUYd4JuSX5lbYQOUkgIUCwODSQxuwe3bQDFQP7LvSQ1tt
	4x/5aVE+qsO4uYw+jjGjupmKlXQn6T79ZiakeyuBRZ3sbNEio9BN/vS/cBEC1NwxaWbhWc9DcsL
	5fHar5S+n//hSBdK2SKkaSxcvdZcrYXm+cCnxdweYWZcAznPJTBYM2RgZTQDxlZDf1A==
X-Received: by 2002:a9d:71d1:: with SMTP id z17mr26406243otj.22.1558519706604;
        Wed, 22 May 2019 03:08:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8dsOVzc+HBw/ADTcWeNAiJLkzaOlNv/GrZbAVsxBm34xKSyi9YyzEs73mqQltpTgHacvI
X-Received: by 2002:a9d:71d1:: with SMTP id z17mr26406187otj.22.1558519705765;
        Wed, 22 May 2019 03:08:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558519705; cv=none;
        d=google.com; s=arc-20160816;
        b=OPxTUcjtUBmZUYEhlMNI4gFgnpwIRVYdkRa7RVmrYF3rHqiWGEYWzltpQ4nqn7G4g5
         ohUsn0muJJF1xTwyTJB0+f/gKKmAMQeL8TKa92h+ok9xwP/fIeycQ/NdSZrSnDz88lXL
         UUZRVwqYvK72WShcIXf8jZf7Ra+mpQlq6I3FbMOKw/cAYnICahy22DUfhYBHM2C6gUui
         Pwvwgt3wdzovXDGGlUWr8Dr8BKtHWWWUiGA7Oou9YB5zwrWlN2GjfhkMVS4QIMb7G8Cz
         ffBZXrQf4CY2wwmUcH7+CvMLR7vzADZuc5MzdYuHSoC5caknWDlnS5x86BPk9PMFXagW
         c3+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=R2PWREw74tSe9/R17jGNrTFGBbP2fe2DvENyY7ygjHk=;
        b=RH+rgTyK+FTidHpSOqv8jTvrN9JEy1OQffh79YRBXiuuY3B/VfiYHKJ2tea63h9W0v
         9KtWQ4X2RayYixPYgDq8gYZqqMN2bK+cmWaAIMJlKnabSippvYnmseVYSL2HeKpGlk8H
         mZ6VAufonVCNmfT52A7mEvECQNk0E9DoldRxkBazWI4N29l36Fv/uxx6Jf3xnDG8LvzH
         FuAS7E1gMuDScwHURMEqzmd2gz0sfyCyNjbd9WcyBca/hOomc+WH9t3YNG1w3bRpyvNZ
         Sn+cN2XD/RMppbDUdrmpmT4qsibkKWoxwdtcxJWtvCIjuwO+e3HgoFNz0sPkFOWgxIvB
         P0Aw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j13si13264020otn.142.2019.05.22.03.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 03:08:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav404.sakura.ne.jp (fsav404.sakura.ne.jp [133.242.250.103])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x4MA8J0k039248;
	Wed, 22 May 2019 19:08:19 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav404.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav404.sakura.ne.jp);
 Wed, 22 May 2019 19:08:19 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav404.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x4MA8Fdm039015
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 22 May 2019 19:08:19 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 1/4] mm, oom: Remove redundant OOM score normalization at select_bad_process().
Date: Wed, 22 May 2019 19:08:03 +0900
Message-Id: <1558519686-16057-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
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
index 5a58778..7534046 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -381,8 +381,6 @@ static void select_bad_process(struct oom_control *oc)
 				break;
 		rcu_read_unlock();
 	}
-
-	oc->chosen_points = oc->chosen_points * 1000 / oc->totalpages;
 }
 
 /**
-- 
1.8.3.1

