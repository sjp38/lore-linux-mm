Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1F5CECDE20
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 02:31:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 877272082C
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 02:31:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dxV3cVXE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 877272082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A208C6B0005; Wed, 11 Sep 2019 22:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D1C96B0006; Wed, 11 Sep 2019 22:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BC8F6B0007; Wed, 11 Sep 2019 22:31:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0191.hostedemail.com [216.40.44.191])
	by kanga.kvack.org (Postfix) with ESMTP id 66A226B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:31:17 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id EBDC1180AD802
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:31:16 +0000 (UTC)
X-FDA: 75924691794.06.smash44_455a440c9de19
X-HE-Tag: smash44_455a440c9de19
X-Filterd-Recvd-Size: 4654
Received: from mail-qk1-f202.google.com (mail-qk1-f202.google.com [209.85.222.202])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:31:16 +0000 (UTC)
Received: by mail-qk1-f202.google.com with SMTP id x77so27355199qka.11
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 19:31:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=UAihQH4uSn5RAg9F05Rz9nBNcH3iynDYf3mYr8rrHrk=;
        b=dxV3cVXE53/n1Izfi1qmSoph9IuSLiaXaxqFBRHJmANJRLANTHhygEOBautN5vYLCj
         +srTSW3d5IK4BcpNRAwvJc7b1sGCmbqo6ca3DM5wec1k67X5dq6ufUWRvyVj0oeVTVVb
         7LiOgGVm050aCYaOYcAHnzBSOW2a299xVLa5UBWK3S30G4JTPwqaicDk+g6yyesuRzzY
         +hovsva0uSsVmoJDBjRVV9zsYBPq8mDDGWU1fDALy3MjJLHrakk7TzBhN6l1noAYNu9I
         nxPa9xNz4PNTaleaS2NseBdMbaj/J8e8biltj53cK7kDMdmL/HYmZaQeH+WuEPVcRYOX
         kGzA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=UAihQH4uSn5RAg9F05Rz9nBNcH3iynDYf3mYr8rrHrk=;
        b=csGHVrc3p4aUXGAzVPybDeYmuLxVOpl4M9JCPpbEDODyQItaNG95JtAT3730y8Rlyr
         hFmZ2BZKZOR/VM3rJjLw7RIj7ted2FThqGr6JNm26pWGgPXgm62tpARHxcpts4KeqhsI
         Cgc6fbMPsJ2OU0zYzl0afH6zLBL2rtbGCDDdsYbdxnq3VYCGw/k4iWmCMvzYJi/GzFW2
         vcyBtU5/y6z7ouFBNN8FxbL5B3Q9nbzAkd0DFKzC4f5mDccJbYj7ywF5fJnij4qV9M1d
         4nLeMvk+zKaIeANcFQJGR+ZC+U/npcb3fe6MTdWMfgnTQnrnGmdmsf0qIoaDAcP9HBQ4
         pS8Q==
X-Gm-Message-State: APjAAAUeue0WrEIkaQFgKpYSTRDG84RGcybFQzBD6wZb1V+O7phtxIkO
	5n8Cr2uF2tqFhTFpJFToFns5lJpY7cQ=
X-Google-Smtp-Source: APXvYqw6hIJan2hXsnpnadFHERmC023740UAU4ylmmV8A0Q1zp8plE7D7Ur2LZ+/xNarODD+17QdVSzAroM=
X-Received: by 2002:ad4:4485:: with SMTP id m5mr17828114qvt.153.1568255475679;
 Wed, 11 Sep 2019 19:31:15 -0700 (PDT)
Date: Wed, 11 Sep 2019 20:31:09 -0600
In-Reply-To: <20190912023111.219636-1-yuzhao@google.com>
Message-Id: <20190912023111.219636-2-yuzhao@google.com>
Mime-Version: 1.0
References: <20190912004401.jdemtajrspetk3fh@box> <20190912023111.219636-1-yuzhao@google.com>
X-Mailer: git-send-email 2.23.0.162.g0b9fbb3734-goog
Subject: [PATCH v2 2/4] mm: clean up validate_slab()
From: Yu Zhao <yuzhao@google.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Yu Zhao <yuzhao@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The function doesn't need to return any value, and the check can be
done in one pass.

There is a behavior change: before the patch, we stop at the first
invalid free object; after the patch, we stop at the first invalid
object, free or in use. This shouldn't matter because the original
behavior isn't intended anyway.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/slub.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 62053ceb4464..7b7e1ee264ef 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4386,31 +4386,26 @@ static int count_total(struct page *page)
 #endif
 
 #ifdef CONFIG_SLUB_DEBUG
-static int validate_slab(struct kmem_cache *s, struct page *page,
+static void validate_slab(struct kmem_cache *s, struct page *page,
 						unsigned long *map)
 {
 	void *p;
 	void *addr = page_address(page);
 
-	if (!check_slab(s, page) ||
-			!on_freelist(s, page, NULL))
-		return 0;
+	if (!check_slab(s, page) || !on_freelist(s, page, NULL))
+		return;
 
 	/* Now we know that a valid freelist exists */
 	bitmap_zero(map, page->objects);
 
 	get_map(s, page, map);
 	for_each_object(p, s, addr, page->objects) {
-		if (test_bit(slab_index(p, s, addr), map))
-			if (!check_object(s, page, p, SLUB_RED_INACTIVE))
-				return 0;
-	}
+		u8 val = test_bit(slab_index(p, s, addr), map) ?
+			 SLUB_RED_INACTIVE : SLUB_RED_ACTIVE;
 
-	for_each_object(p, s, addr, page->objects)
-		if (!test_bit(slab_index(p, s, addr), map))
-			if (!check_object(s, page, p, SLUB_RED_ACTIVE))
-				return 0;
-	return 1;
+		if (!check_object(s, page, p, val))
+			break;
+	}
 }
 
 static void validate_slab_slab(struct kmem_cache *s, struct page *page,
-- 
2.23.0.162.g0b9fbb3734-goog


