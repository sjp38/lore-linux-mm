Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1742C28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BEDF2731D
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Qhl1v0HV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BEDF2731D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 237296B0292; Sat,  1 Jun 2019 09:22:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C0A06B0294; Sat,  1 Jun 2019 09:22:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D59D6B0295; Sat,  1 Jun 2019 09:22:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFDD86B0292
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:22:20 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o12so8222029pll.17
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:22:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=B5mmIFXBwJv1l9kM5SWhBSvZAjXbJapmJmKj7r+SOYo=;
        b=cAfhmGF0ZFcFilLEeslniqb0QOKJNYUXGWhZ/JiDjrz8gjZu9B/tvHt85cqDghzwL1
         mZadSnjI4ojC7UB129ei5A+m8ClBuCMUYwVPdarmria09E1l40BtPYQSUZV1UqKPwHdU
         3/0hq/5pqLZMvrVBTzp4gK35wd9ekXbZHABlVeKYzVawH0VViaz87qkV6b4QF0oooa/a
         JIfoGbNWaVifo5b2Liy9i0zJASRwYqC7tMt2jelZTxSe/bsPhwFcp1p0oW9Av04LJvSG
         EO3DjqKfRtkOjwT0+OnI9J9D6sQo8sCYlFS9lF+9p5tATCsFx12Ecou9tpUvBfsK8y6g
         NFSw==
X-Gm-Message-State: APjAAAUhS69oHcVFO/kWO7LYXEiYIAGupzWxbe5foRXQwP9HrfoW1e04
	mKsaqE6b/qVC88lqkmum3703S7y8BFSMaVU55nsXtWuL899F+IO8mdI9pLouMGl4WyOxX3Yi3XO
	970xjDgIKexLVG6djUSQp0akH3AZ61L2Yuftz+0Ho+pJfVOcylL5OAxyxUXAcF98Y0w==
X-Received: by 2002:a62:3085:: with SMTP id w127mr16596235pfw.170.1559395340411;
        Sat, 01 Jun 2019 06:22:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMLzgLcckXDvzxzEWzGk9i8KLa7YqMax0KAkskhD44OLaHoesmfCF7fKDbX0Pv1MUJObd4
X-Received: by 2002:a62:3085:: with SMTP id w127mr16596162pfw.170.1559395339732;
        Sat, 01 Jun 2019 06:22:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395339; cv=none;
        d=google.com; s=arc-20160816;
        b=rUSzIYRR1mtM81FGzdhZVoqH2we9FAe33ibiewU3E/Pj/cmpVwS2r54Cc74Cwi5M2X
         2r1L9sBxv3Jf7Y5LpfHDzb+WoElt+F7YCvbPt7KeRD2TT2JU3s/c8sm+E2oXe+3hrH9z
         ma6KqoYz7W3TJyrLs1mTleiIoX2s8FsecXX+OFa3KiCPuGQqhIOQyP0o9Gs4nm+6Ajm7
         jnSm1UNqSWERmtY9T828Nw9jS8jhY040SzSNG14YqcwVUvtJxTGA8hozxqvXdn9PG7LR
         MT1jlhaSa8GAZnUWzY2gciu9irTU5TD6draJFNXyUAjEQ7Y9SEPqnYGnU1D+46jqCJan
         wRww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=B5mmIFXBwJv1l9kM5SWhBSvZAjXbJapmJmKj7r+SOYo=;
        b=PaJrykhVZjqz/lVm40McMm7GnUHuPtgmk/ADOSlaKOFZyqMO2l0SS6yZ3Xf+rv8eYA
         62r5RKiGjXI6SNA7DcjUT/Ki00am2C//1iBZon/QHKaFoVeCe92lmTVTAwRD/aTRySzI
         S27mKMwrtJmjuVA4qdNu8ZTQZKAIojDimu54zAy12IPcxikIOGWcZGO1piSYSLxdX9u6
         dfqZXC+GpLd4L2D2wKcrViA7rxbKYfmtC9Q9PoqCVki3exnYsI6c3v6V/xFdebEslanJ
         wrGvx2CeZ/M2QIKqytNfvdUx4SaoYGitktyS3MOMvNs6D0RqJ9qYMcz0xICNU4ZWYP1L
         AV7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Qhl1v0HV;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e14si9699540pgi.586.2019.06.01.06.22.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:22:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Qhl1v0HV;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3C38A27303;
	Sat,  1 Jun 2019 13:22:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395339;
	bh=R6setUJhWF/X4YsMpKmimjEWXraOxYSnQesJTLW/nQ4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Qhl1v0HVYsxwBLT3Z8QgVgmb6MphWMz4RKPRGm1dKFRjaW6ijD7Fpqyva6/mX7psv
	 /Hiqyb/mWTsk+mkFiktl3vAvxVJvmVWxU4mTp9Gg0UIQL2EYIykV4j3U4CgIQDFCLs
	 NrxIIUpxI5SOlJIXZ2Rrt8s8PP33jvgOqhUTYFw0=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 008/141] hugetlbfs: on restore reserve error path retain subpool reservation
