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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05E99C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:00:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B620A2070C
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:00:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="f3hrVj8Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B620A2070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C9FF6B0006; Tue,  6 Aug 2019 04:00:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57A7D6B0008; Tue,  6 Aug 2019 04:00:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4686B6B000A; Tue,  6 Aug 2019 04:00:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F24C6B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:00:46 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w12so12139516pgo.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:00:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VPlLXY0wXzdcZsw+gwjQql0L/1vV4IXahw59/Pbnezs=;
        b=jBXNJJ26wAsPkXVU6xLPrhSi01MQ0zbfq5pomqEg6AysiWhVdqINWwYc7ULchWiNHE
         H2zhyDPsK7jeC0lKFCLHAKlwHFO/nSZdVkN4dFUgXR9Q1A9+WjeS5wnGtYqFpM/M++gf
         LF9FEvOTL7fFfcCr0STznepOn+9PKl5mXwVPl/xT+9Ro1vZ6GYqp6w5vu9T8i1YrJBQ6
         mk64JemDUnveQN6eXhY8tpzv2ElzFZ/ESxJKZ5swrj7Bv9ZO2hNE74PnHvmqm19Rpoy0
         VmDIFXvqgcYee9ANcXzF8p6JWLnYAlTR7iCKX+Fm4cpB61YT8A2r87bMT7KN3o55QpIV
         /Cug==
X-Gm-Message-State: APjAAAX/lXw+ZHlkIAqrafcNnJfh/0Dj+HKAbLOhF+S0FrStlNax5BEs
	ggsxU4hJ2Stpl1t5QHAENxBT+pznOcN2gAD+mb5dhRhqtJInON8mobpvsbsCfIPATb2ljacYrEL
	l8L13jAIT85gl51Hr2lJBPs5AY4OGDflQxAwGKWUDcMWl/xS7InNBa2AaJfpgoV3IoA==
X-Received: by 2002:a62:be04:: with SMTP id l4mr2260972pff.77.1565078445678;
        Tue, 06 Aug 2019 01:00:45 -0700 (PDT)
X-Received: by 2002:a62:be04:: with SMTP id l4mr2260898pff.77.1565078444711;
        Tue, 06 Aug 2019 01:00:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565078444; cv=none;
        d=google.com; s=arc-20160816;
        b=Um7Z9Mucxn6cggENcQSKOUmOkmYKGidJThQm6ak+aQcur2tg+1n4fhc3gAxwCV6wz+
         ZWdeemiZb2R7S8TsmIYzBPVr7FckieO5DpW2Tg5h/cJDY8nMy0MolTwF9WtGZptHNxUj
         V6qyBDD7YEyJNAAThtsPIz8XJST0oWaHcbUU2O0iM9x+f1v2OqklsDaVcuGSjk9f0+bJ
         1yDz/10uhbTZ5XfPFdw4PRT9Yf1LFBG1hiMm6YCSxv17PZKz65SLvuUHpGDqVrtTtPny
         p295GY524JBU1+WwmsrEp+6cDrg/kT9qrSjZas+PIK0X21snBhcNj+UpxYm7C7PAnHkx
         2LJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=VPlLXY0wXzdcZsw+gwjQql0L/1vV4IXahw59/Pbnezs=;
        b=gnDEE9jIOSXkn3W/ZO9LPNcOYIrgQK6jZD7tQxLv/2ryn56bSRL+G/shKia9mSVekc
         FIlhi1i3SYlMzjlpk0hxjCZHeqBzUg2kVbmKZGJalVABhGNpphVw3zohTMpqtHbYQUzU
         RqVMYGD3YyYYxtUvtjKYAvIiOKQ5qJhKa0FhqBiBo1Fe6MZ4YW4Tnwz+8rzNxRoWOvgX
         iHj/9juzCHyHgiQzegJ3k8/gPO2fcG96mxHqOLTbNpO4X8U1ac9Ujna1Jec4DMf+oIxZ
         yFiAqouW4CI8uXkx2qxf1b7RMb6/AZa6QPJpD1NGhuflBCKCBY6YHpg7e/QFhrt0rPjU
         7wDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=f3hrVj8Z;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r2sor66518235pfh.6.2019.08.06.01.00.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 01:00:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=f3hrVj8Z;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=VPlLXY0wXzdcZsw+gwjQql0L/1vV4IXahw59/Pbnezs=;
        b=f3hrVj8ZgSrkyz6mbiTGMtbGJs5//kmK0LanZLxVWpezH8VpgJt8y1ox4rbd5P+7Xu
         rzgSCTmtRAEF7TnsRnCMRtWtnaxg/idNjkjI98rTH/vcVoKdlRfMtcn+GTAVn9u5nrbY
         /kXvVE+IL6jIN3PrJOjEjy2+1PFE9ioV7h3oak9qXBxVb3sVGREH58rI+mP/pBGg9T1W
         dSGuAXe3gUK4/mKwGZhLSa6+q0H8YIiD5gO4WY1k9Liar/mnk7rLB2o2y49Q6Ee68fry
         dmqFLhb6R1cXymhQ7T2tOsaMakcuCNSQbzfwW8Unea6HJvVUNiD4Iic21I5EDOenle3t
         h1/A==
