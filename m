Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D4A0C31E40
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 03:37:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2FC8206C1
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 03:37:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fkKf6iOZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2FC8206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C2916B0007; Mon, 12 Aug 2019 23:37:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 872F56B0008; Mon, 12 Aug 2019 23:37:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 761ED6B000A; Mon, 12 Aug 2019 23:37:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id 508236B0007
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 23:37:15 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E5A98180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 03:37:14 +0000 (UTC)
X-FDA: 75815993988.14.guide82_3f3b33b60c523
X-HE-Tag: guide82_3f3b33b60c523
X-Filterd-Recvd-Size: 5808
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 03:37:14 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id 196so3604685pfz.8
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:37:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:user-agent:mime-version;
        bh=U2rgZkOq9HT91hzWNExU4fX+p045xHF1HOOjlqdf1zA=;
        b=fkKf6iOZrRUIos/4KB+ONcWJx727j5krY4+u0KUS0QOXRDwqv/rJDwABv3ZLzmVf5w
         8xmZ8/eRKR+I/ePFlrj6N9GazIvQDfzQDowOgRpbA+c8sH4xAXAZ1UhccfGFKYnWAsfA
         V278P84EVpEe3L4VZdjuKkc8amARtiZFMeQNq8BvEqf/r2/Bvgx0Hisce67iDqw1P48N
         x7UWk4KD/VDaY2cm3BBSBgY2o3TJJELz9s7OOJedw9hUAhL2FxAbTpa/MEoeVV6pYQSt
         0gxqT5RhXgQ5gZ1WJtWigGKiAnlAe7qOyU5Fo7yzq9aNvA9rWw6wNBWH+iaf5Oswwx6m
         JPUQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:user-agent
         :mime-version;
        bh=U2rgZkOq9HT91hzWNExU4fX+p045xHF1HOOjlqdf1zA=;
        b=RgAdUwqRHJcb9y/dvmXdjc1W+/UI/TxyjLXCYh4dD3wYwZtktlC/KLHJ749mzo0JKB
         vGIjZ4yTOh41t7Oh/gHQJo+tLWtqR+TBxgOpsxV2ZLR+QWTVGIAsg2w7yL4r9NpdEI99
         2QPT16lVf5gBU1/RVMVUix7v02A1bK3Aq5aX+5bozdFGzDuK76Z15RcIoyWCwai5itAW
         Dm0SSEdOTEvffxlgTDPJM2KJ4GlA6U6oBm0wjaKQbA7zbyvhycmkqvjgoFklU7i/Nvri
         Nsv1uifJmKppfZntY7lbQ2agLj2BubpY8Nk4R07OmKniJ+9q9139C68MMu9s9a1S1vqM
         z7IA==
X-Gm-Message-State: APjAAAVrZotm3PWePOY6krOoze4v4N0rzDbRWkm676CQnbc6O4e8J7f/
	Kvj2PEe/8uEQRoqfWWzAD1PA1Q==
X-Google-Smtp-Source: APXvYqwKcgMErg7JEDUy+wyLR524SPRvaaxPz/kLU2UjT/EztHP9fc+lWMa2kSOuptbwsVl4ppDV0w==
X-Received: by 2002:a62:5c01:: with SMTP id q1mr39002258pfb.53.1565667433116;
        Mon, 12 Aug 2019 20:37:13 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id u18sm54897pfl.29.2019.08.12.20.37.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 12 Aug 2019 20:37:12 -0700 (PDT)
Date: Mon, 12 Aug 2019 20:37:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Andrew Morton <akpm@linux-foundation.org>
cc: Vlastimil Babka <vbabka@suse.cz>, 
    Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, 
    Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: [patch] mm, page_alloc: move_freepages should not examine struct
 page of reserved memory
Message-ID: <alpine.DEB.2.21.1908122036560.10779@chino.kir.corp.google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After commit 907ec5fca3dc ("mm: zero remaining unavailable struct pages"),
struct page of reserved memory is zeroed.  This causes page->flags to be 0
and fixes issues related to reading /proc/kpageflags, for example, of
reserved memory.

The VM_BUG_ON() in move_freepages_block(), however, assumes that
page_zone() is meaningful even for reserved memory.  That assumption is no
longer true after the aforementioned commit.

There's no reason why move_freepages_block() should be testing the
legitimacy of page_zone() for reserved memory; its scope is limited only
to pages on the zone's freelist.

Note that pfn_valid() can be true for reserved memory: there is a backing
struct page.  The check for page_to_nid(page) is also buggy but reserved
memory normally only appears on node 0 so the zeroing doesn't affect this.

Move the debug checks to after verifying PageBuddy is true.  This isolates
the scope of the checks to only be for buddy pages which are on the zone's
freelist which move_freepages_block() is operating on.  In this case, an
incorrect node or zone is a bug worthy of being warned about (and the
examination of struct page is acceptable bcause this memory is not
reserved).

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2238,27 +2238,12 @@ static int move_freepages(struct zone *zone,
 	unsigned int order;
 	int pages_moved = 0;
 
-#ifndef CONFIG_HOLES_IN_ZONE
-	/*
-	 * page_zone is not safe to call in this context when
-	 * CONFIG_HOLES_IN_ZONE is set. This bug check is probably redundant
-	 * anyway as we check zone boundaries in move_freepages_block().
-	 * Remove at a later date when no bug reports exist related to
-	 * grouping pages by mobility
-	 */
-	VM_BUG_ON(pfn_valid(page_to_pfn(start_page)) &&
-	          pfn_valid(page_to_pfn(end_page)) &&
-	          page_zone(start_page) != page_zone(end_page));
-#endif
 	for (page = start_page; page <= end_page;) {
 		if (!pfn_valid_within(page_to_pfn(page))) {
 			page++;
 			continue;
 		}
 
-		/* Make sure we are not inadvertently changing nodes */
-		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
-
 		if (!PageBuddy(page)) {
 			/*
 			 * We assume that pages that could be isolated for
@@ -2273,6 +2258,10 @@ static int move_freepages(struct zone *zone,
 			continue;
 		}
 
+		/* Make sure we are not inadvertently changing nodes */
+		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
+		VM_BUG_ON_PAGE(page_zone(page) != zone, page);
+
 		order = page_order(page);
 		move_to_free_area(page, &zone->free_area[order], migratetype);
 		page += 1 << order;

