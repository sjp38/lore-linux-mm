Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA4E2C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 13:21:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9701020843
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 13:21:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JlgbVq8Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9701020843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 321516B0006; Wed, 15 May 2019 09:21:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D2276B0007; Wed, 15 May 2019 09:21:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C0C86B0008; Wed, 15 May 2019 09:21:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB5136B0006
	for <linux-mm@kvack.org>; Wed, 15 May 2019 09:21:18 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b69so1717927plb.9
        for <linux-mm@kvack.org>; Wed, 15 May 2019 06:21:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=9TwqGxcqAmiiOZF0fMbRhR1jD/62UPXQ1qlKx2sBgIw=;
        b=q5oA/Y/t27p4PEXX0gnWsc6CEmbDesO+TU31c6uloUptlcm6QgJbt+XLUkUhN8Im4n
         hUDLvR9HCSljNW1BkgEZwnvd6kKcy+MV9VjzVKDMjLU6PStU/4hYWGCItofp2dP6bpYd
         6qo2p1EDwGd8chp9XgDNYlIIkR8xTqAYbbHGqmucyODcYDD+b5mRvBVK5gVzf9NJyyc5
         jKRaXhOnXpqgTh+HtSCMKakFxsGlyu81c9d8PX+2tpHXIK246vYq+6EhcYNePFMFPTTg
         IJIuJkuZyxVlk9Sc7r5q4rNe+SGsqk7CIf9zAYoShjC+I6343EF7FLm9DhMFjbalZfst
         zskg==
X-Gm-Message-State: APjAAAXPNDzkzYKGoqeNqSMGWfmEvU7zCB4UdP0zpMFy5eItx1924VMr
	RFwSE6sGA4+xwczlYzWLG2w8nbtZRmVnk4SBtrqwXfsvbbASGAW8uXG+T0BJYS0mW0JzcSM5aTD
	QgWXryLNw5bCdzMNOUuX7O6T1L3ZT4yw/PlJrkJG0Gpi/2GYz+p2cxD78MqjoymiVLw==
X-Received: by 2002:aa7:9ab0:: with SMTP id x16mr39880030pfi.201.1557926478347;
        Wed, 15 May 2019 06:21:18 -0700 (PDT)
X-Received: by 2002:aa7:9ab0:: with SMTP id x16mr39879938pfi.201.1557926477323;
        Wed, 15 May 2019 06:21:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557926477; cv=none;
        d=google.com; s=arc-20160816;
        b=ZsKSpGymoj4nboDkiHzeoJUfZWFgcta5NkVi7rDrEfqyNuuovqgVihLNzneX/q+SVi
         MnLFu26rs4pzc5QexCCCTFC+3fYi/1GIA1kAYSYgVxRrjZ+gqzNixiL26nEY6qFlyFGg
         YeJ06z65lXTaIe28Z4S0LxqYR7U0LgATa9cGFN6qCx8bmh+l81Y+36BRd9+RXxvFZ3fh
         NOkCYbppewL6qH/6IXLZvGFEaogVDOHKrHqPX1KLAlDu3z5/CId1//gufN4QbsrZ9MOl
         JAGxkAOdvsOzmcxrNnHT4V0pjZDycXxJ+vDcOStt0e4iHJEN301x3gw3L5qDrMrKZ16u
         HU1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=9TwqGxcqAmiiOZF0fMbRhR1jD/62UPXQ1qlKx2sBgIw=;
        b=qxE+FVPTo6TraOJptkLEumI1n1cxcQgCXm3e9Sb8EkAFGm3M6ISqYsSd2O4Hh0wLjb
         shqg8eCTDk3e5MktMJrWQTzuz5SGkcw04qRU18cBLstDryaOF4Nt6VMf4Afmpw1bE54l
         Bi5d/TgRr0+hh0KZZ8nquZeVHXGccuZiddC8ArggXR2uC479Qgrp4/t1hgPJGsRmYj2i
         ipEIgrqg3QNZPiTz2SdyJTAYaQZOQL8YdBx4bjA2Y2Ou811veHsfS3eGZ7d3AB0GOOW3
         vDH7VUVMNS4qIc47LZNgCj3bdPUJqclU4uquc2hh5FplCk/wxjNY13hNg8/uxoRFP3Ot
         ZbOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JlgbVq8Q;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor1994628pgq.82.2019.05.15.06.21.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 06:21:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JlgbVq8Q;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=9TwqGxcqAmiiOZF0fMbRhR1jD/62UPXQ1qlKx2sBgIw=;
        b=JlgbVq8Qjwpw9WAr3pAylhX1iQ/iYC2g7mT8uRosYuCwHSDM/yTMreG9tYBQVcVNyQ
         BC3/VjABCkHEHMUbtmJ1XRRTjFNlVYrx7pJY+4wKAQ2h1XQhtIWWQjes9+TUvLQY8GpZ
         0BHAGQH2GBe2dBQhPXIAuMQwphBBnD9R55zyuQcMkNaeHWS/m7jNtzmuAXPn0TPRyl1Z
         QtI3c2LEu81tkSQDEm6AJtJ/McHtOdQG8QyM9WvshOaHLKxHkdoyJ+r6XLKyi3M4W+eT
         6TcQq4blbNWTweaNiEeY0T+M83F934W5jcywJmVxHQcdxOlFCYLapC0SZlg61V7F44tT
         ZsVw==
X-Google-Smtp-Source: APXvYqxAXcfJTxXroa2Tygf/+OEh2WGaMRVJDDPwfEwlvrlt/aw5en3n2OvDBvWLLEnZ8lG6AVBaFg==
X-Received: by 2002:a63:8bc9:: with SMTP id j192mr43412507pge.212.1557926476914;
        Wed, 15 May 2019 06:21:16 -0700 (PDT)
Received: from bobo.local0.net (115-64-240-98.tpgi.com.au. [115.64.240.98])
        by smtp.gmail.com with ESMTPSA id a19sm2784459pgm.46.2019.05.15.06.21.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 06:21:16 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: [RFC PATCH 1/5] mm: large system hash use vmalloc for size > MAX_ORDER when !hashdist
Date: Wed, 15 May 2019 23:19:40 +1000
Message-Id: <20190515131944.12489-1-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The kernel currently clamps large system hashes to MAX_ORDER when
hashdist is not set, which is rather arbitrary.

vmalloc space is limited on 32-bit machines, but this shouldn't
result in much more used because of small physical memory.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 mm/page_alloc.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59661106da16..1683d54d6405 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7978,7 +7978,7 @@ void *__init alloc_large_system_hash(const char *tablename,
 			else
 				table = memblock_alloc_raw(size,
 							   SMP_CACHE_BYTES);
-		} else if (hashdist) {
+		} else if (get_order(size) >= MAX_ORDER || hashdist) {
 			table = __vmalloc(size, gfp_flags, PAGE_KERNEL);
 		} else {
 			/*
@@ -7986,10 +7986,8 @@ void *__init alloc_large_system_hash(const char *tablename,
 			 * some pages at the end of hash table which
 			 * alloc_pages_exact() automatically does
 			 */
-			if (get_order(size) < MAX_ORDER) {
-				table = alloc_pages_exact(size, gfp_flags);
-				kmemleak_alloc(table, size, 1, gfp_flags);
-			}
+			table = alloc_pages_exact(size, gfp_flags);
+			kmemleak_alloc(table, size, 1, gfp_flags);
 		}
 	} while (!table && size > PAGE_SIZE && --log2qty);
 
-- 
2.20.1

