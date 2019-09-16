Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C224C4CECE
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 18:26:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2F5220830
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 18:26:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="KTotiNMc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2F5220830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 450F56B0003; Mon, 16 Sep 2019 14:26:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DA516B0006; Mon, 16 Sep 2019 14:26:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A1BF6B0007; Mon, 16 Sep 2019 14:26:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0215.hostedemail.com [216.40.44.215])
	by kanga.kvack.org (Postfix) with ESMTP id 027BD6B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:26:57 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 92F2B440F
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 18:26:57 +0000 (UTC)
X-FDA: 75941615274.23.smoke33_3cb76bcd4be5a
X-HE-Tag: smoke33_3cb76bcd4be5a
X-Filterd-Recvd-Size: 3467
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 18:26:57 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id u40so986008qth.11
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:26:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=aGLQbvl4lzQC5/TXbcMtzuY6cM2BuLvsBEnb8j57QAk=;
        b=KTotiNMcVlc2ur9IJSCApV52NW7xHvYTihJBLgnlipxQNoOT4b8tescPp0QB8sZ/7C
         xkiTVYZeKdkgYXCT2/Pc/cN7SlweWaPPKXiUnVQ6cfWR2i8+8OSP5lNR/x+sNTOEo3b7
         yjsYsbjOt8CYKHaXt76xDhPwHbFKzSlEkdIaMtqyGIDJNUp6eGLux13Xtosm8r3v0YbQ
         5TOpo1Lw79HZXW2iVWSGgcGhw4nRCQ7YMgKZa3xPHcbW55humIWRzzPf1p5m9KBOI5Q5
         PaJUGXsIfgbHda+pRnOEIVQaXPuQ2PWDDnLt9i59cEpr9ilwaSnAWieqdcGUYG5YMqbA
         kVeg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=aGLQbvl4lzQC5/TXbcMtzuY6cM2BuLvsBEnb8j57QAk=;
        b=qlwkwQ8GgUsnXN/Gt8T0CS+SOUHy/D50MVaHB6fUY+o8fvI107E3mSa3vWtOMxgD58
         iHFNCh398THwgA60Udlh29sFqMQUii4U4jHC8XFkIPzEd5aHI0PEi3SzjupLTT16y9Nb
         nb8l0wcJI0GXlsVcbEqTc8YNor/qM4LHEAPdlNpvc0YymN+Dmr5jcDo0Ox5cvSm0p/Hz
         9NBl81rbqFJ7RIqr+cHw53VKbve6YG236c0uAQH1PeF04drua4G7vYhlpm1ZuRFAx9rJ
         AIIB7by59QCwXEXpD64s4msUBPlXYzlWlDvxA/EqUAei8AuEg6xLnGAQBaJ723Sbq56J
         xYyg==
X-Gm-Message-State: APjAAAXw09tF8GVcVgMiDwNdloI2rgk75DAHvt3Pod/GE3FpXxHqkgn+
	SfbwB/2gqLtsLyfGCgCzUorYww==
X-Google-Smtp-Source: APXvYqz/I3HacN6FvkNZuh2Cn0GSGQRoiZWNIsCw+eVru8DTNDt8Rk9HRURFzC9KiNHUGdAZXxm3+w==
X-Received: by 2002:aed:3903:: with SMTP id l3mr1044065qte.165.1568658416581;
        Mon, 16 Sep 2019 11:26:56 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id i1sm1012700qkk.88.2019.09.16.11.26.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Sep 2019 11:26:55 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: ngupta@vflare.org,
	sergey.senozhatsky@gmail.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/zsmalloc: fix a -Wunused-function warning
Date: Mon, 16 Sep 2019 14:26:48 -0400
Message-Id: <1568658408-19374-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.011134, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

set_zspage_inuse() was introduced in the commit 4f42047bbde0 ("zsmalloc:
use accessor") but all the users of it were removed later by the
commits,

bdb0af7ca8f0 ("zsmalloc: factor page chain functionality out")
3783689a1aa8 ("zsmalloc: introduce zspage structure")

so the function can be safely removed now.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/zsmalloc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e98bb6ab4f7e..24179cfe8784 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -476,10 +476,6 @@ static inline int get_zspage_inuse(struct zspage *zspage)
 	return zspage->inuse;
 }
 
-static inline void set_zspage_inuse(struct zspage *zspage, int val)
-{
-	zspage->inuse = val;
-}
 
 static inline void mod_zspage_inuse(struct zspage *zspage, int val)
 {
-- 
1.8.3.1


