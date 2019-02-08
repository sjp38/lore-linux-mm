Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF2D4C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 09:06:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 735E12147C
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 09:06:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 735E12147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 132DC8E0086; Fri,  8 Feb 2019 04:06:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E2678E0083; Fri,  8 Feb 2019 04:06:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3B4C8E0086; Fri,  8 Feb 2019 04:06:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B512C8E0083
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 04:06:24 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m25so1079487edp.22
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 01:06:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=T4BWiNXsmAAV1n3HhGDjUcuQfulQBVoY0Uxzky8E1ms=;
        b=cz6kuw7nNP6Eo0Tc0+pty+BgMilA14L31ZCksEsbLNXIHU7nzqdW+Gt9d5OCJbeRzX
         SzYxymmdSQhMN1aXSSEU2MthsviMu0B/ZhxXwpeuFa2Cdrqy3nJQxYVBZv7TBrT85LXT
         HI5KcQAgrXOivlKZen5lg6Pok0wdGiukPtQmzncfKmm9R7h8UC36kfjiE9r5XsWMBJqL
         HYv8DdLLyLs3/1epB762s+pAjGYuGv5MTg2OAnGBgfBm/yf8i2w4wZltYw5Kf1m6H39O
         REGZiHCf5tAtz4fQ+moVptCv6+5GoEbM0dpysTd4HD7bqOfjfwYO9qx41kZ+Ijea5Baf
         fc5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAua6N0j3edzWwzeG1Ei7qXrQoFMD+yrPLLYh+Y2MEyzsCy/qeaRF
	GqptenCKJo+I6lKFgfU4ho4UvHKznu0+JUx+C0fYywHnMfeu3F0PgPfnXCCC7oWZhDYcthOnRtE
	tEHg7mBH/G/HaqdwTrBCPKIVjWVrvGufLixJ2xkD4fHOw7X4YcpTOhWp9LVtxKh/NdA==
X-Received: by 2002:a50:d643:: with SMTP id c3mr15522622edj.178.1549616784233;
        Fri, 08 Feb 2019 01:06:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbT/qeZmigSd2DNCyTUpIUo+xhNGEzf3kEor6DzTSgSKg9PzNhgOilAS3jy7y1pjnZ7i4ku
X-Received: by 2002:a50:d643:: with SMTP id c3mr15522573edj.178.1549616783298;
        Fri, 08 Feb 2019 01:06:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549616783; cv=none;
        d=google.com; s=arc-20160816;
        b=ZO79clqYPZ4/Ew8YXQv50TFHChGtV+LPE4GEixdhmxCL9pBPBo98VDHF/8O7/8TYDy
         BasfKEunBYkpVAtRuzjpYEX+IUM7aMoipwer4bVvq6F8NeIaa03Vy38bd4LeA6ne5+EB
         opoyJ1j6hAxDH/AUfoNS7QUqzwAezP6YsvneD711QT9eJ6Nw91ZMnYtjgZJoONCqjfrD
         y3EX5cPX368es5iMhkt1fffnnFlKGyb4EQ4nhPnMI7NhHopA46fQpEEv3aHD/O9JM7Mo
         4gqCPiHQiiKDiuvTGXVcJphbmq8MvXcUAC/cwsD8cTHvsGAmw/Z2czVzYUJEPH7GCJsJ
         2cUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=T4BWiNXsmAAV1n3HhGDjUcuQfulQBVoY0Uxzky8E1ms=;
        b=RcvqFB50Lq/fb1i+ljl0wrykorV8sl9Mj4TL5y17xYhoEgTxXrqgaAsLr3SMWyn4u7
         nn/5yQ0s8TWimrIu9iDvRirkTDcjM4P374zXN8uhI0WosudSCWeJ34kC/reZ0mS939ha
         EPcLQsVBvliT+nwrwrMxUxn1x2d/P3v7nMz+GnFOut1N5Y/rQvyPaSRdwvYdac0wes3i
         mL7UvomeWq8G4osh9y9YI/YgGLnG4eVRjkFL+iN7pEPKq8IZwir8MuMOkjGr7HNXF1AJ
         EhbORne1hIQoqEzU/DXZIf4x0uCQ3cpCHlPCv/SSfcjgiNaCge8gb6rFCwpj0B8zLn1P
         mKcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id b6si809766edi.277.2019.02.08.01.06.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 01:06:23 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Fri, 08 Feb 2019 10:06:22 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Fri, 08 Feb 2019 09:06:14 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	anthony.yznaga@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH] mm,memory_hotplug: Explicitly pass the head to isolate_huge_page
Date: Fri,  8 Feb 2019 10:06:04 +0100
Message-Id: <20190208090604.975-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

isolate_huge_page() expects we pass the head of hugetlb page to it:

bool isolate_huge_page(...)
{
	...
	VM_BUG_ON_PAGE(!PageHead(page), page);
	...
}

While I really cannot think of any situation where we end up with a
non-head page between hands in do_migrate_range(), let us make sure
the code is as sane as possible by explicitly passing the Head.
Since we already got the pointer, it does not take us extra effort.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 656ff386ac15..d5f7afda67db 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1378,12 +1378,12 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 
 		if (PageHuge(page)) {
 			struct page *head = compound_head(page);
-			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
 			if (compound_order(head) > PFN_SECTION_SHIFT) {
 				ret = -EBUSY;
 				break;
 			}
-			isolate_huge_page(page, &source);
+			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
+			isolate_huge_page(head, &source);
 			continue;
 		} else if (PageTransHuge(page))
 			pfn = page_to_pfn(compound_head(page))
-- 
2.13.7

