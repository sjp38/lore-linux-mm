Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9582C74A21
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 14:10:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 983842064B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 14:10:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 983842064B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CABA8E0077; Wed, 10 Jul 2019 10:10:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 254558E0032; Wed, 10 Jul 2019 10:10:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 141FC8E0077; Wed, 10 Jul 2019 10:10:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB64E8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 10:10:37 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id d65so786951wmd.3
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 07:10:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=TY7yY/Is1vsoNm98cSnkNJrjSVQKwiCCI3+J5kse7IA=;
        b=NkdYnUx5Bkk6gbRNN2aoWRl6Ua9bsjU+dSlLDuV5fau2pf7W5rfjFBu6bJcjPOYXM0
         OSIRuenw+4pa44hJFE/YvuPgGMEdMFgJuwOZc+SSQVe9qRmmQfqUe98D+q0ccvAmlROs
         kX2FNoBWEr2Mpqz4RPTKACsHQAseL8CWGYm1+0jrkEUtHxlqrpB8YeQJwAQgeqMkRDf8
         XsLlh/aPUtcmcW15D0oMoq3i4H6d1+0KqSkejIzWndf0emY8ZhZ4cjxJ9ngMUWue8Yzw
         JHw9v8mFkZYKIjiRNATJH+So5pn1DvHeJ99UHqPmwz8qiG/9GhDbF8yR2eZRAwiyz+ut
         VVUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yefremov.denis@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yefremov.denis@gmail.com
X-Gm-Message-State: APjAAAUaihdkRUK3MYY56FLNQtVrZ62n+d6v29OlujpZ5TADZZ1TpLin
	rcVasxO5MeUsNPtFYjRoD7cP4s2o4jV2wiWpruM+3cBMwuyrkwSfUi2+gLziUfSihLFAg4Jljdb
	fSd217JkfbUDClAtPeBByrzer2dixB/FSzYf5WpPpgjtDmcukKQPR8OWHq2ePYDI=
X-Received: by 2002:adf:ce05:: with SMTP id p5mr5320972wrn.197.1562767837255;
        Wed, 10 Jul 2019 07:10:37 -0700 (PDT)
X-Received: by 2002:adf:ce05:: with SMTP id p5mr5320923wrn.197.1562767836472;
        Wed, 10 Jul 2019 07:10:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562767836; cv=none;
        d=google.com; s=arc-20160816;
        b=0xWn7cQE27GBNsJSoLZrvesfGuzX7b2G4Tz0zSa01GyOaQl+kyTg56fJkE0OaNOZSS
         NsssTXRXSy56zfoHBCR7Ht26M/uuRISa+GFBHLTX7EUw9GGPsIJTgPPySKv4R7S2gvZo
         L0Dv1xscmbCM5ROhI0MmRv4Srqxn3MaIuZGzyWj7ubaTybSaSdWIsAUyQDtzVEezUUnA
         TmCj+FGN3k8o29hCW+xWKco3hWYYb6AocCSRgjgs7Ewx1rkINFGE1JSG6itMTmoCSbtB
         oXjoL6NSMFfLdhQo8CRLvV/g8amnZpjkLW4yUrvn1io8Q3UwBjTpO1v726oADUzy694D
         DJYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=TY7yY/Is1vsoNm98cSnkNJrjSVQKwiCCI3+J5kse7IA=;
        b=oqZVWm1B8MMDsj/N32CDO54ZloIlVfnpT+RdYbHmlJfWwPA/RWMscsoDhvHiXbitku
         uz1QwWAaX/Fb0k6Ez6InO5ouUSJDS/DXegiS/q1goCpC2F/J9vBvDVMfjwd4ZzmwDXE+
         zxkTuIre13UhNnoDB+7q+h8PJoM7QeeZxM6kuzcIrJZw8f3Xaie3XWQu/9gRpsHapd3E
         vJhlj2OMtZtAex7n6gLi+2GYb4epPCwAgxPC5MqA1AubUGSc1ukteG5MzdrII8+R2nXc
         6vjam2IpaMn0xcUwhbvPXnzuwu+2+0ZUnNuXarTtz8JOxYMxx2L7vpvI8Mo4Xzuddqc2
         9A4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yefremov.denis@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yefremov.denis@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t64sor1411095wmg.21.2019.07.10.07.10.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 07:10:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of yefremov.denis@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yefremov.denis@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yefremov.denis@gmail.com
X-Google-Smtp-Source: APXvYqwpYawV7a4WTLPXAorYW3M6lrhk3kn3yQGP3ACjJl/TL2X4QkY/thdNTJS6Tpzo45XQaURDEw==
X-Received: by 2002:a05:600c:2245:: with SMTP id a5mr5603409wmm.121.1562767836208;
        Wed, 10 Jul 2019 07:10:36 -0700 (PDT)
Received: from localhost.localdomain (broadband-188-32-48-208.ip.moscow.rt.ru. [188.32.48.208])
        by smtp.googlemail.com with ESMTPSA id v5sm2733206wre.50.2019.07.10.07.10.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 07:10:35 -0700 (PDT)
From: Denis Efremov <efremov@linux.com>
To: Arun KS <arunks@codeaurora.org>
Cc: Denis Efremov <efremov@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: remove the exporting of totalram_pages
Date: Wed, 10 Jul 2019 17:10:31 +0300
Message-Id: <20190710141031.15642-1-efremov@linux.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Previously totalram_pages was the global variable. Currently,
totalram_pages is the static inline function from the include/linux/mm.h
However, the function is also marked as EXPORT_SYMBOL, which is at best
an odd combination. Because there is no point for the static inline
function from a public header to be exported, this commit removes the
EXPORT_SYMBOL() marking. It will be still possible to use the function in
modules because all the symbols it depends on are exported.

Fixes: ca79b0c211af6 ("mm: convert totalram_pages and totalhigh_pages variables to atomic")
Signed-off-by: Denis Efremov <efremov@linux.com>
---
 mm/page_alloc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8e3bc949ebcc..060303496094 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -224,8 +224,6 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES] = {
 	[ZONE_MOVABLE] = 0,
 };
 
-EXPORT_SYMBOL(totalram_pages);
-
 static char * const zone_names[MAX_NR_ZONES] = {
 #ifdef CONFIG_ZONE_DMA
 	 "DMA",
-- 
2.21.0