Date: Sat,  1 Jun 2019 09:19:44 -0400
Message-Id: <20190601132158.25821-8-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132158.25821-1-sashal@kernel.org>
References: <20190601132158.25821-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mike Kravetz <mike.kravetz@oracle.com>

[ Upstream commit 0919e1b69ab459e06df45d3ba6658d281962db80 ]

When a huge page is allocated, PagePrivate() is set if the allocation
consumed a reservation.  When freeing a huge page, PagePrivate is checked.
If set, it indicates the reservation should be restored.  PagePrivate
being set at free huge page time mostly happens on error paths.

When huge page reservations are created, a check is made to determine if
the mapping is associated with an explicitly mounted filesystem.  If so,
pages are also reserved within the filesystem.  The default action when
freeing a huge page is to decrement the usage count in any associated
explicitly mounted filesystem.  However, if the reservation is to be
restored the reservation/use count within the filesystem should not be
decrementd.  Otherwise, a subsequent page allocation and free for the same
mapping location will cause the file filesystem usage to go 'negative'.

Filesystem                         Size  Used Avail Use% Mounted on
nodev                              4.0G -4.0M  4.1G    - /opt/hugepool

To fix, when freeing a huge page do not adjust filesystem usage if
PagePrivate() is set to indicate the reservation should be restored.

I did not cc stable as the problem has been around since reserves were
added to hugetlbfs and nobody has noticed.

Link: http://lkml.kernel.org/r/20190328234704.27083-2-mike.kravetz@oracle.com
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/hugetlb.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 0bbb033d7d8c8..65179513c2b25 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1256,12 +1256,23 @@ void free_huge_page(struct page *page)
 	ClearPagePrivate(page);
 
 	/*
-	 * A return code of zero implies that the subpool will be under its
-	 * minimum size if the reservation is not restored after page is free.
-	 * Therefore, force restore_reserve operation.
+	 * If PagePrivate() was set on page, page allocation consumed a
+	 * reservation.  If the page was associated with a subpool, there
+	 * would have been a page reserved in the subpool before allocation
+	 * via hugepage_subpool_get_pages().  Since we are 'restoring' the
+	 * reservtion, do not call hugepage_subpool_put_pages() as this will
+	 * remove the reserved page from the subpool.
 	 */
-	if (hugepage_subpool_put_pages(spool, 1) == 0)
-		restore_reserve = true;
+	if (!restore_reserve) {
+		/*
+		 * A return code of zero implies that the subpool will be
+		 * under its minimum size if the reservation is not restored
+		 * after page is free.  Therefore, force restore_reserve
+		 * operation.
+		 */
+		if (hugepage_subpool_put_pages(spool, 1) == 0)
+			restore_reserve = true;
+	}
 
 	spin_lock(&hugetlb_lock);
 	clear_page_huge_active(page);
-- 
2.20.1

