Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C760FC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D15A20449
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:53:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="m97MBGV8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D15A20449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C6CE6B0007; Sun, 19 May 2019 23:53:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 278A06B0008; Sun, 19 May 2019 23:53:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 118DA6B000A; Sun, 19 May 2019 23:53:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFF616B0007
	for <linux-mm@kvack.org>; Sun, 19 May 2019 23:53:14 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u7so9013608pfh.17
        for <linux-mm@kvack.org>; Sun, 19 May 2019 20:53:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=toPMA/JKL4+JCLITlgbKXa8Kcq8nIXcYZEy8G8dwb38=;
        b=DUU3BXKKLBLL86ZMZW8VvugCx+r+PNB9IXbNMB+T8d9PBkMcBuYltakZnGRqr8TnIz
         CHr05fEPRqcR9S+ziwOe+fTJjg+Iuru/DikSCNjglICqQAsilWnEAxnPfP4PG+4qNecW
         qHdlfYrkWGIraXFyY5+JsEdH5yE9/OHz117xksNMV+dfoNxYKgGgCvScul62ynWei1xQ
         RxYxxOGwFUHL219auLv7JkawtEfj8WJjBqC5vd6jg4RiKrzdvPfTgc+3vU0knaOFESwp
         5h7a02xEKyo33d/75qH88seORA0FpBzPbsTDTZRNs+ccD4swrFvxWQXovV+QOVl95L6P
         U7LQ==
X-Gm-Message-State: APjAAAWKSHigJrYSjrQtl2YJ6V9Kgz44SZHBdrXlFWsPoI24SsLn08q4
	WPd+5afhVWJ8zdaFybF7g24rKhF4FMEyZht/2rjl3vimIr4+L+AZXbRSxz1D8z5CF1917eDiOxz
	QgS/vHMuZZM1+tSVnPC8WjpHkIb9ZylLpY9A+dkkzSrGqLB6xOwVOCsBeO3uJcz4=
X-Received: by 2002:a63:1866:: with SMTP id 38mr73187376pgy.123.1558324394512;
        Sun, 19 May 2019 20:53:14 -0700 (PDT)
X-Received: by 2002:a63:1866:: with SMTP id 38mr73187302pgy.123.1558324393371;
        Sun, 19 May 2019 20:53:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558324393; cv=none;
        d=google.com; s=arc-20160816;
        b=jq/Aieg56v1vzKlYok9KILz5eHPe2jIGh7kf6pdampCap49sxTjhNdJKuYsVvksVzR
         Q8tkNHEte7U5xUe4OSW92/tK5b6tT7AI3Q4IJ/utQJPDM7itfaLkO4y/68Us6tSrC1Tz
         RuV/P/6IuoymBDmZsYvgoyNPvuvkVU+hjN77E7ffAOZxE+YiIgmkWVzJdy/UW6onWXnt
         E8jtwmup2ByRjjIB9ReBDdZXovGyhfS87k+WxEh1lQVI2vJhIS+z5XYT9D7p0wTyArXg
         AuZ7Bp5RfwBZpqI/6KN+zDcPQQzIOlFWyfM2bgDQ86qGQqCj/vQ/fKTgOGzjNUwmWl3f
         gymQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=toPMA/JKL4+JCLITlgbKXa8Kcq8nIXcYZEy8G8dwb38=;
        b=M8vhVK4IDfzVcifm76C0wCPHvdPUSq4HdE9pv4Y+7wsXbfSW+vQ72OEID7KUm7L0n5
         bPJtUqqorgO610w9uun+L4AP6sdG34ylkqKXO7PcKwTRLvbwsIW+u7WDj1EJL7CvO8RX
         dcMq751n0lXHpr1LSNwirmUGABVdxqmNem3iImmDJFl+VuvOWiKBbw1p9oT9Nh3ja9Qd
         XUAZKnmgmjxWg8cEJQj7+xM/X7bpHlyzHbV4++crgWKSywv0jMsBYGmyzNXXJsU0RkUg
         twycW5LjSu4Yb87I/45SQkfc69lYq32lWsTCBDpIzDvRVedKQ7kRwl2gsUFCcF1WKL5n
         RpMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=m97MBGV8;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b11sor18141783plz.51.2019.05.19.20.53.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 May 2019 20:53:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=m97MBGV8;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=toPMA/JKL4+JCLITlgbKXa8Kcq8nIXcYZEy8G8dwb38=;
        b=m97MBGV8NBC+cNZm03BDXSfBTqmp4sA5sC300y9OchQG14lFyRfXZJxdfo2GW5E1Bb
         c3a2eND70z1kSueovPmNTmqKCpC99rpeTQndsDVUf33inyAsKgA6/RsH6E/gncjywccA
         vuM7cpJGZEfgjvvX222Uu1QRUDmeJ+PYc75lPHqnU+P/W987PxW3xyUbJChZSE6eMGyx
         cyN5a8kSJdLmiQhXGuthrx0P9H5qOS/gEWmOhYkfBZffzX36ft3VXIMnJACry2QLWwRS
         DR3UDJCoEm2n1/IbKW2+5zR3mM4UNJnM5ITqNNd3i5AbZ4bw07uLzmsXqbjkURtuljj3
         ug5w==
X-Google-Smtp-Source: APXvYqw1v+/XqFbH4qE/picLm8gJqscGg2vCb7a2xfoSbRTwDaEwwBRsuHR2FujTc9592q32a1eZZg==
X-Received: by 2002:a17:902:d892:: with SMTP id b18mr29342232plz.216.1558324393052;
        Sun, 19 May 2019 20:53:13 -0700 (PDT)
Received: from bbox-2.seo.corp.google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id x66sm3312779pfx.139.2019.05.19.20.53.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 20:53:12 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Minchan Kim <minchan@kernel.org>
Subject: [RFC 2/7] mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
Date: Mon, 20 May 2019 12:52:49 +0900
Message-Id: <20190520035254.57579-3-minchan@kernel.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
References: <20190520035254.57579-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The local variable references in shrink_page_list is PAGEREF_RECLAIM_CLEAN
as default. It is for preventing to reclaim dirty pages when CMA try to
migrate pages. Strictly speaking, we don't need it because CMA didn't allow
to write out by .may_writepage = 0 in reclaim_clean_pages_from_list.

Moreover, it has a problem to prevent anonymous pages's swap out even
though force_reclaim = true in shrink_page_list on upcoming patch.
So this patch makes references's default value to PAGEREF_RECLAIM and
rename force_reclaim with skip_reference_check to make it more clear.

This is a preparatory work for next patch.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d9c3e873eca6..a28e5d17b495 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1102,7 +1102,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
 				      struct reclaim_stat *stat,
-				      bool force_reclaim)
+				      bool skip_reference_check)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -1116,7 +1116,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		enum page_references references = PAGEREF_RECLAIM_CLEAN;
+		enum page_references references = PAGEREF_RECLAIM;
 		bool dirty, writeback;
 
 		cond_resched();
@@ -1248,7 +1248,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!force_reclaim)
+		if (!skip_reference_check)
 			references = page_check_references(page, sc);
 
 		switch (references) {
-- 
2.21.0.1020.gf2820cf01a-goog

