Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F6C4C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:45:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCCB720C01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:45:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dCOPqR5U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCCB720C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37B8E8E000E; Wed, 20 Feb 2019 07:45:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32AD08E0002; Wed, 20 Feb 2019 07:45:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F4238E000E; Wed, 20 Feb 2019 07:45:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id BD9CD8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 07:45:35 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id v8so1727699wmj.1
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 04:45:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=aaoljckUWXKFfeKRZfZeobgkbuOIuC7kgR+jgoF4iJk=;
        b=iRFb3ZL4Wa0rpFyxZ7+phnSim9fiTqYtebAmGuh4c/w5HeQnPZkpoHik2rW5N89UXQ
         N2W5LndY13TpGL7ZqGqyzE7X9JxBiB+RHXc4sgaa9lPZQZhqBAak7JinuR5cRCW1dfkX
         BPJBCM3Y0lTRH5FcHbVqM4G7MyDxvHx1Eaqwo+Ga8rpdJmFSp+vdH/KMMwwIgpHEagiu
         XhTDvbnjHiYBaVQbm2wN0HNN9hhHVD3/3kn9rf3rhBEhCNfzPjmkczyykXLB+2GVtcMt
         FBuMZ9XnLlz8SuGJIpm+9mfwHEDKFqqqCA0qonqROyH/ZSjPUqKGuUEwZFYv6Drb2Fj7
         PatA==
X-Gm-Message-State: AHQUAub/TSzKurpE/zzSlLQ9axcerJmUuoBUBBRz9eQExKNqZYLSY/76
	lJF7EqJT7w1/eGEXqvHzX+GrF6P1xfUNgiE4NwM1HNFQsLQn+ZzUFo6VFodGEqaC7xfL78LFF4E
	xBLVK0l41i9PIDSlBrGugQ8Yzz//D2tkWHCHWPQ/d44N1plY7UapMeZIBZI+Q10nEumA3chCbqO
	/8n8f+yXPKBxehljQLAxrz5ofK38gvTh9d4CC0DKBiXgSb1451LQnYg5U1z/tdCDfZDnx1q19Fi
	RoNEFmZFoKsErL3jie3eUNtYKkTLqQSPjHBted90/Imgl9lUsLOPAQOGFxJrOUJUhmXfUeLIAGQ
	o3iJt0fUVMhNLztpXL1SHIChiBWwFeybe8D4hs7KmqznW+wL3fPuSgrMUaaiF8moZCop/YqyZXR
	Q
X-Received: by 2002:adf:f786:: with SMTP id q6mr7998198wrp.125.1550666735231;
        Wed, 20 Feb 2019 04:45:35 -0800 (PST)
X-Received: by 2002:adf:f786:: with SMTP id q6mr7998155wrp.125.1550666734251;
        Wed, 20 Feb 2019 04:45:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550666734; cv=none;
        d=google.com; s=arc-20160816;
        b=jfFdgUF4ogbgeLiKAIL2U/1ffxvIeON7Cn8957niXhmrK4EFBs42862cgKNcF+jgIn
         OgQjV2g3UlVHfWfdMmg7sqJSPgQN3niBcXyGerTNeIhqGppeTUJfGvSOLiM7tTs/TpMi
         pEd4KG6+a4dI+kuJcS6NBwXs7qlmYdVw2s5An3/NqdVbqC7kBl4WgaU+u0tampC0r3R9
         C/zRxzK8SYl8jy+fUjnyuQrLAH34dY5nnPsBBsBOS5PqGYp0x2k4dfLsOwt/kFY5SatW
         7UiDR/RzY5Kwov1gzsgyE6TR315Y5DEj5ep7b9g1yeyn94HA4GTub1YjY5cOYm3OgyGO
         SY4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=aaoljckUWXKFfeKRZfZeobgkbuOIuC7kgR+jgoF4iJk=;
        b=0WKewkWDgEBoEe1qAnkCXTyaOxDsVrdhaHFaaCy9hFrsZox/gSu0MCvp2cAFsB9569
         Us5UvpdI7iXUjXwEdT/pVLsWiF+C1drJtJMSL+SKOsYA9/D0rVswPJnXmI8sC24OmArH
         zRNBAb+qvqRGGuuJh1BgFJ6AUvZd8JIZ/+pyUE3WkZMdJHnJjbgLbi8n5DZc3ucPN2qK
         cNiBO9o1eZ3rm9SuRpgxXbh24IDffD++wnSG2Y1viVMTsSU9M/7Fh9CfyLdLxryscEsc
         Xk2xq/nm8VgpD4t5pzRo/hP40BzmNzz9FnsKU7/6srUYEbYBwODGV2aoFcCtR3ZnNlj4
         xCXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dCOPqR5U;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v4sor9289709wrq.30.2019.02.20.04.45.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 04:45:34 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dCOPqR5U;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=aaoljckUWXKFfeKRZfZeobgkbuOIuC7kgR+jgoF4iJk=;
        b=dCOPqR5UrKNy/r0gjEIkUKwXsNa3lqaV8sDMBn1OFghR6pdRIBuiH3LFXpJduArWHy
         QaCnlzYPUFbkqtAFyZrxQcZdVGWx28NjSPL8HCV8eCAgi/gTX7GArzZCa7EYUTlRVgfJ
         aQPv8HLTo8Hh6IQAhrMsYkO0+Y64RGeF/xTCt8LY+lkuKeOuzVlMOXyUQw72lTrxCCoR
         hVkRHVHerQDTiqt71u2jBrrOofsTEp/vWPOkV0TAHiaijjr8GAtgukm9R6JwRTf2llpU
         T9Mmuof7mcWq/f0BCOypG2mg0kE5Mc6dqLbwKcRI6EVyNpKcGQt+HF1NLdw43wUYqvYv
         8/8w==
X-Google-Smtp-Source: AHgI3Iahe8QNa86C6LoUNOB1tqAbTiNm3ZOgBS6ROc45eIbTQYdz863wRnoMcCuGABBxrPdDyzXdCA==
X-Received: by 2002:a05:6000:128f:: with SMTP id f15mr23652406wrx.74.1550666733631;
        Wed, 20 Feb 2019 04:45:33 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id f196sm6378889wme.36.2019.02.20.04.45.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 04:45:32 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 1/4] kasan: prevent tracing of tags.c
Date: Wed, 20 Feb 2019 13:45:26 +0100
Message-Id: <9c4c3ce5ccfb894c7fe66d91de7c1da2787b4da4.1550602886.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Similarly to 0d0c8de8 ("kasan: mark file common so ftrace doesn't trace
it") add the -pg flag to mm/kasan/tags.c to prevent conflicts with
tracing.

Reported-by: Qian Cai <cai@lca.pw>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/Makefile | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index e2bb06c1b45e..5d1065efbd47 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -7,6 +7,8 @@ KCOV_INSTRUMENT := n
 
 CFLAGS_REMOVE_common.o = -pg
 CFLAGS_REMOVE_generic.o = -pg
+CFLAGS_REMOVE_tags.o = -pg
+
 # Function splitter causes unnecessary splits in __asan_load1/__asan_store1
 # see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63533
 
-- 
2.21.0.rc0.258.g878e2cd30e-goog

