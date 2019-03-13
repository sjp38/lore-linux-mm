Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97FAEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:16:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AB632184D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:16:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hOMwU4ol"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AB632184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF3258E0011; Wed, 13 Mar 2019 15:16:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA2DD8E0001; Wed, 13 Mar 2019 15:16:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBC328E0011; Wed, 13 Mar 2019 15:16:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86C328E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:16:08 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id v2so3210618pfn.14
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:16:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6fnYzobl2vLXQNbYiglP4/XI3PVcWRcrV7Bn9vRvS8s=;
        b=TxROP8qxdOrr6BG/ijdMNMm1BBpBHbxuHgJ+xfVqeMgJPn360PK5VjPuUZnripmxMd
         8ZUlVDgm0vsX5iy+N7olRIUMhWbZ0hz1sNOQvw7bgvjUfVgoz3UX3uQuN/28YzJCE3Zt
         8QHgHF5DUQ20LDKh3gRbiN0hx1OSkWIYPdZMnxLc6ZjsIm1bUHMdCLy8P6x/QGgMDqgO
         jT+oavDrYt2dLxs3Zxh4lt5WAYn7XEOX/hYNizUBpvakzxMgIrXvgLF97pmGy/Sz/fqL
         iLER1oBbScwqSmna++O39N/RmQj5MFpG3hFvMTdIQXKeuhexpfRuf6H/g5Xtm54f8Dex
         6ZNg==
X-Gm-Message-State: APjAAAWjD8be47+UWTD45BaZhNBmQxRwtrbZnWJdJfMFg8iW7z5FMvXJ
	4a9MgJi6j/trNjKWrha1uUYSvVyUy92karKQu3OEk8xnIUHjgyHomzcTrYr+mX6OIKquZ+olleZ
	thT9msUhHZmShwm5cPOUb1Ioec7LIj+nARyIqrKE5donCOK2EKcrF+euJLvIfUb20sg==
X-Received: by 2002:a17:902:aa88:: with SMTP id d8mr47466803plr.61.1552504568255;
        Wed, 13 Mar 2019 12:16:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNz6gGsFdZXbyhVBwt64Met2t2hf24P1nL2SBHr7Gnh1DEH5smbkTN/+/wZ6+4oSylz4Gk
X-Received: by 2002:a17:902:aa88:: with SMTP id d8mr47466742plr.61.1552504567628;
        Wed, 13 Mar 2019 12:16:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504567; cv=none;
        d=google.com; s=arc-20160816;
        b=hdJ69KeNDpm2z4WszgVsBNuxqQ2zbOGgs5/sNFJvfeTzzTlOR48xHoHe8pQ/SulGxD
         G0NQdkBNTeN/P+rP4nGqIFp99nvggQeJ/QSENHPs8fzpF1X/DFlcAnlcfB89aEEbztvd
         F+ylpGxRPXVH9/rvnFFGREuxKh3ktT3TKybjNPbvmMlnSMhb6Eq2C0D1yYhBT1T8DDwn
         dyLLclg8O7sSYCFBe4+AlQnPvrNjWooKJCy9mxC/CjcsiJWz6qPsbBEJ1T3ECZ3efDtn
         2xsaxZyl06ooFnwVPGz4TWfO4CmBGtFQ/1x2O9tBKdOL6Ao9XKGwx7kcdcW03NBGpP8J
         8EaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6fnYzobl2vLXQNbYiglP4/XI3PVcWRcrV7Bn9vRvS8s=;
        b=jMt7Grm+QhKny6N6qyRd3blPM+QrXgLHtDOrPvniqdkzCDlx1qpvP5Bp+xmTe+ZQKs
         rY5gxUsedo4X8uVgvIciUwP44QR6keJ1p0jpAfVHoj0TeT4Oo7PjptrddtpRhjMuLWEn
         eecLnDqT9jMKF4as929j3a0GBQGcSXvY+W0jQFNdpvGw1jAWOgUHQaxew/R3IazuGJOu
         9srVbaBa6bJVBKVevVM2021msNlK5QEjNYQ6r7sXFk9xBlg1JfYyxRF0HfKuYWiS+MCv
         oTkqYS6V+87VsP3UBX+Lkx2ULWalN3glklVpi23X5zRS3ybxLi4MqBqkB9c5nt1g8R/D
         Vr6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hOMwU4ol;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g32si11125154pgg.223.2019.03.13.12.16.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:16:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hOMwU4ol;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 99A03217F5;
	Wed, 13 Mar 2019 19:16:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504567;
	bh=WXStNE+A0hOhZFnpfm+WbnYTeAPEF8BMGMrdEHJJtUk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=hOMwU4olg5/X/A86zXSsWZhuv3JKhD/WQ8tIgx50SwiUQfn08P7TGIjGDC0TMAsjC
	 e/mOFZm9wuy+/a3tjmbzm1FQnj4HGHUwjtSmgZVxB0nEFcXGhLLqbSfdOwX4/3fFfT
	 9X8xZodhW18skmY0zvaEilvk820EAXGFAWZPPqoA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 21/33] kasan, slab: fix conflicts with CONFIG_HARDENED_USERCOPY
Date: Wed, 13 Mar 2019 15:14:54 -0400
Message-Id: <20190313191506.159677-21-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191506.159677-1-sashal@kernel.org>
References: <20190313191506.159677-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Konovalov <andreyknvl@google.com>

[ Upstream commit 219667c23c68eb3dbc0d5662b9246f28477fe529 ]

Similarly to commit 96fedce27e13 ("kasan: make tag based mode work with
CONFIG_HARDENED_USERCOPY"), we need to reset pointer tags in
__check_heap_object() in mm/slab.c before doing any pointer math.

Link: http://lkml.kernel.org/r/9a5c0f958db10e69df5ff9f2b997866b56b7effc.1550602886.git.andreyknvl@google.com
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Qian Cai <cai@lca.pw>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Evgeniy Stepanov <eugenis@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index 09df506ae830..409631e49295 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4415,6 +4415,8 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 	unsigned int objnr;
 	unsigned long offset;
 
+	ptr = kasan_reset_tag(ptr);
+
 	/* Find and validate object. */
 	cachep = page->slab_cache;
 	objnr = obj_to_index(cachep, page, (void *)ptr);
-- 
2.19.1

