Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 707ABC48BE2
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:40:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42CA52080C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:40:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42CA52080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D58306B0003; Thu, 20 Jun 2019 05:40:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D08D08E0002; Thu, 20 Jun 2019 05:40:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF6DD8E0001; Thu, 20 Jun 2019 05:40:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 88D3F6B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:40:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y24so3544274edb.1
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 02:40:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=oozrE79QaoIcBcp8bFyNI3KvulN6x7Kit+fi0Nelf3Y=;
        b=kWMvg2Z/q3aE5U4Brm6wDEfMjHdQUT1CqH82l1ly+wQruNWuHyT6gom6s4fzM9tINR
         yumOCXsQxFU9qg5DMEE5Rh49qLEKoL8TK/CCbl4524gVGE4TJ1oou6XKIh1baiMkpIPL
         yaJmtuQeGygcjW3b6I288+oSdR0VfZ/oEJO6jgBxdPhQTypE/pXjUJww5NgN6FdO1Usf
         E86iccpClJO+oA18QpRMX0CPK8b/FGFYoZBpMx6dKrFjkYlwRwUeoiixOTklJ13nnBf1
         EqhhL1ZrSJsVZD/AIWTJAME0RF/67yrINQAjQsUQ4BD8ExT0mC+0ZFVHJ5HksPK5qJ/g
         Y7Qg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAUK0wlPuCK321wxJ9map9dRDCaWCMMF92h/+oadOtdT/LnJNJGf
	94fFRYAj3mDstlkoeVgb2SlxXNG8EODdodDe++9Df0+HGRvHQFe34s8c8li6mKfZudhtCf3toBR
	PoDETz1G7e2UmJmDJpLsySdIAC8BWmpPYv6IDN9Eu8B/f/K29bLhL9nmCrAWQxmDR1g==
X-Received: by 2002:a50:9468:: with SMTP id q37mr9370314eda.163.1561023620076;
        Thu, 20 Jun 2019 02:40:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoznh84fW0z/mScK/W9F+bYLraz8cCIIpcWk4G9zg0gYahELU0zL4OuVLqFpX1iU+0b7Fn
X-Received: by 2002:a50:9468:: with SMTP id q37mr9370221eda.163.1561023618968;
        Thu, 20 Jun 2019 02:40:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561023618; cv=none;
        d=google.com; s=arc-20160816;
        b=b54QhsoXlL0Bd9pF1JWe3Qb7SXXBOnoxIdDVLP53dACZuSLirGqxhXddKELr3m8Ny1
         AANkpEWf5xINyM8Y9ISxE4K0nCZjBXEPgJtgCjNOaDfaDZWL1E9gcjUP9a+pTV7F/pZP
         6usTTYPRenwDQKz2T16FBA9sc2Qs+ZVsWIvv2e48aUlRlbeLGDCbEIw4MKQnoRZfExU+
         c8d0jA+OejBkBDtrwnAut8gfdJJ/MoICBXbOFSmNdd0YzyAM6+cLBlxEuoMDR9X+TJVV
         STKcTwFdqOrYqorzEif7YsRYn5o2XW5kvzp2+OvxZywROe9xvsXRfDzSTpl9Pe9H/hF8
         vn4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=oozrE79QaoIcBcp8bFyNI3KvulN6x7Kit+fi0Nelf3Y=;
        b=LYYXkK6xHF2ItQNcx7EhP1BETgF2jxnsOUhiUnzpUyvkf9uu7CBeMgAufBN+8Kx9wX
         UgkFRRjqfNgQVegudGUEggxOyRMHJfzVAyymad9NkOeYi9UGeAUCqP1FlJtdU9KdrtZ4
         YUBZMH5XlWFELLTvur9gOlIwr26Z1+IX4FcPcIkKIME1y79icu8ItYMru4STUIA+i6Kr
         Ry0d1d1lYg9Eg1iEAo+/gqpljd05QBfdOX8b5DjSHD510dTO1jbAtU70zA0GPUATgY/m
         OhbhZ0pYeAcpH5FCFpt3yTxPlphi+AYrNJLyyHLGwL4jitlwBUu95cojlggikWGOUmQu
         KOxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m26si16652143eda.249.2019.06.20.02.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 02:40:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 795A9AED4;
	Thu, 20 Jun 2019 09:40:18 +0000 (UTC)
From: Juergen Gross <jgross@suse.com>
To: xen-devel@lists.xenproject.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: [PATCH RFC] mm: fix regression with deferred struct page init
Date: Thu, 20 Jun 2019 11:40:15 +0200
Message-Id: <20190620094015.21206-1-jgross@suse.com>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time
instead of doing larger sections") is causing a regression on some
systems when the kernel is booted as Xen dom0.

The system will just hang in early boot.

Reason is an endless loop in get_page_from_freelist() in case the first
zone looked at has no free memory. deferred_grow_zone() is always
returning true due to the following code snipplet:

  /* If the zone is empty somebody else may have cleared out the zone */
  if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
                                           first_deferred_pfn)) {
          pgdat->first_deferred_pfn = ULONG_MAX;
          pgdat_resize_unlock(pgdat, &flags);
          return true;
  }

This in turn results in the loop as get_page_from_freelist() is
assuming forward progress can be made by doing some more struct page
initialization.

Fixes: 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time instead of doing larger sections")
---
This patch makes my system boot again as Xen dom0, but I'm not really
sure it is the correct way to do it, hence the RFC.
Signed-off-by: Juergen Gross <jgross@suse.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d66bc8abe0af..6ee754b5cd92 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1826,7 +1826,7 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
 						 first_deferred_pfn)) {
 		pgdat->first_deferred_pfn = ULONG_MAX;
 		pgdat_resize_unlock(pgdat, &flags);
-		return true;
+		return false;
 	}
 
 	/*
-- 
2.16.4

