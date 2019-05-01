Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17739C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 05:31:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C876F2081C
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 05:31:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rx8+mRDr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C876F2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65A966B0005; Wed,  1 May 2019 01:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E48C6B0006; Wed,  1 May 2019 01:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D2C56B0007; Wed,  1 May 2019 01:31:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 13A9B6B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 01:31:17 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e20so10456053pfn.8
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 22:31:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=hJGfLPSlXzuDQII6G9FALVwQaMMai8r6WJCEuagoSSY=;
        b=Db38QjuophLdGdiPH4sVWRCT0s/+FoX+a2qjOuu4vAcEzltmJ2H38lWuNJFNk0zvSv
         oAsf5cxJr8GSof5WF2wa5aHhzn5Ro00x9aOD98Fq5IqnJBvGMPaGYzlL9wqTnOV1NL7k
         wXgcJHCs1XebOmD32KAFLVg3Q9ZOzEqSob4ydFA91VhlHbf7AuO2K51sBNzPUUOpdZQN
         5ZMX1wgqMfwEF264+imRMvjm8k5Nh0CB9WKaNFWM1lGcHtQsAIPvkm0u0m29D2DAw646
         KBhHfdoz2lwB4b04QyA8+1GDYLN7PXX61rLF2VCgXw48tSHIRc+5qiyfhdrbdAkerTMi
         rmZQ==
X-Gm-Message-State: APjAAAU+8KrbYwMXlhFqiYmppkkbvrt/eN6PUq5FCH8fiqvqzRZtjTRN
	X5rkqRcw5k6V3v2qhEOaMbAqdTbCg9jaIagPOi7JrTKeh3PtmippiqnXZxn9H5mKFnr4m9z14gz
	ISnwJSOyXlf0HGLEqx/erUfkvtc2XFJMUq89AaaXwvBQ+EJZuKuaYyxwQsOFzijH9AQ==
X-Received: by 2002:a63:5110:: with SMTP id f16mr53422671pgb.107.1556688676672;
        Tue, 30 Apr 2019 22:31:16 -0700 (PDT)
X-Received: by 2002:a63:5110:: with SMTP id f16mr53422598pgb.107.1556688675736;
        Tue, 30 Apr 2019 22:31:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556688675; cv=none;
        d=google.com; s=arc-20160816;
        b=HgqPJ+2h4HfMEQAdt5zTYG6S5me8bj6yzyoL+eKpEimG0Cq/bajILs0hU+GaBHiUSN
         K/E6QUeOC8DtrktRvXS0XFjnOEMNMUKXie47Yee6gZeSqTRHMdTvZOPayiRuwtNU4LTs
         vXWcyOzDLbHTydYViIPLjS5dHDWKKokKAZMfIwo9ASLl67H6d+eEJ+j678qwD9MX8rip
         /AjlTlWYmO5xjcpHSXVx8BVNCL6dMZNJlf9ChLXRJ/YKgACY3zlINi5S8uPc4PtBEG7M
         IvdOFK1HGoF8GvjpwLpgX6TDFKFVllq0qizl7Fjz3S/4RVcbrjegNTWgA+1OcFV7am6T
         TYkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=hJGfLPSlXzuDQII6G9FALVwQaMMai8r6WJCEuagoSSY=;
        b=wZaQj/0aatIttmS5+mjSRNmFIohWrw0maOmeN6rfFfWq82cDdlV7H3Dvy9v3dsH6pJ
         w/tEUX4RySckf3EFMBlzuzHLMMv21JZxc6Sni5XDEWsxvtWei645jHXzCqQNHPys2vQu
         Nz65EOU5qcZPPVyyg5i94yEIlsbQNHEELvmWpPEvQzL39v4ZtOu5FQ/PYTmwUdAXea36
         PoGkjjGO41IC/PwDrOv/OuM9XIfN/L7PLUwqBx0rrB36Kl83lwhyDtvU6coGmdQzj6xi
         6x1ykQG+X+ZITgDqzJovhA0B3GBcprlhp5J+dXmuD0ZQb7Ndf4+VxS5LJE3mKkdyuKC/
         z6xA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rx8+mRDr;
       spf=pass (google.com: domain of yury.norov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yury.norov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9sor3228159pls.64.2019.04.30.22.31.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 22:31:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of yury.norov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rx8+mRDr;
       spf=pass (google.com: domain of yury.norov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yury.norov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=hJGfLPSlXzuDQII6G9FALVwQaMMai8r6WJCEuagoSSY=;
        b=rx8+mRDr7uB513B1QlZ0yFUEOHTB5qybmgkFdh2zQUxBqedApwYu+doW87pZNZlL1R
         h6bwD1t33VlUHjxYTjhprLqFCdjQPz9625heZ8btkekZs4ONNhMAh7hK3rlEuTl7iPGx
         aqDA32BmZUtYG+5xR5mhpGF1ma47lmaWiuR1KgMuKn7JLgaO37Yv7YQ2LGN8Y8Q0QZfS
         6oyuvfoihrlR5ZwtZ7/zu0ahqgSLS4wo3z6/MKdeHQPyUB/6p6wczRE6xbX8JcK/uqMv
         K3Ye285PbVKnpB4e63GX/RgD7rFxz5du1Md0JXQQQl3X2meLo/+1z09kaAPvFbLDpLe5
         hkqQ==
X-Google-Smtp-Source: APXvYqxoerCH7+5HGdXjF6wwjvKIeawAx6VlCaf7+1k4K+pXX0cyWk4hGTP86fKDCPuMZNTFDxCDBA==
X-Received: by 2002:a17:902:521:: with SMTP id 30mr73353039plf.248.1556688675061;
        Tue, 30 Apr 2019 22:31:15 -0700 (PDT)
Received: from localhost ([2601:640:e:200:bc53:6e04:b584:e900])
        by smtp.gmail.com with ESMTPSA id b14sm47835587pfi.92.2019.04.30.22.31.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Apr 2019 22:31:13 -0700 (PDT)
From: Yury Norov <yury.norov@gmail.com>
X-Google-Original-From: Yury Norov <ynorov@marvell.com>
To: Aaron Tomlin <atomlin@redhat.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: Yury Norov <ynorov@marvell.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Yury Norov <yury.norov@gmail.com>
Subject: [PATCH] mm/slub: avoid double string traverse in kmem_cache_flags()
Date: Tue, 30 Apr 2019 22:31:11 -0700
Message-Id: <20190501053111.7950-1-ynorov@marvell.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If ',' is not found, kmem_cache_flags() calls strlen() to find the end
of line. We can do it in a single pass using strchrnul().

Signed-off-by: Yury Norov <ynorov@marvell.com>
---
 mm/slub.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 4922a0394757..85f90370a293 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1317,9 +1317,7 @@ slab_flags_t kmem_cache_flags(unsigned int object_size,
 		char *end, *glob;
 		size_t cmplen;
 
-		end = strchr(iter, ',');
-		if (!end)
-			end = iter + strlen(iter);
+		end = strchrnul(iter, ',');
 
 		glob = strnchr(iter, end - iter, '*');
 		if (glob)
-- 
2.17.1

