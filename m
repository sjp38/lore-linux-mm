Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AA1AC32751
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:00:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E576821743
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:00:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ov06WqFF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E576821743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7764E6B0005; Tue,  6 Aug 2019 04:00:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 726AA6B0006; Tue,  6 Aug 2019 04:00:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6166A6B0008; Tue,  6 Aug 2019 04:00:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2BDD76B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:00:41 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id o6so47847420plk.23
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:00:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QJLvXO26uNAgUTLj60JeKo10xs/5jo+93bjXJtmEioQ=;
        b=glZDmRnKk9Qii1+E9LxRk+kQjIcnLMCZ19ggMo4xvTja5O+g6i/VDN//TN4DbCbaES
         6JHPu/VVeXw2fjwSl+jtwysOi7Oih0igdNO75CsIVnBV7dO8cB9AhLW/+e9+Ov0V4it2
         dDGk3UFXQ2AHpxY1ZlbGWhjVNPVW+HaItalx0IFWVeQSKqUNfA8YLFZyILDajhdb1SR8
         Z6N5YNiICE19Q1MGSefOtXfNVQRTKS+28JsWMJkOG4NWFbGHfmaqoQk5SzM/QboQp0BS
         PAYNajtU1TcAM2AH105jvOnzJipeeBkuCrggkCDlX4j8Fco5vIjbyPkmHKYCb6znkGoY
         WrEA==
X-Gm-Message-State: APjAAAW5BpEuAR7WOFirc7GzQ5XN8z4uzufijZw1HzUPcfyW/wqRHqmY
	oimpAQ368539YBbDQKjq5EVgdIg3vjd5XiZmKFGHJEl3dDdA7nGbiD2Gn4NRvokdEcyXgLn6aWa
	KT4uZWq63EmhbBZ9SMXCMt2ww1EF95FeB/bGK0K9f1GUb06S6ZOgJdMPuvG/Q/CR22A==
X-Received: by 2002:a63:3112:: with SMTP id x18mr1869482pgx.385.1565078440514;
        Tue, 06 Aug 2019 01:00:40 -0700 (PDT)
X-Received: by 2002:a63:3112:: with SMTP id x18mr1869384pgx.385.1565078439513;
        Tue, 06 Aug 2019 01:00:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565078439; cv=none;
        d=google.com; s=arc-20160816;
        b=y6mWM+u09oHQ7HIOBcVRHyjGMBgbApFc0SADLFLg1V3NbgfS6tY3GAz3i39I5kGl88
         B0NTf38z3/WrxMrZfRkuyEGUeV/b+EgU64LhXOME2p/I6XRuirViFhAsP0b1XbR5Bx13
         H6DBJbBKVjvcPQnhxEtm/TcYPetEnf1KHu4mMStjCnWSJQdnTY9MQZALoGMoUpUP5Nhu
         Z3IO9JVXHrA6HXKjR/AUsO2V/bbKavSommiLgSwlg/sYh1ZkvfqWjrQt8sTwiwFQGB2n
         r52Nfj3cixa5QplATTaX9a+pY7mMo/jEpG3kCYzyVvX3x3SlsX4xdxKP65qImjWYsZCR
         E6qA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QJLvXO26uNAgUTLj60JeKo10xs/5jo+93bjXJtmEioQ=;
        b=oK8SoKXAh25rF3Axu+PpTek7bEzxOw2ZQtKo1d1CSW3ffkFmtPFcZjt/hbTi5dnZhh
         fiW7l4OgXiO7vy+pEcjP75uKYopU14SC+jw27EgA8ZWGIJkTi9+MumfcCJkvd/Gg0ah+
         0cn1vTB95oGuTZKqis+8tigNzskmTqBW4DiLeAAfucFTGSs7aCvLJvvxi5yw/PtGl3a3
         XvwEDPdfQ64nD44SUUsbUeJZVXCKHJvwdL1wJfZSwKhO+EL4rXJYv6dMfaQIfLUPPpV0
         CqAlVgcVZTNRwpsW47p+JHJOJNyof5N161iIMRHvJfzbNfJQSxFPKXrGGmcr1FIaJrLV
         2bOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ov06WqFF;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b10sor32607680pla.6.2019.08.06.01.00.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 01:00:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ov06WqFF;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=QJLvXO26uNAgUTLj60JeKo10xs/5jo+93bjXJtmEioQ=;
        b=Ov06WqFFY5F/mrImBwDzAGW2EMBWCuuAhDL1ZdsHVeP80acUV+W08iVCFtalIXtiqs
         Zb2ePWkpruGrrBPtU/pHKyjQbllrpPlgiUhu7jXat9twql0Kp/09g9hxcrSxf6bpAsKk
         Cb95Vt3v/XsCzvrZo1Ettv33EwB0GMhW3PeHDCdoLR4rQqrEa1uy3+OwC4vl7keb48uh
         gy8GVUJ8aue7XghwW9YnFWsBme4do20rvhV5SARX11rG7UTIpsQNvJ63B8inkppv8xS5
         nCu07LatsWfyhe9v1QL5e59QtWMNu7ENLerKRwFz1MIWpsqbYYDH28du8EGWHcXg1wQk
         299Q==
X-Google-Smtp-Source: APXvYqzCPLsm7dfAooib/V/VTYqbHUQPePIInQAoDof4+Yj607pvI0yjcNDlSnn6Ie1lWQ4lqIBACg==
X-Received: by 2002:a17:902:549:: with SMTP id 67mr1920696plf.86.1565078439075;
        Tue, 06 Aug 2019 01:00:39 -0700 (PDT)
Received: from mylaptop.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id p7sm96840679pfp.131.2019.08.06.01.00.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 01:00:38 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/3] mm/migrate: see hole as invalid source page
Date: Tue,  6 Aug 2019 16:00:10 +0800
Message-Id: <1565078411-27082-2-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
In-Reply-To: <1565078411-27082-1-git-send-email-kernelfans@gmail.com>
References: <1565078411-27082-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

MIGRATE_PFN_MIGRATE marks a valid pfn, further more, suitable to migrate.
As for hole, there is no valid pfn, not to mention migration.

Before this patch, hole has already relied on the following code to be
filtered out. Hence it is more reasonable to see hole as invalid source
page.
migrate_vma_prepare()
{
		struct page *page = migrate_pfn_to_page(migrate->src[i]);

		if (!page || (migrate->src[i] & MIGRATE_PFN_MIGRATE))
		     \_ this condition
}

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/migrate.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index c2ec614..832483f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2136,10 +2136,9 @@ static int migrate_vma_collect_hole(unsigned long start,
 	unsigned long addr;
 
 	for (addr = start & PAGE_MASK; addr < end; addr += PAGE_SIZE) {
-		migrate->src[migrate->npages] = MIGRATE_PFN_MIGRATE;
+		migrate->src[migrate->npages] = 0;
 		migrate->dst[migrate->npages] = 0;
 		migrate->npages++;
-		migrate->cpages++;
 	}
 
 	return 0;
@@ -2228,8 +2227,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		pfn = pte_pfn(pte);
 
 		if (pte_none(pte)) {
-			mpfn = MIGRATE_PFN_MIGRATE;
-			migrate->cpages++;
+			mpfn = 0;
 			goto next;
 		}
 
-- 
2.7.5

