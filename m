Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2B7DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 04:13:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DC2E218AE
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 04:13:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DC2E218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2906B6B0003; Thu, 21 Mar 2019 00:13:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 240CB6B0006; Thu, 21 Mar 2019 00:13:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12FA76B0007; Thu, 21 Mar 2019 00:13:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CCEC46B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 00:13:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 41so1736928edr.19
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 21:13:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=K6PUpHTE48CIeYWZZRXfHlIr2vNmtA/KhvkC2I8/wHg=;
        b=pB7ZDPGyjdzl72yFwhrdPiC8XrqgSrJju1g6wRSmmyQ1xZJbLeaOqWvShUwF5iMT6i
         Nv0HabF2QnPL/NsvabdafRICwFDqiytCbnRnq7mMAj61Gvt34h6PXTtQTWhq9nsFHlNE
         OH/TAhzcMazk1uQ19ec+c4ELEr4oKM4TKAYU5tTyxTmwlnA5Po/ZFxoBEu++hDuaehQ0
         WGN+2X5CXTXIa3krlq0zk2TNg6Uus+5t1ArOJKnKOgXnz0UrXMCZyeOkKipxiRxlVOOU
         QZRo399S21Yr6nEepQ9HpqDh8mBxnieAfZnZn0fY4nX404MAPrKgMTJhf4/M1F3QpaeR
         3w1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXvyNykIjKfHtbfa6mVA2LDISl1g/keHkY4liGf23G2BF6oAvLF
	zbgkp5UgyqlCdYyR7ZEiDfniZznxYxpXpx3Vh5OR9+It5XefK7PfKBCfj5a3rBhnIfzkI3QaDPC
	Gr9H6vEywpVX2lbNS6SPqb0Z8v3120qLK/hZpF8KrCT1veBcPszo0xJ7ECKOSlnutvQ==
X-Received: by 2002:aa7:c606:: with SMTP id h6mr995501edq.210.1553141605182;
        Wed, 20 Mar 2019 21:13:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhWeg3/P6u/Jtn0RbpHhcd2f/787scmLNjMxJsVVg+u9c10+xzlh63x+pmVQMsyltDNsml
X-Received: by 2002:aa7:c606:: with SMTP id h6mr995469edq.210.1553141604427;
        Wed, 20 Mar 2019 21:13:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553141604; cv=none;
        d=google.com; s=arc-20160816;
        b=DzPHV1zTOuiperfUMIMqyitrYpHeyuopT7Pn/H9F3cxdVPjoK0g2C0xdtPch7K4ZlN
         +8sOBIFWWHuy53uIYXdWPYuj+3et0iGujvLEnj7+acJD9eLb+n7JtPOlkJKbs4Vb+k0W
         98ipQr9SWmO9K/t2Qd4iA5FISGsVM1+CKQ+V6GiAB0Z+EVIqWa9yTUrJDB+yRpisQRiy
         hfcB1QtMbmgq3+FoAVqSMqTfvm0pyTlSJ6L5Nd6vN0YPv2UPout2pzUUtEEEAYpYJrR9
         MASOgo4oU7YhjBK0EI+/pydHWZCfnvQlzGAF7nJHI36E07RQIoLz+rbvsRaqASzbXYhi
         uUtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=K6PUpHTE48CIeYWZZRXfHlIr2vNmtA/KhvkC2I8/wHg=;
        b=v8tfzvi4nzbEK1QRYkPFUxzDocxgM+tLwcyN3cshcv1XeQt2e+E1PuIzSEDmmvvZSz
         SNy/WHOKydy2X3C0fM5SFJ3qF7INC5FlALD3zdaWeZ1phe7yYmF0Qk8mXBMI6+t9IaQE
         wddRwJRfBD9/9vOEH9wxItoMxailEEOg+6nUZNTR1i4tZw6bc5R+F2FuWd89zT2cmADk
         HP9ijbl2WVzyxSJTxlXAFMP4Sn/i2xf/M8GLK5wMDMeVcqxD1TaWJj4Wl/9+HCi5SOjR
         ojUbEsX2htAwMJfVTGMJZY2Le6jUMGCGotoZSn62u5wbNkY2+rxKkZBfHuiOYNz3KXux
         rf3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d6si629541edi.114.2019.03.20.21.13.24
        for <linux-mm@kvack.org>;
        Wed, 20 Mar 2019 21:13:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E4B2B374;
	Wed, 20 Mar 2019 21:13:22 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.42.102])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 1B1FD3F71A;
	Wed, 20 Mar 2019 21:13:19 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: mike.kravetz@oracle.com,
	zi.yan@cs.rutgers.edu,
	osalvador@suse.de,
	mhocko@suse.com,
	akpm@linux-foundation.org
Subject: [PATCH] mm/isolation: Remove redundant pfn_valid_within() in __first_valid_page()
Date: Thu, 21 Mar 2019 09:43:15 +0530
Message-Id: <1553141595-26907-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

pfn_valid_within() calls pfn_valid() when CONFIG_HOLES_IN_ZONE making it
redundant for both definitions (w/wo CONFIG_MEMORY_HOTPLUG) of the helper
pfn_to_online_page() which either calls pfn_valid() or pfn_valid_within().
pfn_valid_within() being 1 when !CONFIG_HOLES_IN_ZONE is irrelevant either
way. This does not change functionality.

Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 mm/page_isolation.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index ce323e56b34d..d9b02bb13d60 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -150,8 +150,6 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page;
 
-		if (!pfn_valid_within(pfn + i))
-			continue;
 		page = pfn_to_online_page(pfn + i);
 		if (!page)
 			continue;
-- 
2.20.1