X-Google-Smtp-Source: APXvYqyiwHAHgTc4msK2mvodCQr/+/YaQdZ92NMfmgPYPCboKZknrpOFM/qqY3qhKWJuKDfTi9GXsQ==
X-Received: by 2002:a62:5c47:: with SMTP id q68mr2350903pfb.205.1565078444317;
        Tue, 06 Aug 2019 01:00:44 -0700 (PDT)
Received: from mylaptop.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id p7sm96840679pfp.131.2019.08.06.01.00.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 01:00:43 -0700 (PDT)
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
Subject: [PATCH 3/3] mm/migrate: remove the duplicated code migrate_vma_collect_hole()
Date: Tue,  6 Aug 2019 16:00:11 +0800
Message-Id: <1565078411-27082-3-git-send-email-kernelfans@gmail.com>
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

After the previous patch which sees hole as invalid source,
migrate_vma_collect_hole() has the same code as migrate_vma_collect_skip().
Removing the duplicated code.

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
 mm/migrate.c | 22 +++-------------------
 1 file changed, 3 insertions(+), 19 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 832483f..95e038d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2128,22 +2128,6 @@ struct migrate_vma {
 	unsigned long		end;
 };
 
-static int migrate_vma_collect_hole(unsigned long start,
-				    unsigned long end,
-				    struct mm_walk *walk)
-{
-	struct migrate_vma *migrate = walk->private;
-	unsigned long addr;
-
-	for (addr = start & PAGE_MASK; addr < end; addr += PAGE_SIZE) {
-		migrate->src[migrate->npages] = 0;
-		migrate->dst[migrate->npages] = 0;
-		migrate->npages++;
-	}
-
-	return 0;
-}
-
 static int migrate_vma_collect_skip(unsigned long start,
 				    unsigned long end,
 				    struct mm_walk *walk)
@@ -2173,7 +2157,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 
 again:
 	if (pmd_none(*pmdp))
-		return migrate_vma_collect_hole(start, end, walk);
+		return migrate_vma_collect_skip(start, end, walk);
 
 	if (pmd_trans_huge(*pmdp)) {
 		struct page *page;
@@ -2206,7 +2190,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 				return migrate_vma_collect_skip(start, end,
 								walk);
 			if (pmd_none(*pmdp))
-				return migrate_vma_collect_hole(start, end,
+				return migrate_vma_collect_skip(start, end,
 								walk);
 		}
 	}
@@ -2337,7 +2321,7 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
 
 	mm_walk.pmd_entry = migrate_vma_collect_pmd;
 	mm_walk.pte_entry = NULL;
-	mm_walk.pte_hole = migrate_vma_collect_hole;
+	mm_walk.pte_hole = migrate_vma_collect_skip;
 	mm_walk.hugetlb_entry = NULL;
 	mm_walk.test_walk = NULL;
 	mm_walk.vma = migrate->vma;
-- 
2.7.5

