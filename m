Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A89CC072A4
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 04:50:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B870820851
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 04:50:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="mI5vScJ4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B870820851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24DCD6B0005; Mon, 20 May 2019 00:50:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FE4B6B0006; Mon, 20 May 2019 00:50:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0ED976B0007; Mon, 20 May 2019 00:50:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD2D16B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 00:49:59 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d9so9134628pfo.13
        for <linux-mm@kvack.org>; Sun, 19 May 2019 21:49:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=xkToWfPhUbXUlBSKuzZG3pFF8m3+cgJ3j1xebIaK/EI=;
        b=Lkh9hd7RB7c9xQbOeMvCxVhOxIKUNwWOEEvrrrF3mYa7Fca7sIgJW/MZr2XlDfOHHz
         E9y90/xmXPYuW8nZoA7ioJZli+m/eJYA/q+0ua1yFdsskzKXKyae31OWAEW37SdmYF2g
         YoVvrIxvI43t5C8oA4OFQqbTVq3Lb2bJ6GfjNWNbbkxPM/lUWiz45J39DRHfLzRn59Mo
         GfVKZMns5GNPLP1WtGGkWsFRIA92Yr948oLkf9FNY2IcUanf07KA0cypQkjJmGuUlA2s
         AkIJQbyD4N1Sg+baHNnsufUG+2PfCiPiXQ8vFu6u8lZcUbg4HIQqqHRjYjUZhfSeVk00
         A3Vw==
X-Gm-Message-State: APjAAAUbphoJMDRBZTrbiR5ttLtx4G0yIm4YblpOC9kH0dDIK3KwC+rM
	qHkMFM+j2HqeZnDGgM3AcQZpH/mt13rsor4TspNqnBO/yPFvchHshWEJnEUJq9OawIXd5iN/ETy
	9CBZjSAYfRp8tjEETWM8PYFJsE0q+UCFUq+Mq5WttQ3iRMCWUCFpuaO70x8TFqR0emQ==
X-Received: by 2002:a65:4b88:: with SMTP id t8mr73234556pgq.374.1558327799432;
        Sun, 19 May 2019 21:49:59 -0700 (PDT)
X-Received: by 2002:a65:4b88:: with SMTP id t8mr73234518pgq.374.1558327798737;
        Sun, 19 May 2019 21:49:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558327798; cv=none;
        d=google.com; s=arc-20160816;
        b=G1gzgZX4ESQaRQHlwoy6VA8LvQkX4/QXgyG7ub0SSsY7ML2gPVAxQu7kAXGVNFUzoJ
         AbomyV2FkPlUrDqiNoljyq12ZOImFyWSdrSlvNUyeVLtvRSLedJUfVgJZyjPkSSZ6Arg
         Ga4q1FdO5jxsBoSZUpibCkIvTUgWie/1l9/KxtzE8K/uoae68PPKulMOczmsmHEcjAlb
         3Gt5HiFCxrhaNuKQOOrmxt7iYOL+krj88Y95hYgibggehWFizxqUbaiVppBNkaNKQLeg
         4cWBUhxC5W8Jm9jY/UYrAg2gTSfr1b5SPyTyxkMIKOjNezq04e7N7EUAKA1SAXJ67Woh
         zMJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=xkToWfPhUbXUlBSKuzZG3pFF8m3+cgJ3j1xebIaK/EI=;
        b=nhrtOH8Eohk0ogsIDeZtRSYX0yWPCxaFHg+j2gMes5QSnwAkfBTzHBUTgWrmjWHCKZ
         FVVGxxtNiIT76CnP2Ztg6jNjuWQw3usvLshphbhN/YOw6xZdo/aw/b6qYw/nzVEHMlHG
         vNWMRk7tr9OAHO3KOPmgCy051bOs1mILY/edmTqSaLiiUW2udo1dZyWRRkFlhPjSSg7u
         DtvKerEUUiAgOjnxOT9m9tXSmzaKLNN7+qPwStNy6rAecxiK60BfcatSrhNPkmRf4jVS
         f+Y9W3crd3T3/5Rl7O8zj4tgPQIhhgPYEP9gCmW6L16Zrs1qGQC0OBZt4xSCniNt9fbF
         vUxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=mI5vScJ4;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c12sor16133855pfr.69.2019.05.19.21.49.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 May 2019 21:49:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=mI5vScJ4;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=xkToWfPhUbXUlBSKuzZG3pFF8m3+cgJ3j1xebIaK/EI=;
        b=mI5vScJ46CfONQKk0BXuJqgqaOpncnnzaBz3sQRykYdFNJRSapviixTBiuyNXhv3Lj
         IKXhEYu8bwmxqqhsj4jf31vawxOk5hgaSWCzkrl3jSNirETmZA+np4paeXOlSZGefx++
         v/lIzQqsOCjlows+Onq9agp+5xzN+dFq06s1M=
X-Google-Smtp-Source: APXvYqwN55gQbIsuZenQKAzA8VBSQYQ1vm8yCPL9giuGjnZvDoaeAZMfk2h4f+nYBl2QObZZzuXkCQ==
X-Received: by 2002:a62:ee05:: with SMTP id e5mr76083541pfi.117.1558327798179;
        Sun, 19 May 2019 21:49:58 -0700 (PDT)
Received: from drinkcat2.tpe.corp.google.com ([2401:fa00:1:b:d8b7:33af:adcb:b648])
        by smtp.gmail.com with ESMTPSA id 140sm26022608pfw.123.2019.05.19.21.49.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 21:49:57 -0700 (PDT)
From: Nicolas Boichat <drinkcat@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>,
	Nicolas Boichat <drinkcat@chromium.org>,
	Michal Hocko <mhocko@suse.com>,
	Joe Perches <joe@perches.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-mm@kvack.org,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Pekka Enberg <penberg@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/failslab: By default, do not fail allocations with direct reclaim only
Date: Mon, 20 May 2019 12:49:51 +0800
Message-Id: <20190520044951.248096-1-drinkcat@chromium.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When failslab was originally written, the intention of the
"ignore-gfp-wait" flag default value ("N") was to fail
GFP_ATOMIC allocations. Those were defined as (__GFP_HIGH),
and the code would test for __GFP_WAIT (0x10u).

However, since then, __GFP_WAIT was replaced by __GFP_RECLAIM
(___GFP_DIRECT_RECLAIM|___GFP_KSWAPD_RECLAIM), and GFP_ATOMIC is
now defined as (__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM).

This means that when the flag is false, almost no allocation
ever fails (as even GFP_ATOMIC allocations contain
__GFP_KSWAPD_RECLAIM).

Restore the original intent of the code, by ignoring calls
that directly reclaim only (___GFP_DIRECT_RECLAIM), and thus,
failing GFP_ATOMIC calls again by default.

Fixes: 71baba4b92dc1fa1 ("mm, page_alloc: rename __GFP_WAIT to __GFP_RECLAIM")
Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
---
 mm/failslab.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/failslab.c b/mm/failslab.c
index ec5aad211c5be97..33efcb60e633c0a 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -23,7 +23,8 @@ bool __should_failslab(struct kmem_cache *s, gfp_t gfpflags)
 	if (gfpflags & __GFP_NOFAIL)
 		return false;
 
-	if (failslab.ignore_gfp_reclaim && (gfpflags & __GFP_RECLAIM))
+	if (failslab.ignore_gfp_reclaim &&
+			(gfpflags & ___GFP_DIRECT_RECLAIM))
 		return false;
 
 	if (failslab.cache_filter && !(s->flags & SLAB_FAILSLAB))
-- 
2.21.0.1020.gf2820cf01a-goog

