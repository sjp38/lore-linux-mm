Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91DB0C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:36:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 518A320449
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:36:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J04pm3ui"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 518A320449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00E586B0008; Thu,  2 May 2019 11:36:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F00516B000A; Thu,  2 May 2019 11:36:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC93A6B000C; Thu,  2 May 2019 11:36:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0566B0008
	for <linux-mm@kvack.org>; Thu,  2 May 2019 11:36:07 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id j3so1253794edb.14
        for <linux-mm@kvack.org>; Thu, 02 May 2019 08:36:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=IeCbek7GxN78jmKl6HDSULctY9a079sA8sLhO9KSXCE=;
        b=jvcGndSwvhKpJrNLGQ3PEN5dhhLaWMgNztR9cJyvy3WJpJ6eQBYBtds3N4//BadTI5
         c/mRAF6qqsEjpTmkvCtnT+rlNHCv8uKFln1rsYRJLOctzT8GIWRVfKJG4zrVjyrkJZPA
         rZk2tGo0mOrt8ytfqa0zDOWyFJpReYzCABbgUYsiTjrRPbRo1NgarGJGGjkXb+0mbT9q
         b1vmlEeW/B+vZeuMJf9A46Ur6DI20K1D6Sihu3d+SOMWrYZBnQNHxApzv2993joB3qis
         PSke2NznBO4G9mWi2Vott8McDLspu/iDhaC3OuIo2qpXinzDuInX15bNrVOYhEWhf/pq
         wdjg==
X-Gm-Message-State: APjAAAXrdX/XjAeakp5pJtxYRRwyGIJ6TtjAPows6SrkwhjMeh56+XPB
	LgTvOlBvWRc0u4h/2H59BagA2tA1rEbVe++dqjBvKWvKpcy7PFe19JJ/qWssga7CEyUEdY5czCZ
	myro3vEurkdaa9Tbl/DuLu6y/tazddt4HxPmkuF09pr2y1MeeGV9LrQGR1YFLBOJSyw==
X-Received: by 2002:a50:89db:: with SMTP id h27mr1210124edh.207.1556811366890;
        Thu, 02 May 2019 08:36:06 -0700 (PDT)
X-Received: by 2002:a50:89db:: with SMTP id h27mr1210068edh.207.1556811365941;
        Thu, 02 May 2019 08:36:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556811365; cv=none;
        d=google.com; s=arc-20160816;
        b=oQVQd5BesKk+8Czi+lOOBe0E9i7Jw9NshfZSwv+3mMKTisufM88qEnzk1lzuVtr1rK
         k5tHX48k1qsrP3YEwdQ+kvNqpgsdQbme6KXFRjdUMYPduPcr5T90Ck3P68SQ+VClH77z
         q2XZ9KVjAJElIm1hxEE+QmvBv4lhnkYQesPCZymKWoxV6KughwFh86gmExNCOpVDD5ZC
         U8Ve4ruEzPMLLiG9Ily6qOueb9YR02WA3J9h5FOX+KRbMDpqlE4jw2pKcCEjyJHBlfg9
         828THRAceG0UimhXWEKpAYq2EAnXHrpoGKTrcSxbMxlxKTQ6bXYnjURWBZUPKms8+irR
         a0Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=IeCbek7GxN78jmKl6HDSULctY9a079sA8sLhO9KSXCE=;
        b=lhJcvrr1RwiSnJKmOd/jWYKLzuw2VgVY07lf6gZ9XBX6+8HFaIoXDdENPT2ICnnbLa
         SpU4uZhxFjzthenaE9M/ZMMsTY0sGEVhEnXgT0T1sz/3vCZYTIjY6N9jJ9jKdhBUUWhw
         4bHHQKQ0JMV837FYSMAeeG7wSgDMDtB4m4uR06YjSVV17mPzwoKdZX9rQhrqH2NcMJmx
         ALWYHQ8V4gnZolxzZ+Aw86kKjpssUgPto9E2HS16N64IUBT2tY3o8jkuAM3KgL1WMICa
         F4KsY5QqdgO8vIxftWXWyMT6zMDMDR/AL1dGrsad3aQH4keTIIBk/DbcP6HyTdOocy+j
         9RVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J04pm3ui;
       spf=pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=natechancellor@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y25sor4648897edm.9.2019.05.02.08.36.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 08:36:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J04pm3ui;
       spf=pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=natechancellor@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=IeCbek7GxN78jmKl6HDSULctY9a079sA8sLhO9KSXCE=;
        b=J04pm3uinBZj07mQUc20QoDfp+OQk/UzptzIcSRRvJQ+i19xBQyz7UfnOlAK1p63BP
         0hBiwZvxaaLGWRcC+VrF0LkpwlOR1UA1i2R3snOKvD7L2UbudEv8MjBkKgtRLhI5AK64
         +ajHM23pkTed/0m9GmNqamhAvr7SzAISWxzAKDHmUrK7V7yni2jLai0IAq33C+iJDI5n
         vys9SsRMh2mmR4MMQ4o/E9FfPT9tqsg1pQgNNbAYJbopon/cuMATXAkju4JdqQI80A8U
         lE4FFPwdswVeraFDpUWin5auZ+HT9MMpiC8xpByUz81NDaAJFOqUD+QQqbi6NYSx46e+
         Ns1A==
X-Google-Smtp-Source: APXvYqx2dUlDAJbP5jPeB6xQOpTTqQTTzZYY1NEWzH8taBIya6BsF/hTANqdbRNRRF/OpyE8xQJ/mg==
X-Received: by 2002:a50:be01:: with SMTP id a1mr3094467edi.12.1556811365468;
        Thu, 02 May 2019 08:36:05 -0700 (PDT)
Received: from localhost.localdomain ([2a01:4f9:2b:2b84::2])
        by smtp.gmail.com with ESMTPSA id e18sm7386693ejf.77.2019.05.02.08.36.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 08:36:04 -0700 (PDT)
From: Nathan Chancellor <natechancellor@gmail.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Nick Desaulniers <ndesaulniers@google.com>,
	clang-built-linux@googlegroups.com,
	Nathan Chancellor <natechancellor@gmail.com>
Subject: [PATCH] kasan: Zero initialize tag in __kasan_kmalloc
Date: Thu,  2 May 2019 08:35:38 -0700
Message-Id: <20190502153538.2326-1-natechancellor@gmail.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-Patchwork-Bot: notify
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When building with -Wuninitialized and CONFIG_KASAN_SW_TAGS unset, Clang
warns:

mm/kasan/common.c:484:40: warning: variable 'tag' is uninitialized when
used here [-Wuninitialized]
        kasan_unpoison_shadow(set_tag(object, tag), size);
                                              ^~~

set_tag ignores tag in this configuration but clang doesn't realize it
at this point in its pipeline, as it points to arch_kasan_set_tag as
being the point where it is used, which will later be expanded to
(void *)(object) without a use of tag. Just zero initialize tag, as it
removes this warning and doesn't change the meaning of the code.

Link: https://github.com/ClangBuiltLinux/linux/issues/465
Signed-off-by: Nathan Chancellor <natechancellor@gmail.com>
---
 mm/kasan/common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 36afcf64e016..4c5af68f2a8b 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -464,7 +464,7 @@ static void *__kasan_kmalloc(struct kmem_cache *cache, const void *object,
 {
 	unsigned long redzone_start;
 	unsigned long redzone_end;
-	u8 tag;
+	u8 tag = 0;
 
 	if (gfpflags_allow_blocking(flags))
 		quarantine_reduce();
-- 
2.21.0

