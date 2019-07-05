Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1CE5C46499
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 11:48:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C39120828
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 11:48:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C39120828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 316C56B0005; Fri,  5 Jul 2019 07:48:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C86A8E0003; Fri,  5 Jul 2019 07:48:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B7988E0001; Fri,  5 Jul 2019 07:48:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD1EA6B0005
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 07:48:34 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n7so5457481pgr.12
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 04:48:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=aRZ2vfEaIVnJBID5uEzztpVw8FOaMDmzf7eeMYRRIVY=;
        b=h3tfgKFcY2hn6VQAW1Y4vQhurIMqR0+oWZ9dpqDhIHjQifAskHTQE2J1PJk2gi0slI
         Dsgm3tN8+IE2am0jj0FoN6XrN1jCJcyFLmACmSycH+utT0orzk6wZXd9wwfN9aeJn9Y2
         Ex4mUkxpMYLgkiwTGuiivnn/9XdDmTbvX2fLzUvKPNqeYPElqpLycf3hzTA2m5/KprPA
         26i1OCceMWVcnrbCAkIwxYhJeC7KwfNI0tq401nSyq+pTKQPZ/v0TQynGCMIPO2aRMMv
         OMGeZGri0ecAPi6MS3p9C5QBbPOyyCjkQ3YlYLgvYPMGJSMzotCLUpajAs3YT8z/zhqj
         lIvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lecopzer.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=lecopzer.chen@mediatek.com
X-Gm-Message-State: APjAAAXZh9EwUWxLP2/5E6a65azxmojCcL6dDJrsAwcVFvhxgefX4oC4
	DpED/stO1KdTWIRS7kEGncBcUPTh7ArfyA90QyJOJjjCto7xsCQQAtrIJUq4ctusqYfTP97rbAf
	iK1Esbdpe6zYMII+08gPlKC+UW/4KzkpLDeZ1uZuuGC12kAk4084iQK6eBAv8kNAl3Q==
X-Received: by 2002:a17:902:f095:: with SMTP id go21mr5253736plb.58.1562327314583;
        Fri, 05 Jul 2019 04:48:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAci0YZmjZWbtKfMnop/CkEeYl/91hUDqLwIcGTovWI56qhlFANL2vaEotDGFb2QtdL/t/
X-Received: by 2002:a17:902:f095:: with SMTP id go21mr5253671plb.58.1562327313942;
        Fri, 05 Jul 2019 04:48:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562327313; cv=none;
        d=google.com; s=arc-20160816;
        b=KrP5gMlDObyikS4w8bdnhS30CXBbWTGZwaWWt/xNy3j19wkV0V8c7ffb5W3QTrp9kF
         4PI7aDwCGD8zFmX3LpQCiVxEYJjLm3m6ekSASBLRZ+gWrBr4A0lWax1WU7I6A2VWKUn4
         2UgEIyxtJR6/bKjIBMoPc+Qa0618V2Q0A5k3/N7KIffeumDtzO49cmzE2WXKYYXDqn+w
         yT15tmYCvyddABdJU4dydcwLmJkUvbKQd0gS5GdcFBQ08SodqMWxxFV3nJZT1R60gKUQ
         b5K5CVV6ZAHKcRB2ur0Qht5YYCX0z/Injfv2asXpBYEx1GKLBycPESLLuJ1pt808VdVh
         2/zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=aRZ2vfEaIVnJBID5uEzztpVw8FOaMDmzf7eeMYRRIVY=;
        b=qn25LukvsFQmjPGCqegmmPDWQyF1iHp+/bF6LA9srMflxpEipoIQRV7Igja8fKLdlS
         e/F7GFswdD56zy6uxlruzHCNQtfdT21iPjEYW6M4UC3Cc2SI/bPYptuSWP4uEs221USh
         3fNagDPmtXKju/C9W0U67Un2k/HvWBD4gXl0w2e8CjtKFL4ttcedkEGXlS+a0CSe+Gpp
         rehr4aqT/+sW6KQDvB6WTlWxfuX9UUDvELtzrIpj+gFlkDDtGU5pdCr93wk3jhPK/wva
         XcOQVbDugsFx31+SvezOb1pPnJFPI7QDn7vQ3N3rLgTrWMb6pPe4YbH+215XjVGw82zo
         RTdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lecopzer.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=lecopzer.chen@mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTP id e66si8287162pgc.12.2019.07.05.04.48.33
        for <linux-mm@kvack.org>;
        Fri, 05 Jul 2019 04:48:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of lecopzer.chen@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lecopzer.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=lecopzer.chen@mediatek.com
X-UUID: 592531b021a04da2953bf1183a89fd02-20190705
X-UUID: 592531b021a04da2953bf1183a89fd02-20190705
Received: from mtkmrs01.mediatek.inc [(172.21.131.159)] by mailgw01.mediatek.com
	(envelope-from <lecopzer.chen@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1473552831; Fri, 05 Jul 2019 19:48:30 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs06n1.mediatek.inc (172.21.101.129) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Fri, 5 Jul 2019 19:48:29 +0800
Received: from mtksdccf07.mediatek.inc (172.21.84.99) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Fri, 5 Jul 2019 19:48:29 +0800
From: Lecopzer Chen <lecopzer.chen@mediatek.com>
To: <linux-mm@kvack.org>
CC: Lecopzer Chen <lecopzer.chen@mediatek.com>, Mark-PK Tsai
	<Mark-PK.Tsai@mediatek.com>, YJ Chiang <yj.chiang@mediatek.com>, Andrew
 Morton <akpm@linux-foundation.org>, Pavel Tatashin
	<pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@suse.de>, Michal Hocko
	<mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
	<linux-kernel@vger.kernel.org>
Subject: [PATCH] mm/sparse: fix ALIGN() without power of 2 in sparse_buffer_alloc()
Date: Fri, 5 Jul 2019 19:48:26 +0800
Message-ID: <20190705114826.28586-1-lecopzer.chen@mediatek.com>
X-Mailer: git-send-email 2.18.0
MIME-Version: 1.0
Content-Type: text/plain
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The size argumnet passed into sparse_buffer_alloc() has already
aligned with PAGE_SIZE or PMD_SIZE.

If the size after aligned is not power of 2 (e.g. 0x480000), the
PTR_ALIGN() will return wrong value.
Use roundup to round sparsemap_buf up to next multiple of size.

Signed-off-by: Lecopzer Chen <lecopzer.chen@mediatek.com>
Signed-off-by: Mark-PK Tsai <Mark-PK.Tsai@mediatek.com>
Cc: YJ Chiang <yj.chiang@mediatek.com>
Cc: Lecopzer Chen <lecopzer.chen@mediatek.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org
---
 mm/sparse.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 2b3b5be85120..dafd130f9a55 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -459,7 +459,7 @@ void * __meminit sparse_buffer_alloc(unsigned long size)
 	void *ptr = NULL;
 
 	if (sparsemap_buf) {
-		ptr = PTR_ALIGN(sparsemap_buf, size);
+		ptr = (void *) roundup((unsigned long)sparsemap_buf, size);
 		if (ptr + size > sparsemap_buf_end)
 			ptr = NULL;
 		else {
-- 
2.18.0

